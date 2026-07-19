---
name: apex-plsql-apis
description: >
  Reference/cheat-sheet for the APEX_* PL/SQL packages (Oracle APEX 26.1 API
  Reference) — exact signatures and headless patterns, so migration scripts don't
  hallucinate parameters or re-fetch Oracle docs. Use whenever the user writes or
  debugs server-side PL/SQL touching APEX: `apex_web_service` / `make_rest_request`,
  `apex_json`, `apex_exec` / `open_query_context` / `open_rest_source_query`,
  `apex_session.create_session`, `apex_acl` / `add_user_role`, `apex_util`,
  `apex_data_parser`, `apex_credential`, `apex_application_install`, `apex_lang`,
  "headless PL/SQL", "parse JSON in PL/SQL", "which APEX package for X", "signature
  for APEX_*". NOT for apex_workflow/apex_human_task (see `apex-workflow`), the BAS
  OData loader generator (see `bas2apex`), or .apx syntax (see `apexlang`).
---

# apex-plsql-apis — справочник пакетов APEX_* (26.1)

Быстрый lookup сигнатур и headless-паттернов, чтобы миграционные скрипты не угадывали параметры
и не перечитывали доку вживую. Источник — Oracle APEX 26.1 API Reference (`aeapi`). Это **справка**,
не обучающий скилл: открой нужный референс, скопируй сигнатуру.

> ⚠️ **URL-пастка доки.** Страницы подпрограмм именуются НЕ единообразно (`NAME-Function.html`,
> `PACKAGE.NAME-Procedure-Signature1.html`, с дефисом перед номером и без). **Не угадывай** URL —
> открой страницу пакета `PACKAGE.html`, там список подпрограмм ссылками, возьми реальный href.

## Справочные файлы

| Файл | О чём |
|---|---|
| [`references/package-index.md`](references/package-index.md) | Индекс всех **64 пакетов `APEX_*`** — по одной строке назначения (что где искать) |
| [`references/core-apis.md`](references/core-apis.md) | Глубокие сигнатуры высокочастотных пакетов (`APEX_WEB_SERVICE`, `APEX_JSON`, `APEX_EXEC`, `APEX_SESSION`, `APEX_ACL`, `APEX_DATA_PARSER`, `APEX_STRING`/`APEX_UTIL`, `APEX_APPLICATION_INSTALL`, `APEX_LANG`, `APEX_CREDENTIAL`) + 6 headless-паттернов |

## Топ-факты (чтобы не спотыкаться)

- **Headless-контекст**: вне браузера сначала `apex_util.set_workspace('BAS_REVERSE')` (или
  `set_security_group_id`), затем — для `apex_exec`/`apex_collection`/session-относительных вызовов
  — `apex_session.create_session(p_app_id, p_page_id, p_username)`; в конце `apex_session.detach`.
- **`APEX_ACL.ADD_USER_ROLE`** — в скриптах ВСЕГДА через `p_role_static_id` (портируемый), НЕ
  `p_role_id` (суррогат, пересоздаётся при импорте → тихо назначит не ту роль). Это и есть
  «ACL wiped after import» пастка из `bas2apex`/`apex-workflow`.
- **`APEX_WEB_SERVICE.MAKE_REST_REQUEST`** возвращает CLOB (для бинарного — `_B` → BLOB);
  `p_credential_static_id` = имя Web Credential; заголовки — глобалом через `SET_REQUEST_HEADERS`;
  статус — `apex_web_service.g_status_code`.
- **JSON**: плоский массив → грузи `JSON_TABLE` (нативный SQL, быстро); одиночный/нерегулярный
  объект → `apex_json.parse` + `get_varchar2('path[%d].x', p0=>i)`.
- **`APEX_L10N` НЕ существует** — перевод сообщений это `APEX_LANG.GET_MESSAGE`; локаль сессии —
  `APEX_UTIL.SET_SESSION_LANG/TERRITORY/TIME_ZONE`.
- **Deprecated** (не использовать): `APEX_UTIL.STRING_TO_TABLE`/`TABLE_TO_STRING` → `APEX_STRING`;
  `APEX_APPROVAL` → `APEX_HUMAN_TASK`; `APEX_ITEM` (tabular forms) → Interactive Grid.

## Границы (отдать другим скиллам)

- `APEX_WORKFLOW` / `APEX_HUMAN_TASK` / `APEX_APPROVAL` — владеет **`apex-workflow`** (см.
  `references/human-tasks-and-api.md` там). Здесь — только строка в индексе.
- **BAS-OData загрузчик** (пагинация по Code-префиксу, RAW→project MERGE) — владеет **`bas2apex`**
  (`tools/gen_odata_loaders.py`). Здесь — общий `APEX_WEB_SERVICE`/`APEX_JSON`/`APEX_EXEC` + generic
  паттерны, не BAS-специфика.
- Синтаксис `.apx`, APEXLang API — владеет **`apexlang`**. Здесь — только runtime-PL/SQL.
