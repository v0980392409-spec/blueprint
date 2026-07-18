#!/usr/bin/env python3
"""
gen_catalog_batch.py — детермінований генератор батча довідників (НСІ).

Кодує правила маппінгу skill механічно для набору довідників: стандартні
реквізити (ID/LEGACY_REF/CODE/NAME/IS_DELETED/аудит, PARENT_ID для ієрархії,
OWNER_ID для підпорядкованих), реквізити за типами, посилання (CatalogRef→FK,
EnumRef→RSD_ENUMS, композитні≥2 типів→REF_TYPE/REF_ID §9, нетипізовані→§9),
табличні частини→дочірні таблиці з LINE_NO. Імена таблиць/колонок —
транслітерація (латиниця), підписи — uk-синоніми з XML. FK виносяться в
окрему секцію ALTER після CREATE усіх таблиць — знімає проблему циклів і
порядку. Посилання на цілі поза батчем — відкладені (коментар EXTERNAL).

Використання:
  python3 gen_catalog_batch.py --source <dump> --waves 2,3,4 --out-dir migration/003-... \
      [--exclude Catalog.Организации,Catalog.RSD_Дома,Catalog.RSD_Секции]
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

# Кирилиця (ru+uk) → латиниця
TRANSLIT = {
    'а': 'a', 'б': 'b', 'в': 'v', 'г': 'g', 'д': 'd', 'е': 'e', 'ё': 'e',
    'ж': 'zh', 'з': 'z', 'и': 'i', 'й': 'y', 'к': 'k', 'л': 'l', 'м': 'm',
    'н': 'n', 'о': 'o', 'п': 'p', 'р': 'r', 'с': 's', 'т': 't', 'у': 'u',
    'ф': 'f', 'х': 'kh', 'ц': 'ts', 'ч': 'ch', 'ш': 'sh', 'щ': 'shch',
    'ъ': '', 'ы': 'y', 'ь': '', 'э': 'e', 'ю': 'yu', 'я': 'ya',
    'і': 'i', 'ї': 'yi', 'є': 'ye', 'ґ': 'g',
}

# Довідники, уже мігровані (батч 001) — не створювати, лише резолвити посилання
GLOSSARY_TABLES = {
    "Catalog.Организации": "RSD_ORGANIZATIONS",
    "Catalog.RSD_Дома": "RSD_HOUSES",
    "Catalog.RSD_Секции": "RSD_HOUSE_SECTIONS",
}

STD = {  # стандартні реквізити 1С → фіксовані англ. колонки
    "code": "CODE", "name": "NAME", "legacy": "LEGACY_REF",
    "deleted": "IS_DELETED", "parent": "PARENT_ID", "owner": "OWNER_ID",
}


def translit(s: str) -> str:
    out = []
    for ch in s:
        low = ch.lower()
        if low in TRANSLIT:
            t = TRANSLIT[low]
            out.append(t.upper() if ch.isupper() or ch == low else t.upper())
        elif ch.isalnum() and ord(ch) < 128:
            out.append(ch.upper())
        else:
            out.append('_')
    r = re.sub(r'_+', '_', ''.join(out)).strip('_')
    if r and r[0].isdigit():
        r = 'X_' + r
    return r or 'X'


def table_name(ref: str) -> str:
    if ref in GLOSSARY_TABLES:
        return GLOSSARY_TABLES[ref]
    name = ref.split('.', 1)[1]
    name = name[4:] if name.startswith('RSD_') else name
    return ('RSD_' + translit(name))[:120]


def q(s):
    return "'" + (s or "").replace("'", "''") + "'"


def oracle_type(attr):
    """Реквізит → (oracle_type, kind, ref_target). kind: scalar|ref|enum|composite|untyped."""
    types = attr.get("types", [])
    quals = attr.get("qualifiers", {})
    if not types:
        return None, "untyped", None
    refs = attr.get("refs", [])
    if len(types) > 1 or len(refs) > 1:
        return None, "composite", None
    t = types[0]
    if t.endswith("Ref." + t.split(".", 1)[-1]) or "Ref." in t:
        r = refs[0] if refs else None
        if r and r.startswith("Enum."):
            return "NUMBER", "enum", r
        if r and r.startswith("Catalog."):
            return "NUMBER", "ref", r
        return "NUMBER", "ref-ext", r  # DocumentRef/CCTRef etc → deferred
    # скаляр
    if t == "string":
        n = quals.get("Length", 0)
        return (f"VARCHAR2({n} CHAR)" if n else "CLOB"), "scalar", None
    if t == "decimal":
        d, f = quals.get("Digits"), quals.get("FractionDigits")
        if d and f:
            return f"NUMBER({d},{f})", "scalar", None
        return (f"NUMBER({d})" if d else "NUMBER"), "scalar", None
    if t == "dateTime":
        return ("DATE" if quals.get("DateFractions") == "Date" else "TIMESTAMP"), "scalar", None
    if t == "boolean":
        return "BOOLEAN", "scalar", None
    if t == "UUID":
        return "VARCHAR2(36)", "scalar", None
    if t == "ValueStorage":
        return "BLOB", "scalar", None
    return "VARCHAR2(255 CHAR)", "scalar", None


def uniq(name, used):
    base, i = name[:118], 2
    while name in used:
        name = f"{base}_{i}"
        i += 1
    used.add(name)
    return name


def label_of(node):
    syn = node.get("synonym", {})
    return syn.get("uk") or syn.get("ru") or node.get("name", "")


class Gen:
    def __init__(self, src, refs_in_batch):
        self.src = src
        self.in_batch = refs_in_batch     # ref → table (створювані + glossary)
        self.glossary = []                # (ru, en, uk, kind)
        self.open_q = []                  # рядки §9
        self.stats = {"tables": 0, "cols": 0, "fk": 0, "fk_deferred": 0,
                      "composite": 0, "untyped": 0, "child": 0, "seed": 0}
        self.tables = []                  # (name, cols[], pk, uks[], checks[])
        self.fks = []                     # (table, col, target_table)
        self.seed_rows = []               # (table, code, name, legacy)

    def col(self, table, used, oname, attr, extra_note=""):
        otype, kind, target = oracle_type(attr)
        cname = uniq(translit(attr["name"]), used)
        self.glossary.append((attr["name"], cname, label_of(attr), "attr"))
        if kind == "untyped":
            self.stats["untyped"] += 1
            self.open_q.append(f"- {table}.{cname} ({attr['name']}) — нетипізований "
                               f"(характеристика), колонку не створено")
            return None
        if kind == "composite":
            self.stats["composite"] += 1
            self.stats["cols"] += 2
            self.open_q.append(f"- {table}.{cname} ({attr['name']}) — композитний тип: "
                               f"REF_TYPE/REF_ID, без FK")
            return [(f"{cname}_REF_TYPE", "VARCHAR2(60 CHAR)", None, label_of(attr)),
                    (f"{cname}_REF_ID", "NUMBER", None, label_of(attr))]
        self.stats["cols"] += 1
        # FillChecking=ShowError — це UI-правило 1С, НЕ DB-гарантія: історичні та
        # предопределённые дані його порушують. Колонку лишаємо NULLABLE, вимогу
        # позначаємо в підписі й забезпечуємо в APEX. Інакше seed/завантаження падають.
        req = attr.get("fill_checking") == "ShowError"
        if req:
            extra_note = (extra_note + "; " if extra_note else "") + "обовʼязкове (FillChecking, enforce в APEX)"
        if kind in ("ref", "enum", "ref-ext"):
            cname = uniq(re.sub(r'_ID$', '', cname) + "_ID", used) if not cname.endswith("_ID") else cname
            if kind == "enum":
                self.fks.append((table, cname, "RSD_ENUMS")); self.stats["fk"] += 1
            elif kind == "ref" and target in self.in_batch:
                self.fks.append((table, cname, self.in_batch[target])); self.stats["fk"] += 1
            else:
                self.stats["fk_deferred"] += 1
                extra_note = (extra_note + "; " if extra_note else "") + f"FK deferred: {target} EXTERNAL"
        return [(cname, otype, None, label_of(attr), extra_note)]

    def catalog(self, ref, obj):
        tbl = table_name(ref)
        self.glossary.append((obj["name"], tbl, label_of(obj), "Catalog"))
        props = obj.get("properties", {})
        used = set()
        cols = [("ID", "NUMBER GENERATED ALWAYS AS IDENTITY", None, "Сурогатний ключ", ""),
                ("LEGACY_REF", "VARCHAR2(36)", "NOT NULL", "UUID 1С — звірка", "")]
        used |= {"ID", "LEGACY_REF"}
        uks = ["LEGACY_REF"]
        if props.get("CodeLength"):
            cl = props["CodeLength"]
            cols.append(("CODE", f"VARCHAR2({cl} CHAR)", "NOT NULL", "Код 1С", ""))
            used.add("CODE")
            if props.get("CheckUnique") == "true":
                uks.append("CODE")
        if props.get("DescriptionLength"):
            cols.append(("NAME", f"VARCHAR2({props['DescriptionLength']} CHAR)", "NOT NULL",
                         "Найменування", "")); used.add("NAME")
        if props.get("Hierarchical") == "true":
            cols.append(("PARENT_ID", "NUMBER", None, "Батьківський елемент (ієрархія)", "self"))
            used.add("PARENT_ID")
            self.fks.append((tbl, "PARENT_ID", tbl)); self.stats["fk"] += 1
        for owner in obj.get("owners", []):
            oref = owner if owner.startswith("Catalog.") else f"Catalog.{owner.split('.',1)[-1]}"
            cols.append(("OWNER_ID", "NUMBER", "NOT NULL", "Власник", ""))
            used.add("OWNER_ID")
            if oref in self.in_batch:
                self.fks.append((tbl, "OWNER_ID", self.in_batch[oref])); self.stats["fk"] += 1
            else:
                self.stats["fk_deferred"] += 1
            break
        for attr in obj.get("attributes", []):
            got = self.col(tbl, used, None, attr)
            if got:
                cols.extend(got)
        cols += [("IS_DELETED", "BOOLEAN DEFAULT FALSE", "NOT NULL", "Мʼяке видалення", ""),
                 ("CREATED_AT", "TIMESTAMP DEFAULT SYSTIMESTAMP", "NOT NULL", "Аудит", ""),
                 ("CREATED_BY", "VARCHAR2(255 CHAR) DEFAULT NVL(SYS_CONTEXT('APEX$SESSION','APP_USER'),USER)", "NOT NULL", "Аудит", ""),
                 ("UPDATED_AT", "TIMESTAMP DEFAULT SYSTIMESTAMP", "NOT NULL", "Аудит", ""),
                 ("UPDATED_BY", "VARCHAR2(255 CHAR) DEFAULT NVL(SYS_CONTEXT('APEX$SESSION','APP_USER'),USER)", "NOT NULL", "Аудит", "")]
        self.tables.append((tbl, cols, "ID", uks, [], label_of(obj), ref))
        self.stats["tables"] += 1
        # табличні частини
        for ts in obj.get("tabular_sections", []):
            self.tab_section(tbl, ts)
        # предопределённые → seed (лише з непорожнім UUID; CODE лише якщо колонка є)
        has_code = bool(props.get("CodeLength"))
        for it in obj.get("predefined", []):
            legacy = it.get("id", "")
            if not legacy:
                continue  # LEGACY_REF NOT NULL — без UUID рядок не сіємо
            self.seed_rows.append((tbl, has_code, it.get("code", ""),
                                   it.get("description") or it["name"], legacy))
            self.stats["seed"] += 1
        # обробники → §9
        if obj.get("module_handlers"):
            self.open_q.append(f"- {tbl}: обробники BSL (імена) — "
                               + ", ".join(obj["module_handlers"]))

    def tab_section(self, parent_tbl, ts):
        tname = uniq((parent_tbl + "_" + translit(ts["name"]))[:120], set())
        used = {"ID", "PARENT_FK_ID", "LINE_NO"}
        cols = [("ID", "NUMBER GENERATED ALWAYS AS IDENTITY", None, "Ключ", ""),
                (parent_tbl.replace("RSD_", "") + "_ID" if False else "OWNER_ID", "NUMBER", "NOT NULL", "Власник ТЧ", ""),
                ("LINE_NO", "NUMBER", "NOT NULL", "Номер рядка", "")]
        # use OWNER_ID as parent fk
        for attr in ts.get("attributes", []):
            got = self.col(tname, used, None, attr)
            if got:
                cols.extend(got)
        self.tables.append((tname, cols, "ID", [], [], label_of(ts) + " (ТЧ)", None))
        self.fks.append((tname, "OWNER_ID", parent_tbl)); self.stats["fk"] += 1
        self.stats["child"] += 1
        self.stats["tables"] += 1


def render_ddl(g):
    L = ["-- Батч 003: довідники НСІ (хвилі 2–4). Транслітеровані імена; підписи uk у COMMENT.",
         "-- NLS_LANG=.AL32UTF8. Повторюваний. FK — окремою секцією після CREATE (цикли/порядок).",
         ""]
    for name, *_ in reversed(g.tables):
        L.append(f"DROP TABLE IF EXISTS {name} CASCADE CONSTRAINTS;")
    L.append("")
    for name, cols, pk, uks, checks, label, ref in g.tables:
        L.append(f"-- {ref or 'ТЧ'} — {label}")
        L.append(f"CREATE TABLE {name} (")
        body = []
        for c in cols:
            cn, ct, nn = c[0], c[1], c[2]
            body.append(f"    {cn} {ct}" + (f" {nn}" if nn else ""))
        body.append(f"    CONSTRAINT {name[:110]}_PK PRIMARY KEY ({pk})")
        for u in uks:
            body.append(f"    CONSTRAINT {(name+'_UK_'+u)[:120]}_ UNIQUE ({u})")
        L.append(",\n".join(body))
        L.append(");")
        L.append(f"COMMENT ON TABLE {name} IS {q(label)};")
        for c in cols:
            if len(c) >= 4 and c[3]:
                L.append(f"COMMENT ON COLUMN {name}.{c[0]} IS {q(c[3])};")
        L.append("")
    L.append("-- ===== Зовнішні ключі (усі таблиці вже створені) =====")
    for tbl, col, target in g.fks:
        cn = (f"{tbl}_FK_{col}")[:120]
        L.append(f"ALTER TABLE {tbl} ADD CONSTRAINT {cn} FOREIGN KEY ({col}) "
                 f"REFERENCES {target} (ID);")
    return "\n".join(L) + "\n"


def render_readme(g, waves, excluded):
    s = g.stats
    return f"""\
# Батч 003 — довідники НСІ (хвилі {waves})

Механічно згенеровано `bas2apex/tools/gen_catalog_batch.py` — не редагувати руками.
Імена таблиць/колонок транслітеровані (латиниця), підписи (uk) — у COMMENT.
Виключені (вже мігровані батчем 001): {', '.join(excluded) or '—'}.

## Підсумок
- Таблиць: **{s['tables']}** (з них дочірніх ТЧ: {s['child']})
- Колонок: {s['cols']}
- FK встановлено: {s['fk']}; відкладено (EXTERNAL/цикли поза батчем): {s['fk_deferred']}
- Композитних реквізитів (REF_TYPE/REF_ID): {s['composite']}
- Нетипізованих (характеристики, колонку не створено): {s['untyped']}
- Seed-рядків (предопределённые): {s['seed']}

## §9 — на ревю архітектора
{chr(10).join(g.open_q[:200]) if g.open_q else '- (порожньо)'}

## Встановлення
`ddl.sql` → стенд (NLS_LANG=.AL32UTF8). EnumRef-колонки посилаються на RSD_ENUMS (батч 002).
"""


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--source", type=Path, required=True)
    ap.add_argument("--waves", default="2,3,4")
    ap.add_argument("--exclude", default="")
    ap.add_argument("--out-dir", type=Path, required=True)
    args = ap.parse_args()
    waves = {int(w) for w in args.waves.split(",")}
    excluded = {e.strip() for e in args.exclude.split(",") if e.strip()}
    args.out_dir.mkdir(parents=True, exist_ok=True)

    objs = bm.scan(args.source)
    sccs = bm.tarjan_scc(objs)
    bm.waves_of(objs, sccs)
    targets = [o for o in objs.values()
               if o["wave"] in waves and o["type"] == "Catalog" and o["ref"] not in excluded]

    # мапа ref→table для резолву FK (створювані + вже мігровані)
    refs_in_batch = dict(GLOSSARY_TABLES)
    for o in targets:
        refs_in_batch[o["ref"]] = table_name(o["ref"])

    g = Gen(args.source, refs_in_batch)
    for o in sorted(targets, key=lambda x: x["ref"]):
        parsed = ec.parse_object(args.source, o["ref"])
        if parsed:
            g.catalog(o["ref"], parsed[0])

    (args.out_dir / "ddl.sql").write_text(render_ddl(g), encoding="utf-8")
    (args.out_dir / "README.md").write_text(render_readme(g, args.waves, excluded), encoding="utf-8")
    # seed
    seed = ["-- Батч 003 seed (предопределённые). Ідемпотентний. NLS_LANG=.AL32UTF8.", "SET DEFINE OFF"]
    for tbl, has_code, code, name, legacy in g.seed_rows:
        name = name or legacy           # NAME NOT NULL — фолбек на UUID
        code = code or name             # CODE NOT NULL, у предвизначених часто порожній → імʼя
        cols = "LEGACY_REF" + (",CODE" if has_code else "") + ",NAME"
        vals = q(legacy) + (f",{q(code)}" if has_code else "") + f",{q(name)}"
        seed.append(f"MERGE INTO {tbl} t USING (SELECT {q(legacy)} lr FROM dual) s "
                    f"ON (t.LEGACY_REF=s.lr) WHEN NOT MATCHED THEN "
                    f"INSERT ({cols}) VALUES ({vals});")
    seed.append("COMMIT;")
    (args.out_dir / "seed.sql").write_text("\n".join(seed) + "\n", encoding="utf-8")
    # glossary rows (dedup)
    seen, rows = set(), []
    for ru, en, uk, kind in g.glossary:
        if (ru, en) not in seen:
            seen.add((ru, en)); rows.append(f"| {ru} | {en} | {uk} | {kind} |")
    (args.out_dir / "glossary-rows.md").write_text("\n".join(rows) + "\n", encoding="utf-8")
    (args.out_dir / "stats.json").write_text(json.dumps(g.stats, ensure_ascii=False, indent=1), encoding="utf-8")
    print(f"{args.out_dir}: {g.stats['tables']} таблиць, {g.stats['cols']} колонок, "
          f"FK {g.stats['fk']}(+{g.stats['fk_deferred']} відкл.), "
          f"composite {g.stats['composite']}, untyped {g.stats['untyped']}, seed {g.stats['seed']}")


if __name__ == "__main__":
    main()
