# Derive guide — from approved spec to blueprint inputs

Stage 4 turns the approved `spec.md` into four artifacts. Order matters:
DDL first (it is the ground truth the rest describes), then seed, then schema
metadata (describes the DDL for the blueprint generator), then FR (describes
the pages). Everything here must trace back to the spec — if you find
yourself adding a table or column that is not in §2, stop: that is a spec
change and goes back through review.

## 1. ddl.sql

- Oracle 26ai syntax (native `BOOLEAN`, `GENERATED ALWAYS AS IDENTITY`).
- One `CREATE TABLE` per §2 entity, columns in §2 order, constraints named:
  `<TABLE>_PK`, `<TABLE>_UK_<COL>`, `<TABLE>_FK_<COL>`, plus indexes from §2.
- FKs to EXTERNAL targets: create the column, SKIP the FK constraint, add a
  `-- FK deferred: <target> is EXTERNAL (batch NNN)` comment. Wiring them up
  happens when the target's batch lands.
- `COMMENT ON TABLE / COLUMN` for every table and column — Ukrainian, from
  the spec labels. These comments are not decoration: schema metadata and the
  blueprint generator read meaning from them.
- The file must be re-runnable against a schema where a previous attempt
  half-succeeded: guard with `DROP TABLE ... IF EXISTS` (26ai) in reverse
  dependency order at the top, or document that it is first-run-only.
- Encoding: UTF-8, and remember the stand pitfall — execute with
  `NLS_LANG=.AL32UTF8` or Cyrillic comments arrive as replacement characters.

## 2. seed.sql

- Enum values and `predefined[]` items from §2 Seed Data lists.
- Insert `LEGACY_REF` where the source had a UUID (predefined items carry
  ids in the dump), `CODE`, `NAME` (uk label).
- Idempotent: `MERGE` or `INSERT ... WHERE NOT EXISTS` — stage 5 may run
  more than once.

## 3. schema-metadata.md

Follow the exact format of
`blueprints/examples/order-entry/prompt-input/order-entry-schema-metadata.md`
(read it before writing). Per table:

```
# Table: RSD_HOUSES
Comment: <table comment>

## Columns:
  - ID - NUMBER NOT NULL [pk]
  - PROJECT_ID - NUMBER NOT NULL [fk]
  ...

## Column Comments:
  - <column> - <comment>

## Column Display Attributes:
  - <column>
    - description: ...
    - display-label: <Ukrainian label from spec §8>
    - semantic-type: ...        # only where confident
    - value-required: true      # from NOT NULL / FillChecking
    - format-mask: DD.MM.YYYY   # dates: project convention
    - read-only: true           # ID, LEGACY_REF, audit columns
    - primary-display-column: true   # usually NAME

## Constraints:
  - <name> - PRIMARY KEY / UNIQUE / FOREIGN KEY (...)

## Table Attributes:
  - description: ...
  - display-label: <Ukrainian plural label>
```

Rules of thumb:
- `display-label` — Ukrainian, from §8. Never leak English identifiers into
  labels.
- `semantic-type` — assign only obvious ones (identifier, date_time,
  person_name, email_address, enumeration, currency_amount). It is a UI hint,
  not a fact from the source — when unsure, omit; do not flag or invent.
- Enum/lookup FK columns: add `ai-context: Valid values are ...` listing the
  seed values, as the order-entry example does for status columns.
- Hide the plumbing: `LEGACY_REF`, `IS_DELETED`, audit columns get
  `read-only: true` and descriptions saying they are technical. The FR (below)
  must also not surface them as user-facing fields.

## 4. fr.md

Follow the structure of
`blueprints/examples/order-entry/prompt-input/order-entry-functional-requirements.md`
(read it before writing). Content comes from spec §1 (context), §4 (pages),
§5 (navigation), §6 (roles), §7 (rules that affect UI: required fields,
LOVs).

- Write it as what users need to do, not as APEX component talk — the
  canonical prompt maps intent to patterns itself.
- Ukrainian page names and labels; `IS_DELETED` filtering stated as "видалені
  записи приховані за замовчуванням".
- Dates `DD.MM.YYYY` (project convention).
- Keep scope to this cluster's pages; navigation entries for EXTERNAL
  entities do not exist yet — don't promise them.

## Checks before stage 5

- ddl.sql column set == spec §2 column set, per table (diff them, don't
  eyeball: extract column names from both and compare).
- Every schema-metadata table exists in ddl.sql with identical columns.
- fr.md references only tables/columns present in schema-metadata.md.
- seed.sql values == §2 Seed Data lists.
