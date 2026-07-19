# Деплой: export / import / Supporting Objects

Свод App Builder User's Guide гл. 25 + Release Notes 2.1 (APEXlang). Проект экспортирует в
**APEXlang** через SQLcl. Точные SQLcl-команды бэкапа — в [stand-admin.md](stand-admin.md);
безопасность — в [security.md](security.md).

## Топология и формат

- dev / test / prod; test и prod — **runtime environments** (без App Builder), импорт DBA через
  SQLcl. Никогда не хардкодить application id — `APP_ID`/`APP_ALIAS`/alias.
- **Форматы**: `SQL` (`.sql`, `f<id>.sql`) vs **`APEXlang`** (`.zip`, `<app-alias>.zip`,
  оптимизирован под AI/VCS — это трек проекта). UI-импорт APEXlang требует **ORDS 26.1.1+** +
  REST-enabled schema; **постранично APEXlang через UI не импортируется** → только SQLcl/VS Code.

## Типы экспорта

| Тип | Для чего |
|---|---|
| `Standard Export` | **source control** (по умолч.): + dev-комменты/аудит, − runtime-данные |
| `Runtime Export` | test/prod: форсит `Run Application Only`, − комменты/аудит/runtime-данные |
| `Full Export` | всё, включая runtime-данные; **не для VCS** (environment-specific) |
| `Custom Export` | панель Advanced (см. ниже) |

**Custom (SQL) Advanced Options**: `Split into Multiple Files`, `Build Status Override`,
**`Supporting Object Definitions`** (`Yes` / `No` / **`Yes and Install on Import Automatically`**),
`Public/Private Reports`, `Report Subscriptions`, `Comments`, `Translations`, `Original IDs`
(стабильные id компонентов — важно для diff-VCS и связки subscriber↔master), `Owner Override`,
`Audit Information`, `As of` (флешбек через `DBMS_FLASHBACK`, в пределах `UNDO_RETENTION`),
`Workflow Instances`, `Task Instances`. Для APEXlang набор меньше (нет split/reports/original-ids;
**runtime-данные — Public/Private Reports, Subscriptions, Workflow/Task Instances — для APEXlang не
экспортируются**).

## Импорт

- **`Import As Application`**: `Auto Assign New Application ID` / **`Reuse Application ID XX`** (⚠️
  «existing application is deleted and then replaced») / `Change Application ID`.
- Заблокированное целевое приложение блокирует импорт. `Subscription Mode`: `Strict`/`Ignore
  Errors`/`Remove`/`Legacy`. Credentials/Remote Servers → до-настройка по подсказкам (секреты не
  едут). Supporting Objects → шаг установки. Бегущие background/scheduler джобы → отдельный диалог
  (`Disable Background Execution` vs `Replace Application` — второе убивает бегущие).

## ⭐ Supporting Objects — идемпотентность и фикс ACL

Иконка **Supporting Objects** приложения. Верхний тумблер `Include in Export` = `Yes` +
`Include Supporting Object Definitions in Export` (тот же tri-state). Секции:
- **Installation**: `Prerequisites`, `Application Substitution Strings` (спрашиваются при установке),
  `Build Options`, `Pre-installation Validations`, **`Installation Scripts`** (несколько,
  упорядоченные — сюда DDL/seed/**`apex_acl.add_user_role`**), `Messages`.
- **Upgrade**: `Upgrade Scripts` + `Query to Detect Existing Supporting Objects` (install-vs-upgrade);
- **Deinstallation**: `Deinstallation Script`.

**Ключ**: при экспорте с `Supporting Object Definitions = Yes and Install on Import Automatically`
командный `apex import` **сам перезапускает Installation Scripts** → гранты ролей (и любой
post-deploy seed) переживают каждый деплой без ручного шага. Это документированный фикс «слетевших
ролей» (см. [security.md](security.md) §3).

> ⚠️ **APEXlang-трек (этот проект) НЕ несёт Supporting Objects** (в `applications/<alias>/` их нет —
> проверено на app 200). Поэтому здесь фикс «слетевших ролей» — не install script, а **committed
> post-import grant-скрипт** `migration/016-acl-grant-fix/regrant.sh` (обязательный шаг после
> `apex import`, идемпотентный). Supporting Objects auto-install — путь для SQL-формата/packaged app.

## Build Options и прочее

- **Build Options** (`APEX_UTIL.GET/SET_BUILD_OPTION_STATUS`): `Include`/`Exclude` — фича-флаг на
  окружение; статус экспортируется/импортируется **отдельно** от приложения (флип фичи в проде без
  редеплоя). У каждого app есть встроенный `Commented Out`.
- **One-Click Remote Deployment** — деплой на удалённый инстанс через REST Enabled SQL (тот же набор
  Export Preferences + `Overwrite Existing Application`/`Application ID Override`).
- Имена файлов: `fNNN.sql`/`.zip`, `fNNN_page_N.sql`, `fNNN_components.sql`; инсталлеры
  `install.sql`/`install_page.sql`, обёртки `set_environment.sql`/`end_environment.sql`.
- **Гранты схеме** (APEX по умолчанию не даёт ничего): `CREATE SESSION, CREATE TABLE, CREATE VIEW,
  CREATE TRIGGER, CREATE SEQUENCE, CREATE PROCEDURE, CREATE TYPE, CREATE JOB, CREATE MATERIALIZED
  VIEW, CREATE SYNONYM, …` (`CREATE JOB` нужен для Workflow/Automations/REST-sync).
- Не называть свои объекты как APEX-овые PUBLIC-синонимы (`WWV_FLOW*`, `APEX_APPL_ACL_*`, …) —
  коллизия.

> **Проект (CLAUDE.md)**: `.apx` — источник правды в `applications/<alias>/`; **workflow там НЕ
> держится** → отдельный SQL-экспорт (`-expType APPLICATION_SOURCE`), см. скилл `apex-workflow`.
