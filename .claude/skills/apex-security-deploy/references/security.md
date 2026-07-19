# App-безопасность: auth, authz, ACL, Security Attributes

Свод App Builder User's Guide гл. 21. Точные сигнатуры `APEX_*` — в `apex-plsql-apis`. Деплой — в
[deploy.md](deploy.md); стенд — в [stand-admin.md](stand-admin.md).

Идентичность после логина — `APP_USER` (`:APP_USER` / `V('APP_USER')` / `sys_context('APEX$SESSION',
'APP_USER')`).

## 1. Authentication Schemes (11 предустановленных типов)

Новая схема **не** активна сразу — нажать **Make Current Scheme**.

| Тип | Когда |
|---|---|
| `Oracle APEX Accounts` | нативный репозиторий APEX. **Dev/demo** (стенд). Oracle НЕ рекомендует в проде (те же креды могут пускать и в workspace). |
| `Database Accounts` | валидация по schema-аккаунтам БД |
| `Social Sign-In` | OpenID Connect/OAuth2/Google/… — **прод** (федеративно). `Verify Attributes` отсекает `_verified:false` |
| `SAML Sign-In` | SAML; сначала настройка в Administration Services (нужен DB 19c RU9+/23ai/26ai) |
| `HTTP Header Variable` | имя из заголовка (`REMOTE_USER`, за Access Manager) |
| `LDAP Directory` | `SIMPLE_BIND_S`; DN с `%LDAP_USER%` |
| `Custom` | PL/SQL-функция → boolean перед каждым запросом |
| `No Authentication` | по DAD; **никогда не оставлять в проде** |
| `Open Door Credentials` | dev-only, только username |
| `Builder Extension Sign-in` / Oracle AS SSO (legacy) | — |

Рантайм-переключение — **Configuration Procedure** (Security Attributes → Authentication):
`p(p_conf in out nocopy apex_authentication.t_configuration)` может задать `authentication_name`
(целевая схема с `Switch In Session`), `substitutions` (`#NAME#`), `tenant_id`.

> **Проект**: стенд — `Oracle APEX Accounts` (CLAUDE/VIKTOR). Прод-контур ERP — федеративно +
> identity-bridge BAS→APEX (логины 1С ↔ APEX; ВЕРХНИЙ регистр).

## 2. Authorization Schemes

Типы (dropdown, расширяемо плагинами):

| Тип | Проходит если |
|---|---|
| `Exists SQL Query` / `NOT Exists SQL Query` | запрос вернул ≥1 / 0 строк |
| `PL/SQL Function Returning Boolean` | функция вернула `true` |
| `Item in Expression 1 is [NOT] NULL` | item пуст / не пуст |
| `Value of Item in Expression 1 Equals/Does NOT Equal Expression 2` | сравнение значения item |
| `Is In Group` / `Is Not In Group` | группа включена для сессии (см. `Source` ниже) |

**`Source for Role or Group Schemes`** (Security Attributes → Authorization) — откуда `Is In Group`
берёт членство: `Access Control User Role Assignments` (роли ACL приложения — §3), `Authentication
Scheme` (группы workspace для APEX Accounts / DB-роли для Database Accounts), `Custom Code`
(`apex_authentication.enable_dynamic_groups` в Post-Authentication).

**Кэш оценки** (`Validate authorization scheme`): `Once per session` (по умолч., эффективно) /
`Once per page view` / `Once per component` / `Always (No Caching)`. Сброс — `APEX_AUTHORIZATION.
RESET_CACHE`. Уровни привязки: Application / Page / Component. ⚠️ `Run on Background Job` проверяет
против **клонированной** session state (без коллекций/post-auth) → неожиданные отказы в джобах.

## 3. Access Control / ACL (роли приложения)

Мастер Access Control (Create Page → Feature → Access Control) генерит:
- роли `Administrator`/`Contributor`/`Reader` (**static id** `ADMINISTRATOR`/`CONTRIBUTOR`/`READER`);
- 3 authorization scheme: `Administration Rights`/`Contribution Rights`/`Reader Rights`;
- Application Setting `ACCESS_CONTROL_SCOPE` (`ALL_USERS` = любой аутентифицированный);
- **2 таблицы в схеме приложения** — назначения пользователь→роль (это и есть уязвимое место).
- build option `Feature: Access Control`.

Сгенерированный PL/SQL (шаблон для ручной логики при SQLcl-импорте):
```sql
-- Administration Rights:
return apex_acl.has_user_role(p_application_id=>:APP_ID, p_user_name=>:APP_USER, p_role_static_id=>'ADMINISTRATOR');
-- Reader Rights:
if nvl(apex_app_setting.get_value('ACCESS_CONTROL_SCOPE'),'x')='ALL_USERS' then return true;
else return apex_acl.has_user_any_roles(p_application_id=>:APP_ID, p_user_name=>:APP_USER); end if;
```
Компонентные схемы: `Administration/Contribution/Reader Rights` (+ их `Not …`). Вью:
`APEX_APPL_ACL_ROLES`, `APEX_APPL_ACL_USERS`, `APEX_APPL_ACL_USER_ROLES`.

### ⭐ Пастка «слетели роли после импорта» + фикс
- **Определения ролей** (роли + authorization schemes) — метаданные приложения → **экспортируются**
  (в `.apx`: `shared-components/acl-roles.apx`).
- **Назначения пользователь→роль** — в **метаданных APEX** (вью `apex_appl_acl_user_roles`), **не**
  в `.apx` и **не** экспортируются APEXlang'ом → теряются при полном import/пересборе схемы.
- **Фикс (проверено на app 200, 26.1)** — `role_id` по `static_id` в рантайме + `p_role_id`
  (перегрузка `p_role_static_id` здесь падает `ORA-01403`!):
  ```sql
  select role_id into l_id from apex_appl_acl_roles where application_id=N and role_static_id='admin';
  apex_acl.add_user_role(p_application_id=>N, p_user_name=>'CLAUDE', p_role_id=>l_id);  -- в apex_session.create_session(...)
  ```
  Оформлено как идемпотентный post-import скрипт `migration/016-acl-grant-fix/` (обязательный шаг
  после импорта). Для SQL-формата/packaged app альтернатива — те же вызовы в Supporting Objects
  Installation Script (`Yes and Install on Import Automatically`); APEXlang их не несёт → скрипт.

## 4. Security Attributes (чек-лист перед деплоем)

App Definition → Security (или Shared Components → Security → Security Attributes).

**Session Management**: `Rejoin Sessions` (⚠️ Oracle: включение = риск перехвата сессий; `Enabled
for All Sessions` требует SSP + `Embed In Frames` same-origin/Deny); `Deep Linking`; `Maximum
Session Length/Idle in Seconds` (+ Timeout URLs, `#LOGOUT_URL#`); `Session Timeout Warning`.

**Session State Protection** (антиподмена URL): app-toggle + `Page Access Protection`
(`Unrestricted`/`Arguments Must Have Checksum`/`No Arguments Allowed`/`No URL Access`) + item
`Session State Protection` (`Checksum Required: Application/User/Session Level` / `Restricted - May
not be set from browser`).

**Browser Security**: `Cache` (выключить → `cache-control: no-store`, не течёт через back после
логаута); `Embed in Frames` (`Deny`/`Allow from same origin`/`Allow` — антикликджекинг,
`X-Frame-Options`); `HTML Escaping Mode` (`Basic`/`Extended`); `HTTP Response Headers` (напр.
`X-Content-Type-Options: nosniff`). **CSP** — `Content-Security-Policy[-Report-Only]`, подстановки
`#APEX_CSP_NONCE#`/`#APEX_CSP_HASHES#`. Экранирование колонок: `#COL!HTML#`/`!ATTR#`/`!JS#`/`!RAW#`/
`!STRIPHTML#`.

**Database Session**: `Parsing Schema` (`#OWNER#`), `Initialization/Cleanup PL/SQL`, `Runtime API
Usage`. **Password items**: `Storage = Per Request (Memory Only)` для секретов; персистентный —
только `Store value encrypted`. **File uploads**: грузить в таблицу схемы или
`APEX_APPLICATION_TEMP_FILES` (не `APEX_APPLICATION_FILES` — не гейтится, течёт между юзерами).

**Application Availability** (`Status`): `Available` / `Available with Developer Toolbar` /
`Available to Developers Only` / `Restricted Access` / `Unavailable`. `Build Status` = `Run and
Build` vs `Run Application Only` (последнее после импорта откатывается только через Administration
Services — односторонняя блокировка).
