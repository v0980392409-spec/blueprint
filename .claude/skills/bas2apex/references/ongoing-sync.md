# Web Credentials и Automations — довесок к data-track

Декларативные куски интеграции, дополняющие ручные OData-загрузчики (`tools/gen_odata_loaders.py`).
**НЕ замена** им: OData BAS кривой (игнорит `$orderby`, режет `$skip` ~3000 → нужна пагинация по
Code-префиксу), а декларативные REST Data Sources/REST Sync это из коробки не тянут. Здесь — только
то, чего в репо реально не хватает: механика **Web Credentials** и **Automations** (регулярная
сверка). Сигнатуры PL/SQL (`APEX_WEB_SERVICE`/`APEX_CREDENTIAL`/`APEX_EXEC`) — в скилле
`apex-plsql-apis`.

## Web Credentials (секреты для REST)

Workspace-уровень, шифровано. Создать: Workspace Utilities → **Web Credentials** (или Shared
Components → Workspace Objects → **Credentials**). `gen_odata_loaders.py` уже ссылается на
`BAS_DOC_CRED` по имени — вот его атрибуты:

- **Authentication Type**: `Basic Authentication`, `OAuth2 Client Credentials`, `HTTP Header`,
  `URL Query String`, `OAuth2 Password Flow`, `OCI Native`, … (для BAS OData обычно Basic).
- **Name** / **Static ID** — static id и подставляется в `p_credential_static_id => 'BAS_DOC_CRED'`.
- **`Valid for URLs`** — по одному префиксу URL на строку. Если целевой URL не начинается ни с
  одного — рантайм отказ `Credential is not allowed to be used for this URL endpoint`. **Это и есть
  шаг «Allowed URLs = хост OData» из `docs/stand.md`.**
- **`Prompt On Install`** — секрет не экспортируется; при импорте запрашивается заново.

> **Два базиса OData BAS** — каждому свой credential (или один с обоими хостами в `Valid for URLs`):
> ERP `https://rv.entercom.ua:5683/Riverside`, Документообіг `.../bas_doc`. По мере роста app 122
> (ERP-контур) понадобится второй credential.

Кодом (детали — `apex-plsql-apis`): `apex_credential.create_credential(...)` +
`apex_credential.set_persistent_credentials(p_credential_static_id=>'BAS_DOC_CRED', p_client_id=>…,
p_client_secret=>…)`.

## Automations (регулярная сверка/догрузка)

Shared Components → **Workflows and Automations → Automations** (то же меню, что Workflows, но
**другая** фича — не Human Task). Незаметный расписанный «query → PL/SQL-действия на строку».
Естественный дом для *повторяющейся* сверки: разовый MERGE из `gen_reconcile.py` → регулярный
логируемый джоб.

- **Type**: `Scheduled` (по `Schedule Expression` — календарный синтаксис `DBMS_SCHEDULER`, есть
  Interval Builder) или `On Demand` (только через `APEX_AUTOMATION.EXECUTE`). Нужен грант
  `CREATE JOB` схеме. Фоновый координатор — джоб `ORACLE_APEX_AUTOMATIONS` (раз в 2 мин).
- **Actions Initiated On**: `Query` (действия на каждую строку) / `Function Body Returning Boolean`
  / `Always`.
- **Data Source** запроса: `Local Database`, `REST Enabled SQL Service` или **`REST Data Source`**
  (можно триггерить прямо по REST-источнику, без локальной таблицы).
- **Actions**: последовательные PL/SQL-блоки, bind = колонки запроса (`:REF_KEY`), у каждого своя
  Server-Side Condition. `apex_automation.log_info/warn/error(...)` → Execution Log.
- **Action Execution**: `Execute Actions When` (rows returned/not), `Primary Key Column`, `Commit`
  (на строку/раз), `Maximum Rows to Process`, **Action Error Handling**: `Ignore` / `Terminate
  Automation` / `Disable Automation`.
- **Status**: `Active` / `Disabled` / `Error` (авто после сбоя; on-demand всё равно работает).
- Код: `apex_automation.execute(p_static_id => '…')`, `apex_automation.reschedule(...)`.
- Execution Log — таймстемпы/счётчики/сообщения; авто-очистка раз в 14 дней; ручной Purge Log.

## REST Source Synchronization — спайк (не проверено)

Встроенное зеркалирование REST Data Source в **локальную таблицу**: Shared Components → REST Data
Sources → источник → **Manage Synchronization**. `Synchronization Type`: `Append` / `Merge`
(нужен PK) / `Replace`. Расписание — календарный синтаксис. **`Steps`** (Add Step — вызвать
источник на каждый набор параметров) — ближайший встроенный аналог ручного «партиционирования по
Code-префиксу», но **не проверено**, тянет ли он квирк пагинации BAS. После импорта app'а sync
авто-**отключается** → `apex_rest_source_sync.enable(p_application_id, p_module_static_id)` /
`reschedule(...)`. Джоб — `ORACLE_APEX_REST_SOURCE_SYNC` (раз в 10 мин). **Вывод: спайк перед
тем как полагаться**; текущий ручной двухфазный загрузчик остаётся дефолтом для больших сущностей.
