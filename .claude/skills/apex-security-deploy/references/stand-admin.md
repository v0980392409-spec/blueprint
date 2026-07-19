# Стенд: instance-админ (доступ, SMTP, джобы, бэкап)

Свод Administration Guide (`aeadm`) — только срез, полезный одно-воркспейсному стенду `BAS_REVERSE`.
Мультитенант-хостинг (провижининг воркспейсов, изоляция, self-service) — **есть в мануале, но не
нужно** здесь. Точные сигнатуры `APEX_INSTANCE_ADMIN` — в `apex-plsql-apis`; стек стенда — `docs/stand.md`.

## Роли и доступ

Четыре уровня: `End users` → `Developers` → `Workspace administrators` (управляют своим workspace)
→ `Instance administrators` (весь инстанс: workspaces, instance settings, security — через
приложение **Administration Services**).

- Вход в инстанс-админ: `https://<host>/ords/apex_admin` (или нижняя ссылка **Administration** на
  форме логина APEX), аккаунтом инстанс-админа (создан при установке).
- ⚠️ **Self-lockout**: включил `Disable Administrator Login` — назад **только SQL** (как SYS):
  ```sql
  begin apex_instance_admin.set_parameter('DISABLE_ADMIN_LOGIN','N'); end;
  ```
  (на стенде вход как SYS — `docker exec … sqlplus sys/$ORACLE_PWD@FREEPDB1 as sysdba`).

## Пользователи (мост к identity-bridge)

Manage Users and Groups → Create User: `Username` (≤100, спецсимволы только `&`/`.`; в рантайме
`:app_user`), тумблеры `Users are workspace administrators`/`Users are developers` (оба No = End
user), доступы `App Builder`/`SQL Workshop`/`Team Development`/`Data Reporter`. Группы — только для
`Oracle APEX Accounts` auth. **Имена — ВЕРХНИЙ регистр** (`p_uppercase_username` default TRUE) —
иначе `ORA-20987` на операциях задач. Это и есть точка identity-bridge BAS→APEX (сопоставить
`RSD_POLZOVATELI.IDENTIFIKATORPOLZOVATELYAIB` ↔ логины APEX).

## SMTP (на нём висят письма Human Task!)

Manage Instance → Instance Settings → Email: `SMTP Host Address` (default `localhost`), `SMTP Host
Port` (25), `SMTP Authentication Username/Password`, `Use SSL/TLS`, `Default Email From Address`,
`Maximum Emails per Workspace`. Кодом — `apex_instance_admin.set_parameter('SMTP_HOST_ADDRESS', …)`;
проверка — `apex_instance_admin.validate_email_config`. Нужен грант `DBMS_NETWORK_ACL_ADMIN` схеме
`APEX_260100` на исходящее соединение. Очередь — джоб `ORACLE_APEX_MAIL_QUEUE` (раз в 5 мин).

> Если уведомления Task Definition (Send Email actions) «не уходят» — первым делом сюда.

## Джобы DBMS_SCHEDULER (карта для троблшутинга)

| Джоб | Что | Когда |
|---|---|---|
| `ORACLE_APEX_MAIL_QUEUE` | отправка почты | 5 мин |
| `ORACLE_APEX_AUTOMATIONS` | Automations | 2 мин |
| `ORACLE_APEX_REST_SOURCE_SYNC` | REST Source Sync | 10 мин |
| `ORACLE_APEX_WF_TIMEOUT` | таймауты активностей workflow | 5 мин |
| `ORACLE_APEX_TASKS_EXPIRE` | истечение/продление задач | час |
| `ORACLE_APEX_TASKS_PURGE` | чистка задач | ночью 02:00 |
| `ORACLE_APEX_WFS_PURGE` | чистка workflow | ночью 03:00 |
| `ORACLE_APEX_PURGE_SESSIONS` | сессии >12ч | час |
| `ORACLE_APEX_BG_PROCESSES` | фоновые page-процессы | 2 мин |
| `ORACLE_APEX_PWA_PUSH_QUEUE` | push | 2 мин |
| `ORACLE_APEX_DAILY_MAINTENANCE`/`_METRICS`/`_BACKUP`/`_DICTIONARY_CACHE` | метрики/бэкап/кэш | ночью |

Диагностика: «письма стоят» → `ORACLE_APEX_MAIL_QUEUE`; «задача не истекает» → `ORACLE_APEX_TASKS_
EXPIRE` (или форс `apex_human_task.handle_task_deadlines`); «Automation не бежит» → `ORACLE_APEX_
AUTOMATIONS`.

## Инстанс-безопасность (кратко)

Manage Instance → Security: `Session Timeout` (`Maximum Session Length` 28800 / `Idle` 3600 /
`Warning` 300 — инстанс = пол, перекрывается ниже), password-policy (`Minimum Password Length`,
классы символов), `Authorized URLs` (allowlist редиректов), `Require HTTPS`, `Restrict Access by IP`.
Всё дублируется `apex_instance_admin.set_parameter('<PARAM>', …)` (`MAX_SESSION_IDLE_SEC`,
`SMTP_HOST_ADDRESS`, `REQUIRE_HTTPS`, …) — headless-фолбэк когда UI недоступен.

## Бэкап/экспорт через SQLcl (не `.apx`-пайплайн)

```
apex export -applicationid 200                 # одно приложение (SQL)
apex export -applicationid 200 -split          # по-компонентно (diff-friendly)
apex export -applicationid 200 -expComponents "PAGE:3 PAGE:11 LOV:12345"
apex export -workspaceid <id> [-expMinimal]    # весь workspace (метаданные/юзеры/группы; НЕ схемы/приложения)
apex list -applicationid 200 -changesSince 2026-07-01
```
`APEXExport` (легаси Java) **десаппортнут** — только SQLcl `apex export/import`. Whole-workspace
экспорт **не** включает схемы/объекты/приложения — их отдельным app-экспортом.

> **Проект**: `.apx`-трек (валидация/импорт/реэкспорт) — скиллы `bas2apex`/`apexlang`; workflow —
> SQL-трек (`apex-workflow`). Здесь — бэкап и восстановление доступа к стенду.
