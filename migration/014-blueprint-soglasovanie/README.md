# Батч 014 — Blueprint-track наскрізь: «Погодження» (app 201)

Перший прогін **APEX Blueprint-track для document-shaped кластера (master-detail)**.
Раніше track проходили лише для довідника (пілот 001 → app 200 «BUDYNKY»); для
документів/регістрів був тільки DDL+дані+ручний APEXLang-UI. Тут — увесь конвеєр
FR+метадані → blueprint → скаффолд-застосунок, на **живих даних**.

Кластер: `BusinessProcess.Согласование` (Погодження) — 500 header + ТЧ (батч 012).
Курований: шапка + виконавці (843) + результати погодження (702). Пусті сутності
(ЗадачаИсполнителя тощо) виключено.

## Конвеєр

- **Stage 4a — reporting-view'и** (`ddl-views.sql`, встановлені, 0 INVALID):
  - `RSD_V_SOGLASOVANIE` — шапка + резолвлені імена Автора/Стану/Результату/
    Варіанту/Важливості (join RSD_POLZOVATELI/RSD_ENUMS), boolean→Так/Ні.
  - `RSD_V_SOGLAS_ISPOLNITELI` — **поліморфний виконавець** → Роль/Користувач +
    імʼя (107 користувачів по імені; 736 ролей — довідник ролей не мігровано),
    Порядок, Пройден.
  - `RSD_V_SOGLAS_REZULTATY` — рішення по ітераціях.
  - *Навіщо*: генератор blueprint надійніший над плоским джерелом, ніж над
    складним join/поліморф-SQL. Форми лишаються над базовими таблицями.
- **Stage 4b** — `schema-metadata.md` (база `RSD_SOGLASOVANIE` для форми,
  курований набір ~14 колонок замість 42, + 3 view для звітів) та `fr.md` (EARS,
  точний SQL 5 LOV над RSD_ENUMS з фільтром ENUM_TYPE / RSD_POLZOVATELI).
- **Stage 6 — `blueprint.md`** (638 рядків, канонічний промпт, 0 Validation
  Findings): 3 сторінки — Дашборд (4 KPI-картки + 3 графіки), Faceted-список
  (фасети над текстовими `*_NAME` — обхід boolean-пастки), модальна форма
  «Процес погодження» (LOV-редагування шапки + 2 read-only master-detail звіти
  через `owner_id = to_number(:P3_ID)`). Ролі ADMIN/CONTRIBUTOR/READER.
- **Stage 7 — import → app 201 «ПОГОДЖЕННЯ»** (alias `pogodzhennya`):
  `APEX_GENDEV.PROCESS_BLUEPRINT` (parsing log **NULL** = чисто) → apexlang.zip
  (54 КБ) → `apex import` (LANG=C.utf8). Ролі ADMIN → CLAUDE/VIKTOR. Ре-експорт
  → `applications/pogodzhennya/` (репо=стенд; APEX нормалізував, додав
  component-settings.apx).

## Перевірка (стенд)

- **Структура**: 4 сторінки (Дашборд / Погодження / Процес погодження[modal] /
  Login), усі регіони (4 KPI+3 графіки / звіт+фасети / форма+2 деталі), 5 LOV.
- **Дані течуть**: KPI total=500, active=500, approved=333, rejected=20;
  master-detail — proc 17 (2 погоджувачі + 1 результат), 18 (2/2), 19 (1/1).
- **Deployment**: логін-сторінка «Погодження» рендериться (ORDS обслуговує 201).
- **Візуальна перевірка авторизованих сторінок — за власником** (логін; пароль
  не вводиться асистентом).

## Артефакти

`ddl-views.sql`, `schema-metadata.md`, `fr.md`, `blueprint.md`, `stage7-mkzip.sql`,
`stage7-grant-roles.sql`. Джерело правди UI — `applications/pogodzhennya/`.

## Пастки/факти (нове, для SKILL/progress)

- **APEX_GENDEV** = public synonym → `APEX_260100.WWV_BP_APEXLANG_API`;
  `PROCESS_BLUEPRINT(p_blueprint IN CLOB, p_parsing_log OUT CLOB, p_apexlang_zip OUT BLOB)`.
  Запускати як BAS_REVERSE; читати blueprint через BP_TMP_DIR (=/tmp у apex-db).
- **SQLcl 26.1.2 `apex import`**: флаги `-input <dir>` (НЕ `-dir`), `-id <appid>`
  (НЕ `-applicationId`), `-alias`, `-workspaceId <id>`. Usage лише при конекті;
  `-h`/`-help`/`-?` не підтримуються. Cyrillic-імена сторінок ОК за LANG=C.utf8.
- **Поліморфні/enum FK у master-detail** → резолв через view'и; базові таблиці
  для форм. App id/alias призначаються на import (у blueprint їх немає).
- **BAS_REVERSE конект** (пароль зі спецсимволами): `connect BAS_REVERSE/"pw"@...`
  (лапки) через `sqlplus /nolog`; helper'и `/root/basrev_{db,ords}.sh` (пароль
  лишається на VPS).
