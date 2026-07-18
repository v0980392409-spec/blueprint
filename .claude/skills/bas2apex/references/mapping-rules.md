# Mapping rules: 1C/BAS metadata → Oracle 26ai schema design

You are acting as a senior migration engineer across two platforms: the
1C:Enterprise 8.3 / BAS metadata model (consumed here as cluster.json, not raw
XML) and Oracle APEX 26.1 / Oracle Database 26ai. The transformation is a
faithful, auditable STRUCTURAL one — never inventive. When in doubt between
inventing and flagging, flag (§9 of the spec).

## Parameters (resolve before mapping)

- `APP_NAME` — target APEX application name.
- `MODULE_CONTEXT` — 1–3 sentences: business purpose of the cluster. Ask the
  user if not evident.
- `TABLE_PREFIX` — prefix for all generated tables. Default `RSD_` (project
  constitution: custom DB identifiers carry the integrator prefix). If a 1C
  name already starts with `RSD_`, do not double it.
- Labels are Ukrainian, taken from the `uk` synonym in cluster.json. Translate
  only when `uk` is absent (many stock-BAS objects have only `ru`) — and list
  every such translation in §9 for review.

## Object types

| 1C object (cluster.json `type`) | Target |
|---|---|
| Catalog | Master table + Interactive Report page + modal Form |
| Catalog, `Hierarchical=true` | + `PARENT_ID` self-FK; Tree or hierarchy-aware IR |
| Catalog with `owners` | Detail table with `OWNER_ID` FK to the owner's table |
| Document | Transaction table + IR list + Master-Detail page |
| `tabular_sections[i]` | Child table `<DOC>_<SECTION>` with `DOC_ID` FK + `LINE_NO`; unique(`DOC_ID`,`LINE_NO`) |
| Enum | Lookup table + seed rows from `values[]`, used as LOV. CHECK constraint instead only if ≤3 values and referenced by exactly one entity |
| InformationRegister, periodic | History table: dimension columns + `VALID_FROM DATE/TIMESTAMP`; unique(dims, `VALID_FROM`); note a "current value" view |
| InformationRegister, non-periodic | Plain table keyed by dimensions |
| AccumulationRegister | Movements table only: source doc ref + signed resource columns. Balances/totals design is an ARCHITECTURE DECISION — flag in §9, do not invent |
| Forms | DO NOT map 1:1 — APEX pages follow APEX UX patterns. Heavily customized forms → note existence in §9 |
| `module_handlers` | List names per object in §9. NEVER translate BSL to PL/SQL in the spec |
| `predefined[]` | Seed Data list in §2 for that entity |

## Standard attributes

These do not appear in cluster.json `attributes` (1C keeps them implicit);
emit them from the object's `properties`:

| 1C standard | Column | Trigger / notes |
|---|---|---|
| Ссылка (UUID) | `ID NUMBER GENERATED ALWAYS AS IDENTITY` (PK) **plus** `LEGACY_REF VARCHAR2(36) NOT NULL UNIQUE` | always; LEGACY_REF holds the 1C UUID — required for data migration and reconciliation |
| Код | `CODE VARCHAR2(n)` | `CodeLength>0`; n = CodeLength; `CheckUnique=true` → unique constraint; `Autonumbering=true` → note "app-assigned, keep editable" |
| Наименование | `NAME VARCHAR2(n CHAR)` | n = DescriptionLength |
| ПометкаУдаления | `IS_DELETED BOOLEAN DEFAULT FALSE NOT NULL` | always; soft delete — default filters exclude TRUE (no physical DELETE, project constitution) |
| Родитель | `PARENT_ID` self-FK | `Hierarchical=true` |
| ЭтоГруппа | `IS_FOLDER BOOLEAN` | `Hierarchical=true` with folders (`HierarchyType=HierarchyFoldersAndItems`) |
| Владелец | `OWNER_ID` FK | `owners[]` non-empty; >1 owner = composite-type situation → §9 |
| Документ: Номер | `DOC_NO VARCHAR2(n)` | n = NumberLength; uniqueness scope (per year/org — `NumberPeriodicity`) is a business decision → §9 |
| Документ: Дата | `DOC_DATE TIMESTAMP` | always for documents |
| Документ: Проведен | `IS_POSTED BOOLEAN DEFAULT FALSE NOT NULL` | `Posting=Allow` |
| — audit (documents and catalogs) | `CREATED_AT`, `CREATED_BY`, `UPDATED_AT`, `UPDATED_BY` | always; APEX conventions |
| Табличная часть: НомерСтроки | `LINE_NO NUMBER` | always in section child tables |

## Data types (cluster.json `types` + `qualifiers`)

| cluster.json | Oracle 26ai | Notes |
|---|---|---|
| `string`, Length=n | `VARCHAR2(n CHAR)` | |
| `string`, no Length (unlimited) | `CLOB` | flag in Notes column |
| `decimal`, Digits=L, FractionDigits=P | `NUMBER(L,P)` | copy exactly, never round |
| `decimal`, Digits=L, no FractionDigits | `NUMBER(L)` | |
| `dateTime`, DateFractions=Date | `DATE` | |
| `dateTime`, DateFractions=Time | `TIMESTAMP` | note "time-only in source" |
| `dateTime`, no DateFractions | `TIMESTAMP` | |
| `boolean` | `BOOLEAN` | native in 26ai |
| `CatalogRef.X` / `DocumentRef.X` | `X_ID NUMBER` FK → table of X | X in `referenced` → FK; X in `external`/`outward_refs` → FK column still created, target marked EXTERNAL |
| `EnumRef.X` | `X_ID NUMBER` FK → lookup table of X | |
| `UUID` | `VARCHAR2(36)` | note the choice (alternative RAW(16)) |
| `ValueStorage` | `BLOB` | flag in §9: content semantics unknown |
| ≥2 ref types on one attribute (composite) | see below | ALWAYS flag in §9 |

**Composite-type rule.** Default design: `REF_TYPE VARCHAR2(60)` +
`REF_ID NUMBER` (polymorphic, no DB-level FK). State the default, list the
allowed types, flag the decision in §9 (alternative: separate nullable FKs if
≤3 types).

**FillChecking=ShowError** → column NOT NULL candidate; record the source in
the Notes column. If the object's data may violate it historically, that is a
migration-load question — not a reason to drop the constraint silently.

**`indexing: Index`** → suggested index in §2.

## Pages (APEX conventions)

- Catalog → Interactive Report + modal Form. ≥5 filterable attributes →
  Faceted Search variant. Hierarchical → Tree region or hierarchy column.
- Document → IR list (IS_POSTED status badge, date-range filter) +
  Master-Detail page: header form + editable Interactive Grid per tabular
  section.
- Enum lookup → no standalone page unless it has extra attributes; managed via
  an admin page group.
- Register history → read-only IR with dimension filters.
- Approval hints (Статус attribute referencing an approval enum, or
  согласование objects nearby) → note "candidate for APEX Workflow" in the
  page description + detail in §9 (routes live in BSL/settings, not in
  structure).

## Naming

- English identifiers. Well-known domain words get meaningful translations
  (Дом→HOUSE, Помещение→UNIT, Организация→ORGANIZATION); the rest —
  consistent transliteration. Every choice lands in §8 and, after approval, in
  `docs/glossary.md`.
- Deterministic: same source name → same identifier, always, across batches.
  The glossary read at stage start is authoritative — never re-derive an
  identifier that already has a glossary row.
- Tables get `TABLE_PREFIX`. Columns do not.

## Hard rules

1. **No invented logic.** Nothing that is not in cluster.json. Handlers →
   names only, §9.
2. **Zero silent drops.** Every attribute of every object lands in §2 or §9.
   Compute the Coverage line; if unsure, recount programmatically.
3. **Exact qualifiers.** Lengths, precision, code length — copy, never round.
4. **External references.** FK column is still created; target marked
   EXTERNAL in §3/§8/§9.
5. **Output discipline.** English identifiers/structure; Ukrainian labels
   (from `uk` synonyms); source names preserved in §8 and the Source column.
   Valid Markdown; exactly one mermaid block.
6. **The spec is a spec** — no DDL, no PL/SQL, no APEXlang syntax in it.
   Those come at the derive stage.
