# Индекс пакетов APEX_* (26.1) — 64 пакета

Все `APEX_*` пакеты API Reference с назначением в одну строку. Открывай `PACKAGE.html` за
реальными href подпрограмм (URL-пастка — см. SKILL.md). Глубокие сигнатуры высокочастотных — в
[core-apis.md](core-apis.md).

| Пакет | Назначение |
|---|---|
| `APEX_ACL` | роли пользователей приложения (access control); `add/remove/replace_user_role`, `has_user_role` |
| `APEX_AI` | Generative AI APIs — `CHAT`, `GENERATE`, эмбеддинги; нужна APEX-сессия |
| `APEX_APP_OBJECT_DEPENDENCY` | скан зависимостей приложения от объектов БД (+ невалидный SQL) |
| `APEX_APP_SETTING` | get/set значений Application Settings |
| `APEX_APPLICATION` | движок рендеринга: глобалы `g_user`, `g_flow_id`, `HELP`, `STOP_APEX_ENGINE` |
| `APEX_APPLICATION_ADMIN` | runtime-атрибуты установленного приложения (alias/name/status/auth…) |
| `APEX_APPLICATION_INSTALL` | конфиг перед установкой app-export скрипта (app id/schema/offset) |
| `APEX_APPROVAL` *(Deprecated)* | старый Human Task API → `APEX_HUMAN_TASK` (скилл `apex-workflow`) |
| `APEX_AUTHENTICATION` | API для auth-плагинов: `LOGIN`/`LOGOUT`/`CALLBACK`, SAML |
| `APEX_AUTHORIZATION` | схемы авторизации: `IS_AUTHORIZED`, `HAS_ACCESS`, `RESET_CACHE` |
| `APEX_AUTOMATION` | Automations (query→actions): `EXECUTE`, `LOG_INFO/WARN/ERROR`, `RESCHEDULE` |
| `APEX_BACKGROUND_PROCESS` | прогресс/отмена async фонового процесса |
| `APEX_BARCODE` | Code128/EAN8/QR как SVG или PNG BLOB |
| `APEX_COLLECTION` | session-scoped временное хранилище строк (Collections) |
| `APEX_CREDENTIAL` | управление Web Credentials (Basic/OAuth/JWT/OCI/header/query), persistent/session |
| `APEX_CSS` | добавить CSS в вывод (плагины) |
| `APEX_CUSTOM_AUTH` | низкоуровневая session/auth-обвязка (session id, cookies, LDAP DN) |
| `APEX_DATA_EXPORT` | экспорт запроса (через `APEX_EXEC`-контекст) в PDF/XLSX/HTML/CSV/XML/JSON |
| `APEX_DATA_INSTALL` | загрузка supporting-object данных при установке/миграции |
| `APEX_DATA_LOADING` | программный запуск Data Loading-определения (`LOAD_DATA`) |
| `APEX_DATA_PARSER` | парсинг CSV/XLSX/XML/JSON/ICS → `COL001..COL300` (`PARSE` pipelined) |
| `APEX_DB_DICTIONARY` | LLM-friendly метаданные БД (для AI-фич) |
| `APEX_DEBUG` | debug-лог: `ENABLE`, `MESSAGE`, `INFO/WARN/ERROR/TRACE` |
| `APEX_DG_DATA_GEN` | Data Generator: `GENERATE_DATA` (нужна сессия) |
| `APEX_ERROR` | центральный error-handling: `ADD_ERROR` (5 перегрузок) |
| `APEX_ESCAPE` | экранирование: `HTML`, `JS_LITERAL`, `CSV`, `LDAP_DN`, `JSON`, `CSS_SELECTOR`, `REGEXP` |
| `APEX_EXEC` | единая абстракция запросов/DML над local/remote DB и REST Data Sources |
| `APEX_EXPORT` | экспорт app/workspace в текст: `GET_APPLICATION`, `ZIP`/`UNZIP` |
| `APEX_EXTENSION` | Extension-App меню/ссылки для подписанных workspace |
| `APEX_HTTP` | скачать файл по HTTP(S) (`DOWNLOAD`) — уже `APEX_WEB_SERVICE` |
| `APEX_HUMAN_TASK` | Human Task runtime — **скилл `apex-workflow`** |
| `APEX_IG` | состояние Interactive Grid (фильтры/reset/saved report) |
| `APEX_INSTANCE_ADMIN` | инстанс-админ: workspaces/schemas/email/wallet; нужен SYS/`APEX_ADMINISTRATOR_ROLE` |
| `APEX_INSTANCE_DEBUG` | инстанс-контроль debug-лога по всем workspace |
| `APEX_IR` | состояние Interactive Report (фильтры/subscriptions/saved report) |
| `APEX_ITEM` *(Legacy)* | старые «tabular form» виджеты из SQL → Interactive Grid |
| `APEX_JAVASCRIPT` | добавить JS в вывод (плагины) |
| `APEX_JSON` | парсинг и генерация JSON |
| `APEX_JWT` | JWT encode/decode/validate — **только HS256** |
| `APEX_LANG` | перевод текст-сообщений приложения; NLS/XLIFF (нет `APEX_L10N`!) |
| `APEX_LDAP` | LDAP `AUTHENTICATE`/`SEARCH`/`IS_MEMBER`/атрибуты |
| `APEX_MAIL` | отправка почты (через `APEX_MAIL_QUEUE` джоб) |
| `APEX_MARKDOWN` | Markdown → HTML (`TO_HTML`, CommonMark 0.29) |
| `APEX_PAGE` | инфо о странице: `GET_URL`, кэш, режимы |
| `APEX_PLUGIN` / `APEX_PLUGIN_UTIL` | разработка плагинов (интерфейсы + хелперы) |
| `APEX_PRINT` | печать/генерация документов из шаблонов (`GENERATE_DOCUMENT`) |
| `APEX_PWA` | push-уведомления PWA (subscribe/send) |
| `APEX_REGION` | API регионов: query context, cache, reset |
| `APEX_REST_SOURCE_SYNC` | встроенный merge/sync REST Data Source → таблица (instant/scheduled) |
| `APEX_SEARCH` | унифицированный поиск по индексам приложения |
| `APEX_SESSION` | создать/attach/detach APEX-сессию для headless-PL/SQL |
| `APEX_SESSION_STATE` | типизированный get/set значений session state |
| `APEX_SHARED_COMPONENT` | публикация/refresh shared-компонентов |
| `APEX_SPATIAL` | Locator/Spatial хелперы: геометрия, `POINT`/`CIRCLE_POLYGON`/`RECTANGLE` |
| `APEX_STRING` | массивы/CLOB/строки: `SPLIT`/`JOIN`/`PUSH`/`FORMAT`/`GREP`/PLIST |
| `APEX_STRING_UTIL` | текст-майнинг: emails/links/tags/`DIFF`/`GET_SLUG` |
| `APEX_THEME` | темы по пользователю/сессии |
| `APEX_UI_DEFAULT_UPDATE` | UI Defaults (дефолты мастеров) для таблиц/колонок |
| `APEX_UTIL` | граббег: session state (`GET_SESSION_STATE`=`V()`), users/roles, prefs, cache, workspace |
| `APEX_WEB_SERVICE` | REST/SOAP: `MAKE_REST_REQUEST[_B]`, заголовки/cookies-глобалы, OAuth |
| `APEX_WORKFLOW` | Workflow runtime — **скилл `apex-workflow`** |
| `APEX_ZIP` | ZIP: `ADD_FILE`/`FINISH`/`GET_FILE_CONTENT`/`GET_DIR_ENTRIES` |
| `APEX_T_JAVASCRIPT_OBJECT` | тип для сборки JS-объектов (не JSON) в вывод |

Смежные книги (не здесь): **JavaScript API Reference** (`aexjs`) и **APEXLang API Reference**
(`apxln` — скилл `apexlang`).
