# Spec template — 9 sections, exactly this order

The spec (`spec.md`) is the human-reviewed contract between the 1C source and
everything generated downstream (DDL, schema metadata, FR). Its quality gate
is §9 + the Coverage line: an architect must be able to see at a glance what
mapped mechanically and what needs a decision.

## 1. Application Overview

App name, module context, source objects list (with 1C refs), batch marker if
the cluster is part of a series.

## 2. Data Model

For EVERY entity: target table name, source object ref, then:

| Column | Oracle Type | Null | Default | Source (1C) | Notes |

After the column table: PK, unique constraints, FKs (with ON DELETE rule),
suggested indexes (from `indexing` hints and FK columns), and — if the source
has `predefined[]` or is an Enum — a `Seed Data` list (name, code, uk label).

## 3. Relationships

A single `mermaid erDiagram` covering all entities of this batch. Referenced
objects not present in the cluster (`external`, `outward_refs`) appear as
entities marked `EXTERNAL`.

## 4. Pages

Per entity, per the Pages section of mapping-rules.md: page name (Ukrainian),
type (Interactive Report / Form / Master-Detail / Faceted Search / Tree),
source table, key features (filters, status badges, editable grid for
tabular-section lines).

## 5. Navigation

Menu structure for this batch: entries, grouping, icons optional (icons must
come from `blueprints/prompt/apex-fa-icons-allowlist.txt` if named).

## 6. Roles & Access

If role/rights data is provided: map read/write per object to APEX
authorization scheme suggestions. Otherwise emit the default triad `ADMIN`,
`CONTRIBUTOR`, `READER` with a note that real roles must come from the source
configuration.

## 7. Business Rules (derived only)

ONLY rules literally derivable from cluster.json: required fields
(`fill_checking: ShowError`), string lengths, numeric precision, enum value
sets, uniqueness of Код (`CheckUnique`), master-detail cascade. Each rule
cites its source attribute.

## 8. Naming Glossary

| Source name (ru) | Identifier (en) | Label (uk) | Kind |

One row per object, attribute, tabular section, enum value. Rows already in
`docs/glossary.md` are repeated here verbatim (marked `existing`); new rows
are marked `new`. Label (uk) column: the uk synonym from cluster.json, or the
translation if uk was absent (then also flagged in §9).

## 9. Unmapped & Open Questions

Everything not mapped mechanically: composite types, register totals,
numbering scopes, ValueStorage semantics, module handler names per object,
labels translated by the model (uk synonym absent), heavily customized forms,
EXTERNAL targets. Mandatory final line:

`Coverage: mapped X of Y source attributes; Z flagged as open questions.`

Y = total attributes across root + tabular sections + referenced objects'
attributes included in §2. X + Z must equal Y.

## Self-check before presenting

- [ ] All 9 sections present, in order
- [ ] Coverage line present and arithmetically consistent with cluster.json
- [ ] Every FK resolves to an entity in §2 or is marked EXTERNAL
- [ ] Every composite type flagged in §9
- [ ] Every register's totals question flagged in §9
- [ ] No business logic invented; handler names listed in §9
- [ ] Glossary covers 100% of named source elements; existing glossary rows reused

## Calibration mini-example

cluster.json fragment:

```json
{"root": {"ref": "Catalog.Дома", "type": "Catalog",
  "synonym": {"ru": "Дома", "uk": "Будинки"},
  "properties": {"CodeLength": 9, "CodeType": "String",
    "DescriptionLength": 150, "CheckUnique": "true"},
  "attributes": [
    {"name": "Проект", "synonym": {"ru": "Проект"},
     "types": ["CatalogRef.КарточкиПроектов"],
     "refs": ["Catalog.КарточкиПроектов"], "fill_checking": "ShowError"},
    {"name": "ДатаВводаВЭксплуатацию",
     "synonym": {"ru": "Дата ввода в эксплуатацию", "uk": "Дата введення в експлуатацію"},
     "types": ["dateTime"], "qualifiers": {"DateFractions": "Date"}}]},
 "external": ["Catalog.КарточкиПроектов"]}
```

Output fragment (§2):

**Entity: RSD_HOUSES** (source: Catalog.Дома)

| Column | Oracle Type | Null | Default | Source (1C) | Notes |
|---|---|---|---|---|---|
| ID | NUMBER GENERATED ALWAYS AS IDENTITY | N | — | Ссылка | PK |
| LEGACY_REF | VARCHAR2(36) | N | — | Ссылка (UUID) | unique; migration reconciliation |
| CODE | VARCHAR2(9) | N | — | Код | unique (CheckUnique=true) |
| NAME | VARCHAR2(150 CHAR) | N | — | Наименование | label uk: «Будинки» |
| PROJECT_ID | NUMBER | N | — | Проект | FK → RSD_PROJECT_CARDS (EXTERNAL); required (FillChecking=ShowError); label uk translated — uk synonym absent → §9 |
| COMMISSIONING_DATE | DATE | Y | — | ДатаВводаВЭксплуатацию | label uk: «Дата введення в експлуатацію» |
| IS_DELETED | BOOLEAN | N | FALSE | ПометкаУдаления | soft delete |

§9 then contains: `RSD_PROJECT_CARDS — EXTERNAL, not in this batch`, the
translated-label note, and the Coverage line.
