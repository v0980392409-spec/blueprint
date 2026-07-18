#!/usr/bin/env python3
"""
gen_reconcile.py — генератор reconcile-проходу крос-FK за field-map.

Проекція (project.sql) резолвить посилання inline під час MERGE, але за
порядком завантаження частина цілей могла зʼявитися пізніше → відповідні FK
лишились NULL. Цей один UPDATE-прохід добиває всі посилальні колонки
завантажених таблиць: для кожної ref-колонки, чия ціль теж завантажена,
UPDATE ... = (id цілі за LEGACY_REF = <Поле>_Key з RAW). Заповнює лише NULL
(ідемпотентно, дешево). За взірцем reconcile-organizations-refs.sql.

Використання:
  python3 gen_reconcile.py --field-map migration/003-.../field-map.json \
      --tables RSD_KONTRAGENTY,RSD_POLZOVATELI,... --out reconcile-refs.sql
"""
from __future__ import annotations

import argparse
import json
from pathlib import Path

EMPTY_UUID = "00000000-0000-0000-0000-000000000000"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--field-map", type=Path, required=True)
    ap.add_argument("--tables", required=True)
    ap.add_argument("--out", type=Path, required=True)
    args = ap.parse_args()
    fmap = json.loads(args.field_map.read_text(encoding="utf-8"))
    loaded = {t.strip() for t in args.tables.split(",") if t.strip()}

    out = [
        "-- Батч 004: reconcile крос-FK (добивання посилань після повного",
        "-- завантаження). Резолвить <Поле>_Key (UUID з RAW) → локальний ID цілі за",
        "-- LEGACY_REF. Лише для завантажених цілей; заповнює NULL. Ідемпотентний.",
        "-- NLS_LANG=.AL32UTF8.",
        "set serveroutput on",
    ]
    n = 0
    for tbl in sorted(loaded):
        if tbl not in fmap:
            continue
        entity = fmap[tbl]["entity"]
        for f in fmap[tbl]["fields"]:
            if f["kind"] not in ("ref", "ref-ext"):
                continue
            target = f.get("target")
            if not target or target not in loaded:
                continue  # ціль не завантажена → лишається NULL
            col, od = f["col"], f["odata"]
            out.append(f"""
begin
    update {tbl} t set t.{col} = (
        select tgt.id from rsd_odata_raw r join {target} tgt
            on tgt.legacy_ref = nullif(json_value(r.doc, '$."{od}"'), '{EMPTY_UUID}')
        where r.entity = '{entity}' and r.ref_key = t.legacy_ref)
    where t.{col} is null
      and exists (select 1 from rsd_odata_raw r join {target} tgt
            on tgt.legacy_ref = nullif(json_value(r.doc, '$."{od}"'), '{EMPTY_UUID}')
          where r.entity = '{entity}' and r.ref_key = t.legacy_ref);
    dbms_output.put_line('{tbl}.{col} -> {target}: ' || sql%rowcount || ' filled');
    commit;
end;
/""")
            n += 1
    out.append("\ncommit;")
    args.out.write_text("\n".join(out) + "\n", encoding="utf-8")
    print(f"{args.out}: {n} reconcile UPDATE(s)")


if __name__ == "__main__":
    main()
