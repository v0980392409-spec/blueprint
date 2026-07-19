#!/usr/bin/env python3
"""gen_document_batch.py — детермінований генератор батча документів (Document).

Document → таблиця-транзакція: ID(PK)/LEGACY_REF/DOC_NO/DOC_DATE/IS_POSTED(якщо
Posting=Allow)/IS_DELETED + аудит; реквізити → колонки; табличні частини →
дочірні таблиці `<DOC>_<SECTION>` (OWNER_ID FK + LINE_NO, unique(OWNER_ID,LINE_NO)).

Переиспользує gen_catalog_batch (col/tab_section/типи/translit/FK/render). FK
лише на наявні таблиці стенду (--existing-tables); решта — відкладені. Scope
унікальності номера (NumberPeriodicity), композитні/нетипізовані реквізити й
обробники BSL → §9. Master-Detail сторінки — етап blueprint, не тут.

Використання:
  python3 gen_document_batch.py --source <dump> [--only Document.X,...] \
      [--existing-tables existing.txt] --out-dir migration/NNN-documents
"""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import extract_cluster as ec  # noqa: E402
import build_migration_map as bm  # noqa: E402
import gen_catalog_batch as gc  # noqa: E402

AUDIT = [
    ("IS_DELETED", "BOOLEAN DEFAULT FALSE", "NOT NULL", "Мʼяке видалення", ""),
    ("CREATED_AT", "TIMESTAMP DEFAULT SYSTIMESTAMP", "NOT NULL", "Аудит: створено", ""),
    ("CREATED_BY", "VARCHAR2(255 CHAR) DEFAULT NVL(SYS_CONTEXT('APEX$SESSION','APP_USER'),USER)", "NOT NULL", "Аудит: створив", ""),
    ("UPDATED_AT", "TIMESTAMP DEFAULT SYSTIMESTAMP", "NOT NULL", "Аудит: змінено", ""),
    ("UPDATED_BY", "VARCHAR2(255 CHAR) DEFAULT NVL(SYS_CONTEXT('APEX$SESSION','APP_USER'),USER)", "NOT NULL", "Аудит: змінив", ""),
]


class DocGen(gc.Gen):
    def tab_section(self, parent_tbl, ts):
        # Як gc.Gen.tab_section, але реєструє field-map ТЧ під parent["sections"]
        # (odata-ім'я секції, дочірня таблиця, поля) — щоб loader проектував ТЧ.
        tname = gc.uniq((parent_tbl + "_" + gc.translit(ts["name"]))[:120], set())
        used = {"ID", "OWNER_ID", "LINE_NO"}
        cols = [("ID", "NUMBER GENERATED ALWAYS AS IDENTITY", None, "Ключ", ""),
                ("OWNER_ID", "NUMBER", "NOT NULL", "Власник ТЧ", ""),
                ("LINE_NO", "NUMBER", "NOT NULL", "Номер рядка", "")]
        sec_fields = []
        self.field_map.setdefault(parent_tbl, {"fields": []}).setdefault("sections", []).append(
            {"odata": ts["name"], "table": tname, "fields": sec_fields})
        self.field_map[tname] = {"entity": None, "fields": sec_fields}  # col() дописує сюди
        for attr in ts.get("attributes", []):
            got = self.col(tname, used, None, attr)
            if got:
                cols.extend(got)
        del self.field_map[tname]  # field-map ТЧ живе лише під parent["sections"]
        self.tables.append((tname, cols, "ID", [], [], gc.label_of(ts) + " (ТЧ)", None))
        self.fks.append((tname, "OWNER_ID", parent_tbl)); self.stats["fk"] += 1
        self.stats["child"] += 1
        self.stats["tables"] += 1

    def document(self, ref, obj):
        tbl = gc.table_name(ref)
        self.glossary.append((obj["name"], tbl, gc.label_of(obj), "Document"))
        props = obj.get("properties", {})
        posting = props.get("Posting") == "Allow"
        num_len = props.get("NumberLength")

        fmap = [{"odata": "Ref_Key", "col": "LEGACY_REF", "kind": "legacy"},
                {"odata": "DeletionMark", "col": "IS_DELETED", "kind": "bool"},
                {"odata": "Date", "col": "DOC_DATE", "kind": "scalar", "otype": "TIMESTAMP"}]
        if num_len:
            fmap.append({"odata": "Number", "col": "DOC_NO", "kind": "scalar"})
        if posting:
            fmap.append({"odata": "Posted", "col": "IS_POSTED", "kind": "bool"})
        self.field_map[tbl] = {"entity": ref, "fields": fmap}

        used = {"ID", "LEGACY_REF", "DOC_DATE", "DOC_NO", "IS_POSTED", "IS_DELETED"}
        cols = [("ID", "NUMBER GENERATED ALWAYS AS IDENTITY", None, "Сурогатний ключ", ""),
                ("LEGACY_REF", "VARCHAR2(36)", "NOT NULL", "UUID 1С — звірка", ""),
                # DOC_DATE — стандартна дата документа (завжди)
                ("DOC_DATE", "TIMESTAMP", None, "Дата документа", "")]
        uks = ["LEGACY_REF"]
        # DOC_NO nullable + без UNIQUE: реальні номери можуть повторюватись між
        # періодами/організаціями; scope унікальності — рішення архітектора (§9).
        if num_len:
            cols.append(("DOC_NO", f"VARCHAR2({num_len} CHAR)", None, "Номер документа", ""))
            self.open_q.append(f"- {tbl}.DOC_NO — scope унікальності номера "
                               f"(NumberPeriodicity={props.get('NumberPeriodicity')}) → рішення архітектора")
        if posting:
            cols.append(("IS_POSTED", "BOOLEAN DEFAULT FALSE", None, "Проведено", ""))

        for attr in obj.get("attributes", []):
            got = self.col(tbl, used, None, attr)
            if got:
                cols.extend(got)
        cols += AUDIT
        self.tables.append((tbl, cols, "ID", uks, [], gc.label_of(obj), ref))
        self.stats["tables"] += 1

        for ts in obj.get("tabular_sections", []):
            self.tab_section(tbl, ts)
        if obj.get("module_handlers"):
            self.open_q.append(f"- {tbl}: обробники BSL — " + ", ".join(obj["module_handlers"]))


def render_readme(g, only):
    s = g.stats
    return f"""\
# Батч документів — Document → таблиці-транзакції + ТЧ

Механічно згенеровано `bas2apex/tools/gen_document_batch.py` — не редагувати руками.
Стандартні поля: ID(PK)/LEGACY_REF/DOC_NO/DOC_DATE/IS_POSTED/IS_DELETED + аудит.
ТЧ → дочірні `<DOC>_<SECTION>` (OWNER_ID FK + LINE_NO). {("Обрано (--only): " + only) if only else "Усі документи дампу."}

## Підсумок
- Таблиць: **{s['tables']}** (з них дочірніх ТЧ: {s['child']})
- Колонок: {s['cols']}; FK встановлено {s['fk']}, відкладено {s['fk_deferred']}
- Композитних реквізитів: {s['composite']}; нетипізованих: {s['untyped']}

## §9 — на ревю архітектора
{chr(10).join(g.open_q) if g.open_q else '- (порожньо)'}

## Далі
`ddl.sql` → стенд (NLS_LANG=.AL32UTF8). Master-Detail сторінки (шапка + IG на ТЧ)
— етап blueprint (fr.md + schema-metadata.md). Дані — з OData (документи + вкладені ТЧ).
"""


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--source", type=Path, required=True)
    ap.add_argument("--only", default="")
    ap.add_argument("--existing-tables", type=Path, default=None)
    ap.add_argument("--out-dir", type=Path, required=True)
    args = ap.parse_args()
    args.out_dir.mkdir(parents=True, exist_ok=True)

    existing = set()
    if args.existing_tables and args.existing_tables.exists():
        existing = {ln.strip().upper() for ln in args.existing_tables.read_text().splitlines() if ln.strip()}

    objs = bm.scan(args.source)
    refs = ([r.strip() for r in args.only.split(",") if r.strip()] if args.only
            else sorted(o["ref"] for o in objs.values() if o["type"] == "Document"))

    # in_batch: мігровані довідники (за наявністю таблиці) + документи цього батча
    in_batch = dict(gc.GLOSSARY_TABLES)
    for o in objs.values():
        if o["type"] == "Catalog":
            tn = gc.table_name(o["ref"])
            if tn in existing:
                in_batch[o["ref"]] = tn
    for r in refs:
        in_batch[r] = gc.table_name(r)

    g = DocGen(args.source, in_batch)
    for ref in sorted(refs):
        parsed = ec.parse_object(args.source, ref)
        if parsed:
            g.document(ref, parsed[0])

    ddl = gc.render_ddl(g).replace(
        "-- Батч 003: довідники НСІ (хвилі 2–4). Транслітеровані імена; підписи uk у COMMENT.",
        "-- Батч документів (Document → таблиця-транзакція + ТЧ). Транслітеровані імена; підписи uk у COMMENT.", 1)
    (args.out_dir / "ddl.sql").write_text(ddl, encoding="utf-8")
    (args.out_dir / "README.md").write_text(render_readme(g, args.only), encoding="utf-8")
    seen, rows = set(), []
    for ru, en, uk, kind in g.glossary:
        if (ru, en) not in seen:
            seen.add((ru, en)); rows.append(f"| {ru} | {en} | {uk} | {kind} |")
    (args.out_dir / "glossary-rows.md").write_text("\n".join(rows) + "\n", encoding="utf-8")
    (args.out_dir / "field-map.json").write_text(json.dumps(g.field_map, ensure_ascii=False, indent=1), encoding="utf-8")
    (args.out_dir / "stats.json").write_text(json.dumps(g.stats, ensure_ascii=False, indent=1), encoding="utf-8")
    print(f"{args.out_dir}: {g.stats['tables']} таблиць (ТЧ {g.stats['child']}), {g.stats['cols']} колонок, "
          f"FK {g.stats['fk']}(+{g.stats['fk_deferred']} відкл.), composite {g.stats['composite']}, untyped {g.stats['untyped']}")


if __name__ == "__main__":
    main()
