#!/usr/bin/env python3
"""
build_migration_map.py — карта міграції всього XML-дампу 1С/BAS.

Сканує всі обʼєкти даних дампу, будує граф залежностей (посилальні типи
реквізитів + власники), знаходить цикли (SCC), розкладає обʼєкти по «хвилях»
(топологічні рівні: обʼєкт може мігрувати, коли всі його цілі FK вже є) і
пропонує порядок батчів для конвеєра bas2apex.

Використання:
  python3 build_migration_map.py --source <dump-dir> --out docs/migration-map.md
"""
from __future__ import annotations

import argparse
import sys
from collections import defaultdict
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import extract_cluster as ec  # noqa: E402  (парсер обʼєктів — спільний)

DATA_TYPES = [
    "Enum", "Catalog", "ChartOfCharacteristicTypes", "InformationRegister",
    "AccumulationRegister", "Document", "DocumentJournal", "BusinessProcess",
    "Task",
]
# Хабові довідники BSP: на них посилаються сотні обʼєктів, самі тягнуть пів
# конфігурації. У хвилях беруть участь, але цикли з ними — очікувані.
TYPE_ORDER = {t: i for i, t in enumerate(DATA_TYPES)}


def scan(src: Path):
    objects = {}
    for typ in DATA_TYPES:
        folder = src / ec.TYPE_TO_DIR[typ]
        if not folder.is_dir():
            continue
        for xml in sorted(folder.glob("*.xml")):
            ref = f"{typ}.{xml.stem}"
            parsed = ec.parse_object(src, ref)
            if parsed is None:
                continue
            obj, refs = parsed
            attrs = obj.get("attributes", []) + obj.get("dimensions", []) \
                + obj.get("resources", [])
            tab_attrs = [a for t in obj.get("tabular_sections", [])
                         for a in t["attributes"]]
            all_attrs = attrs + tab_attrs
            objects[ref] = {
                "ref": ref,
                "type": typ,
                "name": obj["name"],
                "label": obj.get("synonym", {}).get("uk")
                         or obj.get("synonym", {}).get("ru") or obj["name"],
                "attrs": len(all_attrs),
                "tabs": len(obj.get("tabular_sections", [])),
                "deps": sorted({r for r in refs if r != ref}),
                "owners": obj.get("owners", []),
                "composite": sum(1 for a in all_attrs if len(a.get("types", [])) > 1),
                "untyped": sum(1 for a in all_attrs if not a.get("types")),
                "handlers": len(obj.get("module_handlers", [])),
                "predefined": len(obj.get("predefined", [])),
                "hierarchical": obj.get("properties", {}).get("Hierarchical") == "true",
                "enum_values": len(obj.get("values", [])),
            }
    # залежності лише всередині відсканованого світу
    for o in objects.values():
        o["deps"] = [d for d in o["deps"] if d in objects]
        o["fanin"] = 0
    for o in objects.values():
        for d in o["deps"]:
            objects[d]["fanin"] += 1
    return objects


def tarjan_scc(objects):
    index, low, on_stack, stack = {}, {}, set(), []
    sccs, counter = [], [0]

    def strongconnect(v):
        # ітеративний Тарʼян (рекурсія впирається в ліміт на великих графах)
        work = [(v, 0)]
        while work:
            node, pi = work[-1]
            if pi == 0:
                index[node] = low[node] = counter[0]; counter[0] += 1
                stack.append(node); on_stack.add(node)
            recurse = False
            deps = objects[node]["deps"]
            for i in range(pi, len(deps)):
                w = deps[i]
                if w not in index:
                    work[-1] = (node, i + 1)
                    work.append((w, 0))
                    recurse = True
                    break
                elif w in on_stack:
                    low[node] = min(low[node], index[w])
            if recurse:
                continue
            if low[node] == index[node]:
                comp = []
                while True:
                    w = stack.pop(); on_stack.discard(w); comp.append(w)
                    if w == node:
                        break
                sccs.append(comp)
            work.pop()
            if work:
                parent = work[-1][0]
                low[parent] = min(low[parent], low[node])

    for v in objects:
        if v not in index:
            strongconnect(v)
    return sccs


def waves_of(objects, sccs):
    comp_of = {}
    for i, comp in enumerate(sccs):
        for v in comp:
            comp_of[v] = i
    comp_deps = defaultdict(set)
    for v, o in objects.items():
        for d in o["deps"]:
            if comp_of[d] != comp_of[v]:
                comp_deps[comp_of[v]].add(comp_of[d])
    level = {}

    def lvl(c):
        if c in level:
            return level[c]
        level[c] = 1 + max((lvl(d) for d in comp_deps[c]), default=0)
        return level[c]

    for c in range(len(sccs)):
        lvl(c)
    for v in objects.values():
        v["wave"] = level[comp_of[v["ref"]]]
        v["cycle"] = len(sccs[comp_of[v["ref"]]]) > 1
    return max(level.values(), default=0)


def render(objects, src, max_wave):
    by_type = defaultdict(list)
    for o in objects.values():
        by_type[o["type"]].append(o)
    total_attrs = sum(o["attrs"] for o in objects.values())
    cyc = [o for o in objects.values() if o["cycle"]]

    lines = []
    a = lines.append
    a("# Карта міграції — дамп " + src.name)
    a("")
    a("Згенеровано `bas2apex/tools/build_migration_map.py`. Хвиля N = обʼєкт можна "
      "мігрувати, коли всі його посилальні цілі вже в хвилях < N (обʼєкти одного "
      "циклу мігрують разом). Не редагувати руками — перегенерувати скриптом.")
    a("")
    a("## Підсумок")
    a("")
    a("| Тип | Обʼєктів | Реквізитів |")
    a("|---|---|---|")
    for t in DATA_TYPES:
        if by_type[t]:
            a(f"| {t} | {len(by_type[t])} | {sum(o['attrs'] for o in by_type[t])} |")
    a(f"| **Разом** | **{len(objects)}** | **{total_attrs}** |")
    a("")
    a(f"- Хвиль: {max_wave}; обʼєктів у циклах: {len(cyc)}")
    a(f"- Композитних реквізитів (REF_TYPE/REF_ID → §9): "
      f"{sum(o['composite'] for o in objects.values())}")
    a(f"- Нетипізованих реквізитів (характеристики → §9): "
      f"{sum(o['untyped'] for o in objects.values())}")
    a(f"- Обʼєктів з обробниками BSL: "
      f"{sum(1 for o in objects.values() if o['handlers'])}")
    a("")
    a("## Хвилі")
    for w in range(1, max_wave + 1):
        wave_objs = sorted((o for o in objects.values() if o["wave"] == w),
                           key=lambda o: (TYPE_ORDER[o["type"]], -o["fanin"]))
        if not wave_objs:
            continue
        a("")
        a(f"### Хвиля {w} — {len(wave_objs)} обʼєктів")
        a("")
        a("| Обʼєкт | Назва | Реквізити | ТЧ | ←на нього | →залежить | Прапорці |")
        a("|---|---|---|---|---|---|---|")
        for o in wave_objs:
            flags = []
            if o["cycle"]:
                flags.append("ЦИКЛ")
            if o["composite"]:
                flags.append(f"композит:{o['composite']}")
            if o["untyped"]:
                flags.append(f"без типу:{o['untyped']}")
            if o["handlers"]:
                flags.append(f"BSL:{o['handlers']}")
            if o["predefined"]:
                flags.append(f"предвизн:{o['predefined']}")
            if o["hierarchical"]:
                flags.append("ієрарх")
            if o["owners"]:
                flags.append("підпорядк")
            if o["enum_values"]:
                flags.append(f"значень:{o['enum_values']}")
            a(f"| {o['ref']} | {o['label']} | {o['attrs']} | {o['tabs']} "
              f"| {o['fanin']} | {len(o['deps'])} | {', '.join(flags)} |")
    a("")
    a("## Найбільші цикли")
    a("")
    seen = set()
    comp_map = defaultdict(list)
    for o in cyc:
        comp_map[o["wave"]].append(o["ref"])
    if not cyc:
        a("Циклів немає.")
    else:
        for w, refs in sorted(comp_map.items(), key=lambda x: -len(x[1]))[:5]:
            key = tuple(sorted(refs))
            if key in seen:
                continue
            seen.add(key)
            a(f"- хвиля {w}: {len(refs)} обʼєктів — " + ", ".join(sorted(refs)[:12])
              + (" …" if len(refs) > 12 else ""))
    return "\n".join(lines) + "\n"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--source", type=Path, required=True)
    ap.add_argument("--out", type=Path, required=True)
    args = ap.parse_args()
    objects = scan(args.source)
    sccs = tarjan_scc(objects)
    max_wave = waves_of(objects, sccs)
    args.out.write_text(render(objects, args.source, max_wave), encoding="utf-8")
    print(f"{args.out}: {len(objects)} обʼєктів, {max_wave} хвиль, "
          f"{sum(1 for o in objects.values() if o['cycle'])} у циклах")


if __name__ == "__main__":
    main()
