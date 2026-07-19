#!/usr/bin/env python3
"""
gen_odata_loaders.py — генератор SQL-завантажувачів живих даних НСІ з OData.

За field-map.json (згенерованим gen_catalog_batch) будує детерміновані
завантажувачі для набору довідників:
  • raw-ddl.sql — staging RSD_ODATA_RAW (сирий JSON, ключ entity+ref_key).
  • stage.sql   — сторінкова вибірка кожного Catalog_* у RAW (apex_web_service).
  • project.sql — типізований MERGE з RAW у RSD_*: скаляри→json_value,
    перечислення→RSD_ENUMS, посилання (<Поле>_Key UUID)→локальний ID через
    target.LEGACY_REF. Запускати ДВІЧІ (реконсиляція циклів).

Двофазність (raw → project) знімає проблему циклів: усі записи спершу в RAW,
потім посилання резолвляться проти вже завантажених типізованих таблиць.

Використання:
  python3 gen_odata_loaders.py --field-map migration/003-.../field-map.json \
      --tables RSD_KONTRAGENTY,RSD_POLZOVATELI,... \
      --base https://rv.entercom.ua:5683/bas_doc/odata/standard.odata \
      --out-dir migration/004-data-nsi
"""
from __future__ import annotations

import argparse
import json
from pathlib import Path
from urllib.parse import quote

EMPTY_UUID = "00000000-0000-0000-0000-000000000000"


def enc(name):  # Catalog_<Имя> з percent-encoding кирилиці
    return "Catalog_" + quote(name, safe="_")


def jpath(field):
    return "'$.\"" + field + "\"'"


def proj_expr(f):
    """SQL-вираз для колонки з doc (RAW)."""
    k, od = f["kind"], f["odata"]
    if k == "legacy":
        return "json_value(doc, '$.Ref_Key')"
    if k == "bool":
        return f"case when lower(json_value(doc, {jpath(od)})) = 'true' then true else false end"
    if k == "enum":
        return (f"(select id from rsd_enums where enum_type = '{f['enum_type']}' "
                f"and value_key = json_value(doc, {jpath(od)}))")
    if k in ("ref", "ref-ext"):
        if not f.get("target"):
            return "cast(null as number)"  # ціль поза набором — реконсилиться пізніше
        return (f"(select tgt.id from {f['target']} tgt where tgt.legacy_ref = "
                f"nullif(json_value(doc, {jpath(od)}), '{EMPTY_UUID}'))")
    # scalar за otype
    ot = (f.get("otype") or "").upper()
    if ot == "BOOLEAN":
        return f"case when lower(json_value(doc, {jpath(od)})) = 'true' then true else false end"
    if ot.startswith("NUMBER"):
        return f"to_number(json_value(doc, {jpath(od)}) default null on conversion error)"
    if ot in ("DATE", "TIMESTAMP"):
        fn = "to_date" if ot == "DATE" else "to_timestamp"
        return (f"{fn}(substr(json_value(doc, {jpath(od)}), 1, 19), "
                f"'YYYY-MM-DD\"T\"HH24:MI:SS')")
    return f"json_value(doc, {jpath(od)})"  # string


RAW_DDL = """\
-- staging сирого OData JSON (ключ entity+ref_key). NLS_LANG=.AL32UTF8.
declare
    n number;
begin
    select count(*) into n from user_tables where table_name = 'RSD_ODATA_RAW';
    if n = 0 then
        execute immediate q'[
            create table RSD_ODATA_RAW (
                entity   varchar2(100 char) not null,
                ref_key  varchar2(36)       not null,
                doc      clob,
                loaded_at timestamp default systimestamp,
                constraint RSD_ODATA_RAW_PK primary key (entity, ref_key)
            )]';
    end if;
end;
/
"""


def stage_block(entity_odata, entity_ref):
    # $skip-пагінація ($top=500, $skip=0,500,…): надійна для сутностей ≤~3000
    # рядків. Keyset за Ref_Key НЕ працює — 1С ігнорує $orderby, тож курсор
    # `Ref_Key gt` тихо обриває на першій сторінці (silent truncation).
    # Для сутностей >~3000 (глибокий $skip таймаутить через apex_web_service)
    # — окремий партиційний завантажувач за префіксом Code (див.
    # stage-kontragenty-by-code.sql). Перевіряй staged-count проти OData $count.
    return f"""\
-- {entity_ref}
declare
    l_clob clob; l_got number; l_skip number := 0;
begin
    loop
        l_clob := apex_web_service.make_rest_request(
            p_url => '{BASE}/{entity_odata}?$format=json&$top=500&$skip=' || l_skip,
            p_http_method => 'GET', p_credential_static_id => 'BAS_DOC_CRED',
            p_transfer_timeout => 120);
        select count(*) into l_got
          from json_table(l_clob, '$.value[*]' columns (rk varchar2(36) path '$.Ref_Key'));
        exit when l_got = 0;
        merge into rsd_odata_raw t using (
            select rk, dc from json_table(l_clob, '$.value[*]' columns (
                rk varchar2(36) path '$.Ref_Key',
                dc clob format json path '$'))
        ) s on (t.entity = '{entity_ref}' and t.ref_key = s.rk)
        when matched then update set t.doc = s.dc, t.loaded_at = systimestamp
        when not matched then insert (entity, ref_key, doc) values ('{entity_ref}', s.rk, s.dc);
        commit;
        l_skip := l_skip + 500;
        exit when l_got < 500;   -- остання (неповна) сторінка
    end loop;
    dbms_output.put_line('{entity_ref}: staged ' || l_skip);
end;
/
"""


def project_block(table, fm):
    fields = fm["fields"]
    sel = ",\n        ".join(f"{proj_expr(f)} as {f['col']}" for f in fields)
    cols = [f["col"] for f in fields]
    upd = ",\n        ".join(f"t.{c} = s.{c}" for c in cols if c != "LEGACY_REF")
    ins_cols = ", ".join(cols)
    ins_vals = ", ".join(f"s.{c}" for c in cols)
    return f"""\
-- {fm['entity']} → {table}
merge into {table} t using (
    select
        {sel}
    from rsd_odata_raw where entity = '{fm['entity']}'
) s on (t.legacy_ref = s.LEGACY_REF)
when matched then update set
        {upd}
when not matched then insert ({ins_cols})
    values ({ins_vals});
commit;
"""


def main():
    global BASE
    ap = argparse.ArgumentParser()
    ap.add_argument("--field-map", type=Path, required=True)
    ap.add_argument("--tables", required=True)
    ap.add_argument("--base", required=True)
    ap.add_argument("--out-dir", type=Path, required=True)
    args = ap.parse_args()
    BASE = args.base.rstrip("/")
    fmap = json.loads(args.field_map.read_text(encoding="utf-8"))
    tables = [t.strip() for t in args.tables.split(",") if t.strip()]
    args.out_dir.mkdir(parents=True, exist_ok=True)

    stage = ["-- Батч 004: stage сирих даних НСІ у RSD_ODATA_RAW. NLS_LANG=.AL32UTF8.",
             "-- Потрібен контекст APEX-сесії (Web Credential BAS_DOC_CRED):",
             "exec apex_session.create_session(p_app_id=>200, p_page_id=>1, p_username=>'CLAUDE');",
             "set serveroutput on", ""]
    project = ["-- Батч 004: типізована проекція RAW → RSD_*. Запускати ДВІЧІ (цикли).",
               "-- NLS_LANG=.AL32UTF8.", "set define off", ""]
    for t in tables:
        if t not in fmap:
            print(f"! {t} відсутній у field-map — пропущено"); continue
        entity_ref = fmap[t]["entity"]                 # Catalog.Контрагенты
        name = entity_ref.split(".", 1)[1]
        stage.append(stage_block(enc(name), entity_ref))
        project.append(project_block(t, fmap[t]))

    (args.out_dir / "raw-ddl.sql").write_text(RAW_DDL, encoding="utf-8")
    (args.out_dir / "stage.sql").write_text("\n".join(stage), encoding="utf-8")
    (args.out_dir / "project.sql").write_text("\n".join(project), encoding="utf-8")
    print(f"{args.out_dir}: {len(tables)} завантажувачів (raw-ddl + stage + project ×2)")


if __name__ == "__main__":
    main()
