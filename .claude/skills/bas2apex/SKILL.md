---
name: bas2apex
description: >
  Migrate 1C/BAS configuration objects (справочники, документы, перечисления,
  регистры) to Oracle APEX 26.1 via the Blueprint pipeline. Use this skill
  whenever the user asks to migrate, transform, or reverse a BAS/1C object or
  cluster into APEX — including phrases like "перенеси справочник в APEX",
  "сделай спецификацию миграции", "трансформируй XML в blueprint", "извлеки
  кластер", "продолжи миграцию BAS", or mentions of EDO_XML_Conf /
  ERP_XML_Conf dumps. Covers the full path: XML dump → cluster JSON → 9-section
  spec → human review → FR + schema metadata + DDL → blueprint → import into
  APEX app 122.
---

# bas2apex — миграция BAS → Oracle APEX 26.1 через Blueprint

One cluster = one pipeline run. A cluster is a root object (документ or
справочник) plus the catalogs/enums it references. Never attempt the whole
configuration at once.

The pipeline is deliberately staged so that every LLM step consumes a compact,
deterministic input and produces a reviewable artifact. Raw 1C XML never goes
into context — it is 80% noise and blows past attribute-level fidelity, which
is the whole point (zero silent drops).

## Pipeline

```
1. extract   cluster JSON from XML dump          (script, deterministic)
2. specify   9-section migration spec            (LLM, references/spec-template.md)
3. review    human approves spec; §9 = backlog   (GATE — do not proceed without it)
4. derive    FR + schema metadata + DDL + seed   (LLM, references/derive-guide.md)
5. install   DDL + seed on the stand             (ssh apex-vps, sqlplus)
6. blueprint canonical Oracle prompt             (blueprints/prompt/blueprint-prompt.md)
7. import    App Builder → Import → Application Blueprint
```

## Workspace layout

Each cluster gets `migration/NNN-<slug>/` (sequential NNN) in the repo root:

```
migration/001-rsd-doma/
├── cluster.json          # stage 1 output
├── spec.md               # stage 2 output, reviewed at stage 3
├── fr.md                 # stage 4: functional requirements
├── schema-metadata.md    # stage 4: schema metadata
├── ddl.sql               # stage 4: tables + comments
├── seed.sql              # stage 4: predefined items / enum values
└── blueprint.md          # stage 6 output → imported at stage 7
```

`docs/glossary.md` is the cumulative naming glossary across ALL clusters —
read it before stage 2, append new rows after stage 3 approval. It is what
makes naming deterministic between batches; without it the same 1C name can
drift to different English identifiers in different runs.

## Stage 1 — extract

```bash
python3 .claude/skills/bas2apex/tools/extract_cluster.py \
  --source "/Users/stepanovviktor/Claude/BAS new/_source/EDO_XML_Conf" \
  --object "Catalog.RSD_Дома" \
  --out migration/NNN-<slug>/cluster.json
```

- `--source`: `EDO_XML_Conf` (Документообіг) or `ERP_XML_Conf` (BAS ERP).
- `--object`: `Тип.Имя` exactly as in 1C (`Catalog.X`, `Document.X`, `Enum.X`,
  `InformationRegister.X`, `AccumulationRegister.X`, …).
- Output: root object with full attribute detail (types, qualifiers,
  FillChecking, ru/uk synonyms, tooltips, tabular sections, predefined items,
  module handler names), `subordinates` — catalogs owned by the root via
  `<Owners>` (loaded fully: a subordinate catalog is effectively the owner's
  detail table; disable with `--no-subordinates`), referenced objects at
  depth 1, `external` list for refs that could not be loaded. Referenced
  objects' own outward refs are in `outward_refs` — they become EXTERNAL in
  the spec. Subordinates map per mapping-rules.md: detail table with
  `OWNER_ID` FK.

If the cluster JSON exceeds ~150 KB, the cluster is too big: split it
(reference-heavy catalogs like Пользователи/Организации stay depth-1 stubs by
design — do not re-root on them).

## Stage 2 — specify

Read `references/mapping-rules.md` and `references/spec-template.md`, then
transform `cluster.json` into `spec.md` following them exactly. Also read
`docs/glossary.md` first and reuse every existing identifier mapping.

Key invariants (full rules in the references):
- Every source attribute lands in §2 (Data Model) or §9 (Open Questions);
  the Coverage line must be arithmetically consistent.
- Ukrainian labels come from the `uk` synonym in cluster.json — translate
  only when `uk` is missing, and flag those translations in §9.
- No DDL, no PL/SQL, no APEXlang in the spec. Handler names → §9 as names only.
- Same source name → same identifier, across all batches (glossary).

## Stage 3 — review (GATE)

Present spec.md to the user. §9 (Unmapped & Open Questions) is the working
backlog for the architect — composite types, register totals, numbering
scopes, handler logic. Do not start stage 4 until the user approves the spec
or resolves the §9 items that block schema design. After approval, append new
glossary rows to `docs/glossary.md`.

## Stage 4 — derive

Read `references/derive-guide.md`. From the approved spec produce, in this
order: `ddl.sql`, `seed.sql`, `schema-metadata.md`, `fr.md`. The blueprint
does NOT create tables — DDL is a first-class artifact here, not an option.

## Stage 5 — install

Target: workspace/schema `BAS_REVERSE` on the stand (see `docs/stand.md`).

```bash
scp migration/NNN-<slug>/{ddl,seed}.sql apex-vps:/tmp/
ssh apex-vps 'source /opt/apex-stand/.env && for f in /tmp/ddl.sql /tmp/seed.sql; do
  docker cp $f apex-db:/tmp/ && docker exec -i -e NLS_LANG=.AL32UTF8 apex-db \
  sqlplus BAS_REVERSE/<pwd из /root/apex-credentials.txt>@FREEPDB1 @$f; done'
```

Cyrillic literals corrupt without `NLS_LANG=.AL32UTF8` — never skip it.
Verify each object compiled/created before moving on.

## Stage 6 — blueprint

Follow `blueprints/QUICKSTART.md` §"Generate The Blueprint" verbatim:

```
Using the prompt and icon allowlist files:
- blueprints/prompt/blueprint-prompt.md
- blueprints/prompt/apex-fa-icons-allowlist.txt
Generate and overwrite:
- migration/NNN-<slug>/blueprint.md
Using:
- migration/NNN-<slug>/fr.md
- migration/NNN-<slug>/schema-metadata.md
Don't read any other files unless directed by the prompt.
```

The canonical prompt is ~2200 lines of hard validation rules — do not
paraphrase it, load it and follow it. If the output contains
`## Validation Findings`, fix the blueprint with the same prompt and inputs
until clean.

## Stage 7 — import (server-side; proven on batch 001)

The App Builder import wizard (Import → Application Blueprint) parses the file
but its final install step can stall on a blank page — do NOT rely on it.
The reliable path is fully server-side:

```bash
# 1. blueprint.md → APEXlang zip (validates too: p_parsing_log stays null when clean)
scp migration/NNN-<slug>/blueprint.md apex-vps:/tmp/ && ssh apex-vps '
docker cp /tmp/blueprint.md apex-db:/tmp/
PW=$(grep "^schema BAS_REVERSE" /root/apex-credentials.txt | awk "{print \$4}")
docker exec -i -e NLS_LANG=.AL32UTF8 apex-db sqlplus -s BAS_REVERSE/$PW@FREEPDB1'
# PL/SQL: read /tmp/blueprint.md via directory BP_TMP_DIR (exists on the stand),
# call apex_gendev.process_blueprint(p_blueprint, p_parsing_log, p_apexlang_zip),
# write the blob to /tmp/apexlang.zip (see migration/001-rsd-doma history for the block)

# 2. unzip on the VPS, then import via SQLcl in the ords container.
#    LANG/LC_ALL=C.utf8 is MANDATORY — page files have Cyrillic names and the
#    JVM dies with InvalidPathException in POSIX locale. -alias must be ASCII,
#    otherwise the friendly URL gets a Cyrillic alias.
docker exec -e NLS_LANG=.AL32UTF8 -e LANG=C.utf8 -e LC_ALL=C.utf8 apex-ords \
  bash -c '... /opt/oracle/sqlcl/bin/sql ... "apex import -input /tmp/apx -id <NNN> -alias <ASCII> -workspace BAS_REVERSE"'
```

Known converter/compiler pitfalls (all hit on batch 001):
- Faceted filter `Datatype: boolean` — App Builder parser rejects it even
  though the canonical prompt's grammar allows it; project a varchar2 label
  (`case when ... then 'Так' else 'Ні' end`) and facet on that.
- `apex_gendev` derives IR savedReport ids from region names → Cyrillic name
  gives an illegal static id (`будинки-primary`). After unzip, rename such ids
  to ASCII (`sed`) before `apex import`.
- FILENAME_MISMATCH warnings from transliterated filenames are harmless.
- The imported app has Access Control roles but NO user role assignments —
  every login gets «Немає доступу» (ACCESS_DENIED_SIMPLE). Grant roles right
  after import (inside `apex_session.create_session`); note that
  `apex_acl.add_user_role` with `p_role_static_id` fails with ORA-01403 —
  use the `p_role_id` overload with the id from `apex_appl_acl_roles`:
  ```sql
  begin
      apex_session.create_session(p_app_id => <id>, p_page_id => 1, p_username => 'CLAUDE');
      select role_id into l_role_id from apex_appl_acl_roles
       where application_id = <id> and role_static_id = 'admin';
      apex_acl.add_user_role(p_application_id => <id>, p_user_name => 'CLAUDE', p_role_id => l_role_id);
      commit;
  end;
  ```

After import, export the result back into the repo (`applications/<alias>/`)
so it stays the source of truth:

```
apex export -applicationid <id> -exptype APEXLANG -dir /tmp/apx-export
```

## Incremental edits to an existing app (APEXlang)

To add/change a page, LOV, or item on an already-imported app, edit the
`.apx` files under `applications/<alias>/` (repo = source of truth), then:

1. **Validate**: `apex validate -input <dir>` in the ords container (LANG=C.utf8).
2. **Import in place**: `apex import -input <dir> -id <id> -alias <ASCII> -workspace BAS_REVERSE`.
3. **Re-grant roles** — import replaces the app and wipes ACL assignments (user→role
   pairs live in APEX metadata, not in `.apx`). Mandatory idempotent step:
   `migration/016-acl-grant-fix/regrant.sh <id> admin CLAUDE,VIKTOR`. NB (verified 26.1):
   `add_user_role(p_role_static_id=>...)` throws `ORA-01403` here — look up `role_id`
   from `apex_appl_acl_roles` by static_id and pass `p_role_id` (see `apex-security-deploy`).
4. **Re-export** back to the repo (round-trip; APEX normalizes ordering + adds
   savedReport ids — commit that version so repo matches the stand).

New pages: ASCII filename (`p00008-enums.apx`) avoids the Cyrillic-filename
JVM crash; add matching entries to `breadcrumbs.apx` and the nav `list` in
`lists.apx`, and a `pageGroup`. Reference existing schemes (`@admin`) and
LOVs (`@lov-...`) by their apx identifiers. Clone a plain-IR page (not a
faceted one) as the template for a simple report.

**Transfer pitfall (macOS → stand).** `scp -r` and `docker cp` of a macOS
directory materialize AppleDouble `._*` files inside the ords container
(`com.apple.provenance` xattr) — the APEXlang compiler then reads them as
source and fails with `token recognition error at: 'Mac OS X'`. `find -delete`
does not clear them reliably. Bulletproof: pipe a **git archive** stream
straight into the container's tar — no xattrs, no `._*`, no docker cp:

```bash
git archive --format=tar HEAD:applications/<alias> | \
  ssh apex-vps 'docker exec -i apex-ords bash -c "rm -rf /tmp/app && mkdir /tmp/app && tar -C /tmp/app -xf -"'
```

## Data track — live OData load (separate from structure)

For the declarative complements (Web Credentials attribute mechanics, Automations
for recurring reconcile, REST Source Sync spike), see
`references/ongoing-sync.md`. The hand-rolled loader below stays the default for
BAS's quirky OData.

Once NSI structure exists, fill it from BAS OData (see
`migration/004-data-nsi/` for the working pattern). Not `bas_sync_pkg` (the
experiment-1 framework rejects RSD_ uppercase/long names via its
`^[a-z]{,30}$` checks) — load directly:

- `apex_web_service.make_rest_request(p_url, p_credential_static_id => 'BAS_DOC_CRED')`
  inside `apex_session.create_session(...)` (credential needs an APEX session).
- Entity set `Catalog_<Name>`, Cyrillic percent-encoded in the URL; `$format=json`.
- **Paging large entities (>~3000 rows).** Deep `$skip` caps ~3000 rows via
  `apex_web_service` (timeout; curl gets all). Keyset by `Ref_Key` fails too —
  1C orders GUIDs in BINARY order but a string cursor compares lexically, and
  `$orderby` is ignored (asc=desc). **Working solution: partition by `Code`
  prefix with `startswith`** (`stage-kontragenty-by-code.sql`). This 1C
  publication forbids `eq/gt/ge/lt` on Code but allows
  `startswith(Code,'<pfx>')%20eq%20true`; sequential codes (`ДО-NNNNNN`) →
  prefixes `ДО-000`…`ДО-0NN`, each ≤1000 rows fetched in one request, no
  cursor. Verify partitions sum to the entity's `$count`. Two-phase (RAW →
  project) also survives cycles.
- `JSON_TABLE(l_clob, '$.value[*]' columns(...))`, Cyrillic field paths quoted
  (`'$."ИНН"'`).
- `MERGE ON (t.LEGACY_REF = s.Ref_Key)` — idempotent reconciliation on the 1C UUID.
- Enum-typed source fields (string value) → `<X>_ID` via subquery to `RSD_ENUMS`
  (`where enum_type=... and value_key=<val>`).
- Ref fields (`X_Key` UUIDs) stay NULL until the referenced catalog is loaded +
  a UUID→ID reconciliation pass.
- **Relax NOT NULL / UNIQUE before loading real data**: source has empty `Code`,
  unfilled required fields (`''` = NULL in Oracle). 1C constraints are UI-level,
  not DB guarantees for historical data — enforce them in APEX, not the table.

## Failure modes worth knowing

- **Spec drops attributes silently** — recompute Coverage against
  cluster.json programmatically if in doubt (`jq` the attribute names).
- **Blueprint import: missing database objects** — stage 5 skipped or DDL
  failed silently; re-check object list in the schema.
- **Mojibake in Ukrainian labels** — NLS_LANG was not set during stage 5, or
  a file was written without UTF-8; re-run with the exact commands above.
