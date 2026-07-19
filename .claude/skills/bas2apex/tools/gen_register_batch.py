#!/usr/bin/env python3
"""gen_register_batch.py — детермінований генератор батча регістрів відомостей.

Кодує правила маппінгу InformationRegister механічно (аналог gen_catalog_batch):

- Стандартні поля регістра синтезуються з `properties` (їх немає у складі
  реквізитів, як Ссылка/Код у довідників):
    ID              — сурогатний PK (регістр не має одноколоночного ключа);
    VALID_FROM      — «Період», якщо періодичний (Second→TIMESTAMP, Day/…→DATE);
    RECORDER_TYPE/RECORDER_ID/LINE_NO/IS_ACTIVE — якщо WriteMode=RecorderSubordinate
                      (регістратор поліморфний → §9);
    CREATED_*/UPDATED_* — аудит (конвенція APEX).
- Виміри (dimensions) → колонки + складений UNIQUE-ключ (виміри[,VALID_FROM]);
  для підпорядкованого — ключ (RECORDER_*,LINE_NO). Нетипізований/композитний
  вимір НЕ прибирається (він частина ідентичності) → REF_TYPE/REF_ID у ключі, §9.
- Ресурси (resources) і реквізити (attributes) → колонки; нетипізовані — §9, drop.
- Періодичні незалежні регістри → VIEW зрізу останніх (срез последних):
  ROW_NUMBER() OVER (PARTITION BY dims ORDER BY VALID_FROM DESC)=1. Це і є
  «питання підсумків» — дефолт, підтверджує архітектор (§9 + totals).
- Типи/транслітерація/FK/композит — з gen_catalog_batch. FK ставляться ЛИШЕ на
  наявні таблиці стенду (--existing-tables); решта — відкладені (EXTERNAL).

Використання:
  python3 gen_register_batch.py --source <dump> --waves 2,3,4 --out-dir migration/NNN-... \
      [--existing-tables existing.txt] [--only Ref1,Ref2] [--exclude Ref3,...]
"""
from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import extract_cluster as ec  # noqa: E402
import build_migration_map as bm  # noqa: E402
import gen_catalog_batch as gc  # noqa: E402

translit = gc.translit
table_name = gc.table_name
oracle_type = gc.oracle_type
uniq = gc.uniq
label_of = gc.label_of
q = gc.q

AUDIT = [
    ("CREATED_AT", "TIMESTAMP DEFAULT SYSTIMESTAMP", "NOT NULL", "Аудит: створено"),
    ("CREATED_BY", "VARCHAR2(255 CHAR) DEFAULT NVL(SYS_CONTEXT('APEX$SESSION','APP_USER'),USER)", "NOT NULL", "Аудит: створив"),
    ("UPDATED_AT", "TIMESTAMP DEFAULT SYSTIMESTAMP", "NOT NULL", "Аудит: змінено"),
    ("UPDATED_BY", "VARCHAR2(255 CHAR) DEFAULT NVL(SYS_CONTEXT('APEX$SESSION','APP_USER'),USER)", "NOT NULL", "Аудит: змінив"),
]


def period_type(periodicity):
    """1С InformationRegisterPeriodicity → тип колонки Період (None = непер.)."""
    if periodicity in (None, "Nonperiodical", "RecorderPosition"):
        return None
    return "TIMESTAMP" if periodicity == "Second" else "DATE"  # Day/Month/Quarter/Year


def comment_with(label, note):
    return label + (" — " + note if note else "")


class RegGen:
    def __init__(self, existing):
        self.existing = existing          # set: наявні таблиці стенду (цілі FK)
        self.glossary = []                # (ru, en, uk, kind)
        self.open_q = []                  # рядки §9
        self.totals = []                  # (view, table) — рішення про зріз останніх
        self.stats = {"registers": 0, "cols": 0, "fk": 0, "fk_deferred": 0,
                      "composite": 0, "untyped_dim": 0, "untyped_res": 0,
                      "periodic": 0, "subordinate": 0, "zero_dim": 0, "views": 0}
        self.tables = []                  # dict per table
        self.fks = []                     # (table, col, target)
        self.field_map = {}

    def emit(self, table, used, attr, role, keycols, fmap_fields):
        """Ознака регістра → список 4-кортежів (col, type, nn, comment).
        role: dimension|resource|attribute. Для виміру додає імена колонок у keycols."""
        otype, kind, target = oracle_type(attr)
        cname = uniq(translit(attr["name"]), used)
        self.glossary.append((attr["name"], cname, label_of(attr), role))
        is_dim = (role == "dimension")
        lbl = label_of(attr)

        if kind == "untyped":
            if is_dim:  # вимір не прибираємо — поліморфний ключ
                self.stats["untyped_dim"] += 1
                self.stats["cols"] += 2
                tcol = uniq(cname + "_REF_TYPE", used)
                icol = uniq(cname + "_REF_ID", used)
                keycols.extend([tcol, icol])
                self.open_q.append(f"- {table}.{cname} ({attr['name']}) — нетипізований ВИМІР "
                                   f"(поліморфний, у ключі): {tcol}/{icol}, без FK → рішення архітектора")
                fmap_fields.append({"odata": attr["name"] + "_Key", "col": icol, "kind": "poly-dim"})
                return [(tcol, "VARCHAR2(60 CHAR)", None, comment_with(lbl, "тип (поліморфний вимір)")),
                        (icol, "NUMBER", None, comment_with(lbl, "id (поліморфний вимір)"))]
            self.stats["untyped_res"] += 1
            self.open_q.append(f"- {table}.{cname} ({attr['name']}) — нетипізований {role}, колонку не створено")
            return None

        if kind == "composite":
            self.stats["composite"] += 1
            self.stats["cols"] += 2
            tcol = uniq(cname + "_REF_TYPE", used)
            icol = uniq(cname + "_REF_ID", used)
            if is_dim:
                keycols.extend([tcol, icol])
            self.open_q.append(f"- {table}.{cname} ({attr['name']}) — композитний {role}: {tcol}/{icol}, без FK")
            return [(tcol, "VARCHAR2(60 CHAR)", None, comment_with(lbl, "тип (композит)")),
                    (icol, "NUMBER", None, comment_with(lbl, "id (композит)"))]

        self.stats["cols"] += 1
        note = "обовʼязкове (FillChecking, enforce в APEX)" if attr.get("fill_checking") == "ShowError" else ""
        fm = {"odata": attr["name"], "col": cname, "kind": kind, "role": role, "otype": otype}
        if kind in ("ref", "enum", "ref-ext"):
            if not cname.endswith("_ID"):
                cname = uniq(re.sub(r'_ID$', '', cname) + "_ID", used)
            fm["col"] = cname
            if kind == "enum":
                self.fks.append((table, cname, "RSD_ENUMS")); self.stats["fk"] += 1
                fm["enum_type"] = target.split(".", 1)[1] if target else None
            else:
                tgt = table_name(target) if target else None
                if tgt and tgt in self.existing:
                    self.fks.append((table, cname, tgt)); self.stats["fk"] += 1
                    fm["odata"] = attr["name"] + "_Key"; fm["target"] = tgt
                else:
                    self.stats["fk_deferred"] += 1
                    note = (note + "; " if note else "") + f"FK deferred: {target} (немає на стенді/EXTERNAL)"
                    fm["odata"] = attr["name"] + "_Key"; fm["target"] = None
        fmap_fields.append(fm)
        if is_dim:
            keycols.append(cname)
        return [(cname, otype, None, comment_with(lbl, note))]

    def register(self, ref, obj):
        tbl = table_name(ref)
        props = obj.get("properties", {})
        periodicity = props.get("InformationRegisterPeriodicity")
        subordinate = (props.get("WriteMode") == "RecorderSubordinate")
        self.glossary.append((obj["name"], tbl, label_of(obj), "InformationRegister"))
        self.stats["registers"] += 1

        used = {"ID"}
        cols = [("ID", "NUMBER GENERATED ALWAYS AS IDENTITY", None, "Сурогатний ключ")]
        keycols = []
        fmap_fields = []
        vfrom = None

        if subordinate:
            self.stats["subordinate"] += 1; self.stats["cols"] += 4
            for c, ct, nn, lbl in [("RECORDER_TYPE", "VARCHAR2(60 CHAR)", "NOT NULL", "Регистратор (тип)"),
                                   ("RECORDER_ID", "NUMBER", "NOT NULL", "Регистратор (id)"),
                                   ("LINE_NO", "NUMBER", "NOT NULL", "Номер рядка"),
                                   ("IS_ACTIVE", "BOOLEAN DEFAULT TRUE", None, "Активність")]:
                cols.append((c, ct, nn, lbl)); used.add(c)
            self.open_q.append(f"- {tbl}: RecorderSubordinate — RECORDER_TYPE/RECORDER_ID поліморфний "
                               f"(регістратор = документ будь-якого типу), ключ (RECORDER_*,LINE_NO) → §9")

        pt = period_type(periodicity)
        if pt and not subordinate:
            vfrom = "VALID_FROM"; self.stats["cols"] += 1; self.stats["periodic"] += 1
            cols.append(("VALID_FROM", pt, "NOT NULL", f"Період (1С {periodicity})"))
            used.add("VALID_FROM")

        for d in obj.get("dimensions", []):
            got = self.emit(tbl, used, d, "dimension", keycols, fmap_fields)
            if got:
                cols.extend(got)
        for r in obj.get("resources", []):
            got = self.emit(tbl, used, r, "resource", keycols, fmap_fields)
            if got:
                cols.extend(got)
        for a in obj.get("attributes", []):
            got = self.emit(tbl, used, a, "attribute", keycols, fmap_fields)
            if got:
                cols.extend(got)

        cols.extend(AUDIT)

        # ключ + періодичність
        if subordinate:
            uk = ["RECORDER_TYPE", "RECORDER_ID", "LINE_NO"]
        else:
            uk = list(keycols) + ([vfrom] if vfrom else [])
        if not keycols and not subordinate:
            self.stats["zero_dim"] += 1
            self.open_q.append(f"- {tbl}: 0 вимірів — природного ключа немає, лише ID (PK); "
                               f"унікальність рядків → §9")
            uk = []

        view = None
        if vfrom and keycols:  # зріз останніх лише для періодичних незалежних з вимірами
            view = tbl + "_SREZ_V"
            self.stats["views"] += 1
            self.totals.append((view, tbl))
            self.open_q.append(f"- {tbl}: періодичний ({periodicity}) → VIEW {view} (зріз останніх, "
                               f"срез последних: PARTITION BY {','.join(keycols)} ORDER BY VALID_FROM DESC). "
                               f"«Питання підсумків»: view (дефолт) / матеріалізована таблиця / без зрізу → архітектор")

        self.field_map[tbl] = {"entity": ref, "periodic": bool(vfrom), "subordinate": subordinate,
                               "key": uk, "fields": fmap_fields}
        self.tables.append({"name": tbl, "cols": cols, "pk": "ID", "uk": uk,
                            "label": label_of(obj), "ref": ref, "keycols": keycols,
                            "vfrom": vfrom, "view": view})


def render_ddl(g, waves):
    L = [f"-- Батч регістрів відомостей (хвилі {waves}). Транслітеровані імена; підписи uk у COMMENT.",
         "-- NLS_LANG=.AL32UTF8. Повторюваний. FK/VIEW — окремими секціями після CREATE усіх таблиць.",
         "-- Стандартні поля синтезовані: ID(PK), VALID_FROM(період), RECORDER_*/LINE_NO(підпорядк.), аудит.",
         ""]
    for t in reversed(g.tables):
        L.append(f"DROP TABLE IF EXISTS {t['name']} CASCADE CONSTRAINTS;")
    L.append("")
    for t in g.tables:
        L.append(f"-- {t['ref']} — {t['label']}")
        L.append(f"CREATE TABLE {t['name']} (")
        body = []
        for c in t["cols"]:
            cn, ct, nn = c[0], c[1], c[2]
            body.append(f"    {cn} {ct}" + (f" {nn}" if nn else ""))
        body.append(f"    CONSTRAINT {t['name'][:110]}_PK PRIMARY KEY ({t['pk']})")
        if t["uk"]:
            body.append(f"    CONSTRAINT {(t['name'][:112])}_UK UNIQUE ({', '.join(t['uk'])})")
        L.append(",\n".join(body))
        L.append(");")
        L.append(f"COMMENT ON TABLE {t['name']} IS {q(t['label'])};")
        for c in t["cols"]:
            if len(c) >= 4 and c[3]:
                L.append(f"COMMENT ON COLUMN {t['name']}.{c[0]} IS {q(c[3])};")
        L.append("")
    L.append("-- ===== Зовнішні ключі (усі таблиці вже створені) =====")
    for tbl, col, target in g.fks:
        cn = (f"{tbl}_FK_{col}")[:120]
        L.append(f"ALTER TABLE {tbl} ADD CONSTRAINT {cn} FOREIGN KEY ({col}) REFERENCES {target} (ID);")
    views = [t for t in g.tables if t["view"]]
    if views:
        L.append("")
        L.append("-- ===== Зрізи останніх (срез последних) для періодичних регістрів =====")
        for t in views:
            collist = ", ".join(c[0] for c in t["cols"])
            part = ", ".join(t["keycols"])
            L.append(f"CREATE OR REPLACE VIEW {t['view']} AS")
            L.append(f"SELECT {collist} FROM (")
            L.append(f"  SELECT t.*, ROW_NUMBER() OVER (PARTITION BY {part} ORDER BY {t['vfrom']} DESC) AS RN")
            L.append(f"  FROM {t['name']} t")
            L.append(f") WHERE RN = 1;")
            L.append(f"COMMENT ON TABLE {t['view']} IS {q('Зріз останніх: ' + t['label'])};")
    return "\n".join(L) + "\n"


def render_readme(g, waves, only, excluded):
    s = g.stats
    return f"""\
# Батч регістрів відомостей — хвилі {waves}

Механічно згенеровано `bas2apex/tools/gen_register_batch.py` — не редагувати руками.
Імена таблиць/колонок транслітеровані (латиниця), підписи (uk) — у COMMENT.
{("Пілот (--only): " + only) if only else ""}
Виключені: {', '.join(sorted(excluded)) or '—'}.

## Підсумок
- Регістрів (таблиць): **{s['registers']}**; колонок: {s['cols']}
- Періодичних (VALID_FROM): {s['periodic']}; зрізів останніх (VIEW): {s['views']}
- Підпорядкованих регістратору: {s['subordinate']}; без вимірів: {s['zero_dim']}
- FK встановлено: {s['fk']}; відкладено (EXTERNAL/немає на стенді): {s['fk_deferred']}
- Композитних ознак: {s['composite']}; нетипізованих вимірів (поліморфний ключ): {s['untyped_dim']}; нетипізованих ресурсів (drop): {s['untyped_res']}

## §9 — на ревю архітектора
{chr(10).join(g.open_q) if g.open_q else '- (порожньо)'}

## Встановлення
`ddl.sql` → стенд (NLS_LANG=.AL32UTF8). EnumRef→RSD_ENUMS. FK лише на наявні таблиці;
відкладені ставляться після міграції відповідних довідників/документів.
"""


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--source", type=Path, required=True)
    ap.add_argument("--waves", default="2,3,4")
    ap.add_argument("--only", default="")          # пілот: явний список Тип.Имя
    ap.add_argument("--exclude", default="")
    ap.add_argument("--existing-tables", type=Path, default=None)
    ap.add_argument("--out-dir", type=Path, required=True)
    args = ap.parse_args()
    excluded = {e.strip() for e in args.exclude.split(",") if e.strip()}
    only = [o.strip() for o in args.only.split(",") if o.strip()]
    args.out_dir.mkdir(parents=True, exist_ok=True)

    existing = set()
    if args.existing_tables and args.existing_tables.exists():
        existing = {ln.strip().upper() for ln in args.existing_tables.read_text().splitlines() if ln.strip()}
    existing.add("RSD_ENUMS")

    if only:
        refs = only
    else:
        objs = bm.scan(args.source)
        sccs = bm.tarjan_scc(objs)
        bm.waves_of(objs, sccs)
        waves = {int(w) for w in args.waves.split(",")}
        refs = [o["ref"] for o in objs.values()
                if o["type"] == "InformationRegister" and o["wave"] in waves and o["ref"] not in excluded]

    g = RegGen(existing)
    for ref in sorted(refs):
        parsed = ec.parse_object(args.source, ref)
        if parsed:
            g.register(ref, parsed[0])

    (args.out_dir / "ddl.sql").write_text(render_ddl(g, args.waves), encoding="utf-8")
    (args.out_dir / "README.md").write_text(render_readme(g, args.waves, args.only, excluded), encoding="utf-8")
    seen, rows = set(), []
    for ru, en, uk, kind in g.glossary:
        if (ru, en) not in seen:
            seen.add((ru, en)); rows.append(f"| {ru} | {en} | {uk} | {kind} |")
    (args.out_dir / "glossary-rows.md").write_text("\n".join(rows) + "\n", encoding="utf-8")
    (args.out_dir / "field-map.json").write_text(
        json.dumps(g.field_map, ensure_ascii=False, indent=1), encoding="utf-8")
    (args.out_dir / "stats.json").write_text(json.dumps(g.stats, ensure_ascii=False, indent=1), encoding="utf-8")
    print(f"{args.out_dir}: {g.stats['registers']} регістрів, {g.stats['cols']} колонок, "
          f"періодичних {g.stats['periodic']} (view {g.stats['views']}), підпорядк {g.stats['subordinate']}, "
          f"FK {g.stats['fk']}(+{g.stats['fk_deferred']} відкл.), "
          f"untyped-dim {g.stats['untyped_dim']}, composite {g.stats['composite']}")


if __name__ == "__main__":
    main()
