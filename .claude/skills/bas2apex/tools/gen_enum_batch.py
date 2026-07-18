#!/usr/bin/env python3
"""
gen_enum_batch.py — детермінований генератор батча перечислень (хвиля 1).

Перечислення 1С — це довідкові списки значень без реквізитів. Маппінг чисто
механічний (правила skill: Enum → lookup + seed, без окремих сторінок), тож
його робить скрипт, а не LLM. Усі перечислення дампу зводяться в ОДНУ
уніфіковану таблицю `RSD_ENUMS` (тип, ключ значення, підпис) — вона стає
ціллю FK для `<X>_ID` колонок майбутніх батчів; коректність типу гарантує
LOV (фільтр `enum_type = '<X>'`), а не 241 окрема таблиця.

Використання:
  python3 gen_enum_batch.py --source <dump-dir> --out-dir migration/002-enums-wave-1
"""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import extract_cluster as ec  # noqa: E402


def q(s: str) -> str:
    """SQL-літерал у одинарних лапках із екрануванням."""
    return "'" + (s or "").replace("'", "''") + "'"


def collect(src: Path):
    enums = []
    for xml in sorted((src / "Enums").glob("*.xml")):
        obj, _ = ec.parse_object(src, f"Enum.{xml.stem}")
        vals = []
        for i, v in enumerate(obj.get("values", []), start=1):
            syn = v.get("synonym", {})
            label = syn.get("uk") or syn.get("ru") or v["name"]
            vals.append({"key": v["name"], "label": label, "sort": i * 10})
        enums.append({
            "ref": obj["ref"], "name": obj["name"],
            "label": obj.get("synonym", {}).get("uk")
                     or obj.get("synonym", {}).get("ru") or obj["name"],
            "values": vals,
        })
    return enums


DDL = """\
-- =============================================================================
-- Батч 002: перечислення (хвиля 1) — уніфікована lookup-таблиця RSD_ENUMS
-- Одна таблиця на всі {n_enum} перечислень дампу ({n_val} значень).
-- Виконувати з NLS_LANG=.AL32UTF8. Повторюваний (DROP IF EXISTS).
-- =============================================================================
DROP TABLE IF EXISTS RSD_ENUMS CASCADE CONSTRAINTS;

CREATE TABLE RSD_ENUMS (
    ID          NUMBER GENERATED ALWAYS AS IDENTITY,
    ENUM_TYPE   VARCHAR2(100 CHAR) NOT NULL,   -- імʼя перечислення 1С (техн. ключ)
    VALUE_KEY   VARCHAR2(150 CHAR) NOT NULL,   -- імʼя значення 1С (техн. ключ для звірки даних)
    NAME        VARCHAR2(255 CHAR) NOT NULL,   -- підпис (uk)
    SORT_ORDER  NUMBER             NOT NULL,
    IS_DELETED  BOOLEAN DEFAULT FALSE NOT NULL,
    CONSTRAINT RSD_ENUMS_PK PRIMARY KEY (ID),
    CONSTRAINT RSD_ENUMS_UK UNIQUE (ENUM_TYPE, VALUE_KEY)
);

COMMENT ON TABLE RSD_ENUMS IS 'Значення перечислень 1С (уніфікований довідник; FK-ціль для <X>_ID колонок, LOV фільтрує за ENUM_TYPE)';
COMMENT ON COLUMN RSD_ENUMS.ENUM_TYPE IS 'Імʼя перечислення 1С — технічний ключ типу';
COMMENT ON COLUMN RSD_ENUMS.VALUE_KEY IS 'Імʼя значення 1С — технічний ключ для звірки при завантаженні даних';
COMMENT ON COLUMN RSD_ENUMS.NAME IS 'Підпис значення (українською)';
COMMENT ON COLUMN RSD_ENUMS.SORT_ORDER IS 'Порядок значень як у джерелі';

CREATE INDEX RSD_ENUMS_IX_TYPE ON RSD_ENUMS (ENUM_TYPE);
"""


def render_seed(enums):
    lines = [
        "-- =============================================================================",
        "-- Батч 002: seed значень перечислень. Ідемпотентний (MERGE за ENUM_TYPE+VALUE_KEY).",
        "-- Виконувати з NLS_LANG=.AL32UTF8.",
        "-- =============================================================================",
        "SET DEFINE OFF",
        "",
    ]
    for e in enums:
        lines.append(f"-- {e['ref']} — {e['label']} ({len(e['values'])})")
        for v in e["values"]:
            lines.append(
                "MERGE INTO RSD_ENUMS t USING (SELECT "
                f"{q(e['name'])} enum_type, {q(v['key'])} value_key, "
                f"{q(v['label'])} name, {v['sort']} sort_order FROM dual) s "
                "ON (t.ENUM_TYPE=s.enum_type AND t.VALUE_KEY=s.value_key) "
                "WHEN MATCHED THEN UPDATE SET t.NAME=s.name, t.SORT_ORDER=s.sort_order "
                "WHEN NOT MATCHED THEN INSERT (ENUM_TYPE,VALUE_KEY,NAME,SORT_ORDER) "
                "VALUES (s.enum_type,s.value_key,s.name,s.sort_order);"
            )
        lines.append("")
    lines.append("COMMIT;")
    return "\n".join(lines) + "\n"


def render_readme(enums, n_val):
    top = sorted(enums, key=lambda e: -len(e["values"]))[:10]
    rows = "\n".join(f"| {e['ref']} | {e['label']} | {len(e['values'])} |" for e in top)
    return f"""\
# Батч 002 — перечислення (хвиля 1)

Механічний батч: усі **{len(enums)}** перечислень дампу ({n_val} значень) зведені
в одну lookup-таблицю `RSD_ENUMS`. Артефакти згенеровані детерміновано
(`bas2apex/tools/gen_enum_batch.py`) — не редагувати руками, перегенерувати скриптом.

## Рішення дизайну

- **Одна таблиця, не 241.** `RSD_ENUMS(ENUM_TYPE, VALUE_KEY, NAME, SORT_ORDER)`.
  Причина: 241 таблиця на 1326 рядків нечитабельна; уніфікований довідник —
  стандартний патерн для простору перечислень 1С.
- **FK-ціль.** Колонки `<X>_ID` майбутніх батчів (тип `EnumRef.X`) посилаються на
  `RSD_ENUMS(ID)`. Коректність типу забезпечує LOV:
  `select id, name from rsd_enums where enum_type = '<X>' order by sort_order`.
- **Звірка даних.** `VALUE_KEY` = імʼя значення в 1С — за ним завантаження зіставляє
  `EnumRef` зі рядком (аналог `LEGACY_REF`).
- **Без сторінок.** Перечислення не мають окремих сторінок APEX (правило skill);
  керуються через адмін-групу. Тому етапи blueprint/import для цього батча
  пропущені — deliverable це `ddl.sql` + `seed.sql`.

## Найбільші перечислення

| Перечислення | Підпис | Значень |
|---|---|---|
{rows}

## Встановлення

```bash
scp ddl.sql seed.sql apex-vps:/tmp/ && ssh apex-vps '...NLS_LANG=.AL32UTF8...'
```
Розблоковує EXTERNAL-цілі FK у батчах, що посилаються на перечислення —
зокрема `Enum.ЮрФизЛицо` (обовʼязковий FK у батчі 001).
"""


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--source", type=Path, required=True)
    ap.add_argument("--out-dir", type=Path, required=True)
    args = ap.parse_args()
    args.out_dir.mkdir(parents=True, exist_ok=True)

    enums = collect(args.source)
    n_val = sum(len(e["values"]) for e in enums)

    (args.out_dir / "enums.json").write_text(
        json.dumps({"source_dump": str(args.source), "enums": enums},
                   ensure_ascii=False, indent=1), encoding="utf-8")
    (args.out_dir / "ddl.sql").write_text(
        DDL.format(n_enum=len(enums), n_val=n_val), encoding="utf-8")
    (args.out_dir / "seed.sql").write_text(render_seed(enums), encoding="utf-8")
    (args.out_dir / "README.md").write_text(render_readme(enums, n_val), encoding="utf-8")
    print(f"{args.out_dir}: {len(enums)} перечислень, {n_val} значень → RSD_ENUMS")


if __name__ == "__main__":
    main()
