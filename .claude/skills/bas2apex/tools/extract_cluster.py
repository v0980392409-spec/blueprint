#!/usr/bin/env python3
"""
extract_cluster.py — детерминированная выжимка кластера объектов из XML-дампа
конфигурации 1С/BAS (DumpConfigToFiles) для миграции на Oracle APEX.

Кластер = корневой объект + все объекты, на которые он ссылается (глубина 1).
Перечисления грузятся полностью (значения нужны для seed data), остальные
ссылки — с полным составом реквизитов; их собственные ссылки помечаются
external. Выход — компактный JSON: только то, что нужно для маппинга
(имена, синонимы ru/uk, типы с квалификаторами, FillChecking, табличные
части, предопределённые элементы). Шум дампа (InternalInfo, развёрнутые
StandardAttributes, формы) отбрасывается — сырой XML в контекст LLM не идёт.

Использование:
  python3 extract_cluster.py --source <dump-dir> --object Catalog.RSD_Дома \
      [--out cluster.json]
  Имя объекта — как в 1С: Тип.Имя (Catalog|Document|Enum|InformationRegister|
  AccumulationRegister|ChartOfCharacteristicTypes|BusinessProcess|Task).
"""
from __future__ import annotations

import argparse
import json
import re
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

TYPE_TO_DIR = {
    "Catalog": "Catalogs",
    "Document": "Documents",
    "Enum": "Enums",
    "InformationRegister": "InformationRegisters",
    "AccumulationRegister": "AccumulationRegisters",
    "AccountingRegister": "AccountingRegisters",
    "ChartOfCharacteristicTypes": "ChartsOfCharacteristicTypes",
    "BusinessProcess": "BusinessProcesses",
    "Task": "Tasks",
    "DocumentJournal": "DocumentJournals",
}
REF_RE = re.compile(r"^cfg:([A-Za-z]+)Ref\.(.+)$")

# Свойства корня, значимые для маппинга (см. mapping-rules.md), по типам объектов.
CATALOG_PROPS = [
    "Hierarchical", "HierarchyType", "CodeLength", "CodeType",
    "DescriptionLength", "CheckUnique", "Autonumbering", "SubordinationUse",
]
DOCUMENT_PROPS = ["NumberLength", "NumberType", "NumberPeriodicity", "Autonumbering", "Posting"]
INFOREG_PROPS = ["InformationRegisterPeriodicity", "WriteMode", "MainFilterOnPeriod"]


def lc(tag: str) -> str:
    return tag.split("}")[-1]


def child(el, name):
    if el is None:
        return None
    for c in el:
        if lc(c.tag) == name:
            return c
    return None


def children(el, name):
    if el is None:
        return []
    return [c for c in el if lc(c.tag) == name]


def text(el, name, default=""):
    c = child(el, name)
    return (c.text or "").strip() if c is not None and c.text else default


def multilang(el, name):
    out = {}
    for item in children(child(el, name), "item"):
        lang, content = text(item, "lang"), text(item, "content")
        if lang:
            out[lang] = content
    return out


def parse_type(props):
    """<Type> -> (types[], qualifiers{}, refs[]). Типы без префиксов xs:/cfg:."""
    tnode = child(props, "Type")
    types, refs, quals = [], [], {}
    if tnode is None:
        return types, quals, refs
    for c in tnode.iter():
        tag, val = lc(c.tag), (c.text or "").strip()
        if tag == "Type" and val:
            m = REF_RE.match(val)
            if m:
                refs.append(f"{m.group(1)}.{m.group(2)}")
                types.append(f"{m.group(1)}Ref.{m.group(2)}")
            else:
                types.append(val.split(":", 1)[-1])
        elif tag in ("Length", "AllowedLength", "Digits", "FractionDigits",
                     "AllowedSign", "DateFractions") and val:
            # AllowedLength/AllowedSign со значениями по умолчанию — шум
            if (tag, val) not in (("AllowedLength", "Variable"), ("AllowedSign", "Any")):
                quals[tag] = int(val) if val.isdigit() else val
    return types, quals, refs


def parse_attribute(attr_el):
    props = child(attr_el, "Properties")
    if props is None:
        return None
    types, quals, refs = parse_type(props)
    a = {"name": text(props, "Name"), "synonym": multilang(props, "Synonym"),
         "types": types}
    if quals:
        a["qualifiers"] = quals
    if refs:
        a["refs"] = refs
    fc = text(props, "FillChecking")
    if fc and fc != "DontCheck":
        a["fill_checking"] = fc  # ShowError => NOT NULL-кандидат
    tooltip = multilang(props, "ToolTip")
    if tooltip:
        a["tooltip"] = tooltip
    idx = text(props, "Indexing")
    if idx and idx != "DontIndex":
        a["indexing"] = idx
    comment = text(props, "Comment")
    if comment:
        a["comment"] = comment
    return a


def parse_predefined(obj_dir: Path):
    p = obj_dir / "Ext" / "Predefined.xml"
    if not p.exists():
        return []
    items = []
    for it in ET.parse(p).getroot().iter():
        if lc(it.tag) == "Item":
            items.append({
                "id": it.get("id", ""),  # UUID предопределённого — XML-атрибут <Item id="...">
                "name": text(it, "Name"),
                "code": text(it, "Code"),
                "description": text(it, "Description"),
                "is_folder": text(it, "IsFolder") == "true",
            })
    return items


def parse_object(src: Path, ref: str):
    """ref = 'Catalog.RSD_Дома' -> разобранный объект или None, plus его refs."""
    typ, _, name = ref.partition(".")
    folder = TYPE_TO_DIR.get(typ)
    if not folder:
        return None
    path = src / folder / f"{name}.xml"
    if not path.exists():
        return None
    root = ET.parse(path).getroot()
    body = child(root, typ)
    if body is None and len(root):
        body = root[0]
    props = child(body, "Properties")
    obj = {"ref": ref, "type": typ, "name": name,
           "synonym": multilang(props, "Synonym")}
    comment = text(props, "Comment")
    if comment:
        obj["comment"] = comment

    prop_names = (CATALOG_PROPS if typ == "Catalog"
                  else DOCUMENT_PROPS if typ == "Document"
                  else INFOREG_PROPS if typ == "InformationRegister" else [])
    p_out = {}
    for pn in prop_names:
        v = text(props, pn)
        if v:
            p_out[pn] = int(v) if v.isdigit() else v
    # Hierarchical=false — убрать HierarchyType-шум
    if p_out.get("Hierarchical") == "false":
        p_out.pop("HierarchyType", None)
    if p_out:
        obj["properties"] = p_out

    owners_el = child(props, "Owners")
    owners = ([o.text.strip() for o in owners_el if o.text]
              if owners_el is not None else [])
    if owners:
        obj["owners"] = owners

    co = child(body, "ChildObjects")
    all_refs = list(owners)

    if typ == "Enum":
        obj["values"] = [
            {"name": text(vp, "Name"), "synonym": multilang(vp, "Synonym")}
            for v in children(co, "EnumValue")
            if (vp := child(v, "Properties")) is not None
        ]
        return obj, all_refs

    for group, tag in (("attributes", "Attribute"), ("dimensions", "Dimension"),
                       ("resources", "Resource")):
        items = [a for el in children(co, tag) if (a := parse_attribute(el))]
        if items:
            obj[group] = items
            for a in items:
                all_refs += a.get("refs", [])

    tabs = []
    for ts in children(co, "TabularSection"):
        tp, tco = child(ts, "Properties"), child(ts, "ChildObjects")
        tab = {"name": text(tp, "Name"), "synonym": multilang(tp, "Synonym"),
               "attributes": [a for el in children(tco, "Attribute")
                              if (a := parse_attribute(el))]}
        tabs.append(tab)
        for a in tab["attributes"]:
            all_refs += a.get("refs", [])
    if tabs:
        obj["tabular_sections"] = tabs

    if typ in ("Catalog", "ChartOfCharacteristicTypes"):
        pre = parse_predefined(src / folder / name)
        if pre:
            obj["predefined"] = pre

    # Имена обработчиков модуля объекта (только имена — логика не переносится)
    mod = src / folder / name / "Ext" / "ObjectModule.bsl"
    if mod.exists():
        code = mod.read_text(encoding="utf-8-sig", errors="ignore")
        handlers = re.findall(r"(?:Процедура|Функция)\s+([А-Яа-яA-Za-z_]+)\s*\(", code)
        if handlers:
            obj["module_handlers"] = sorted(set(handlers))

    return obj, all_refs


def find_subordinates(src: Path, root_ref: str):
    """Справочники, подчинённые корню кластера: Catalogs/*.xml, у которых
    <Owners> содержит root_ref. Дёшево: текстовый фильтр, затем точная
    проверка, что ссылка стоит именно внутри блока Owners."""
    found = []
    cat_dir = src / "Catalogs"
    if not cat_dir.is_dir():
        return found
    marker = f">{root_ref}<"
    for p in sorted(cat_dir.glob("*.xml")):
        try:
            txt = p.read_text(encoding="utf-8", errors="ignore")
        except OSError:
            continue
        if "<Owners>" not in txt or marker not in txt:
            continue
        m = re.search(r"<Owners>(.*?)</Owners>", txt, re.S)
        if m and marker in m.group(0):
            found.append(f"Catalog.{p.stem}")
    return found


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[1])
    ap.add_argument("--source", type=Path, required=True, help="каталог XML-дампа")
    ap.add_argument("--object", required=True, help="корень кластера: Тип.Имя")
    ap.add_argument("--out", type=Path, default=None, help="выходной JSON (default: stdout)")
    ap.add_argument("--no-subordinates", action="store_true",
                    help="не искать справочники, подчинённые корню (<Owners>)")
    args = ap.parse_args()

    if not args.source.is_dir():
        sys.exit(f"Дамп не найден: {args.source}")
    if "." not in args.object:
        sys.exit("Ожидается Тип.Имя, например Catalog.RSD_Дома")

    result = parse_object(args.source, args.object)
    if result is None:
        sys.exit(f"Объект не найден в дампе: {args.object}")
    root_obj, refs = result

    # Подчинённые справочники — часть ядра кластера (у владельца это фактически
    # его «табличная часть»): грузим полностью, их ссылки — в общий пул глубины 1.
    subordinates = {}
    if not args.no_subordinates:
        for sub_ref in find_subordinates(args.source, args.object):
            r = parse_object(args.source, sub_ref)
            if r is None:
                continue
            sub_obj, sub_refs = r
            subordinates[sub_ref] = sub_obj
            refs += sub_refs

    core_refs = {args.object, *subordinates}
    referenced, external = {}, []
    for ref in sorted(set(refs)):
        if ref in core_refs:
            continue
        r = parse_object(args.source, ref)
        if r is None:
            external.append(ref)
            continue
        ref_obj, second_refs = r
        # глубина 1: ссылки ссылок не грузим, только помечаем
        outward = sorted({s for s in second_refs
                          if s not in core_refs and s not in set(refs)})
        if outward:
            ref_obj["outward_refs"] = outward
        referenced[ref] = ref_obj

    cluster = {
        "source_dump": str(args.source),
        "root": root_obj,
        "subordinates": subordinates,    # справочники, подчинённые корню (<Owners>)
        "referenced": referenced,        # глубина 1, с реквизитами
        "external": sorted(external),    # не найдены/не грузим — FK-цели EXTERNAL
    }
    out_json = json.dumps(cluster, ensure_ascii=False, indent=1)
    if args.out:
        args.out.write_text(out_json, encoding="utf-8")
        n_attrs = len(root_obj.get("attributes", []))
        print(f"{args.out}: корень {args.object} ({n_attrs} реквизитов), "
              f"подчинённых {len(subordinates)}, ссылочных {len(referenced)}, "
              f"external {len(external)}, {len(out_json)//1024} КБ")
    else:
        print(out_json)


if __name__ == "__main__":
    main()
