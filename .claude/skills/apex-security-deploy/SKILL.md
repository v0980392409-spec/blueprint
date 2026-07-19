---
name: apex-security-deploy
description: >
  Secure and deploy Oracle APEX 26.1 apps + operate the self-hosted stand. Covers
  authentication schemes, authorization schemes, Access Control (ACL roles),
  Security Attributes, export/import lifecycle (SQL vs APEXlang, Supporting
  Objects), and instance/stand admin (apex_admin recovery, SMTP for Human Task
  emails, DBMS_SCHEDULER jobs, backup). Use whenever the user asks "почему после
  apex import слетели роли/ACL", "погоджувачі втратили доступ після імпорту",
  "настрой authentication/authorization scheme", "Access Control / ACL / apex_acl",
  "supporting objects install script", "export/import застосунку", "session timeout
  / rejoin sessions / deep linking / CSP", "не пускает в apex_admin", "настрой SMTP
  / письма не уходят", "почему job не бежит / DBMS_SCHEDULER". Defers exact APEX_*
  signatures to `apex-plsql-apis`, .apx syntax to `apexlang`.
---

# apex-security-deploy — безопасность, деплой и стенд APEX 26.1

Эксплуатационный слой: как **защитить** приложение (auth/authz/ACL), **задеплоить** его
(export/import) и **держать стенд** (instance-админ). Всё это «кусает» после миграции/импорта —
частый провал проекта. Точные сигнатуры `APEX_*` — в `apex-plsql-apis`; синтаксис `.apx` — в
`apexlang`; сами таблицы/blueprint — в `bas2apex`.

## ⭐ Главное: почему после `apex import` слетают роли (и как чинить навсегда)

**Причина.** Access Control различает две вещи:
- **Определения ролей** (`ADMINISTRATOR`/`CONTRIBUTOR`/`READER` + 3 authorization scheme) — это
  метаданные приложения → **экспортируются** и едут с `apex export`/`import`.
- **Назначения пользователь→роль** — это **обычные строки в двух таблицах схемы** (их создал
  Access Control-мастер), для APEX-экспорта **невидимы**. Их сносит любой пересбор схемы (DDL
  rebuild в `migration/NNN-*`) и они не едут при импорте.

**Фикс — по формату экспорта:**
- **SQL-формат / packaged app**: вызовы `apex_acl.add_user_role(...)` в **Supporting Objects →
  Installation Script** + экспорт `Supporting Object Definitions = Yes and Install on Import
  Automatically` → `apex import` сам перевыдаёт роли. Детали — [`references/deploy.md`](references/deploy.md).
- **APEXlang-трек (этот проект)**: `.apx` НЕ держит назначений, app не имеет Supporting Objects →
  фикс = **committed post-import grant-скрипт** `migration/016-acl-grant-fix/` (`regrant.sh` /
  `grant-roles.sql`) — обязательный идемпотентный шаг после каждого `apex import`.

> ⚠️ **Проверено на стенде (app 200, 26.1)**: `add_user_role(p_role_static_id=>'admin')` падает с
> `ORA-01403`; работает `p_role_id` — но **находить его по static_id в рантайме**, не хардкодить
> (role_id может пересоздаваться при импорте):
> ```sql
> select role_id into l_id from apex_appl_acl_roles where application_id=N and role_static_id='admin';
> apex_acl.add_user_role(p_application_id=>N, p_user_name=>'CLAUDE', p_role_id=>l_id);  -- в apex_session.create_session(...)
> ```

## Два слоя (карта)

| Слой | Вопросы | Файл |
|---|---|---|
| **App-безопасность** | какая auth-схема; authorization scheme; ACL-роли; Security Attributes; CSP/сессии | [`references/security.md`](references/security.md) |
| **Деплой** | export типы (Standard/Runtime/Full/Custom); SQL vs APEXlang; import (Reuse ID!); Supporting Objects; Build Options | [`references/deploy.md`](references/deploy.md) |
| **Стенд (instance-админ)** | вход/восстановление `apex_admin`; SMTP (письма Human Task); джобы `DBMS_SCHEDULER`; бэкап; пользователи | [`references/stand-admin.md`](references/stand-admin.md) |

## Топ-факты

- **`APEX_ACL.ADD_USER_ROLE`** — на этой сборке 26.1 перегрузка `p_role_static_id` падает
  `ORA-01403` (проверено на app 200) → находить `role_id` по `static_id` в рантайме и звать
  `p_role_id` (портируемо — re-lookup каждый раз; хардкод role_id нельзя). `has_user_role` —
  только static-id форма (для проверок работает). Доки Oracle рекомендуют static_id — но на этом
  стенде эмпирика победила.
- **Имена пользователей APEX — ВЕРХНИЙ регистр** (governed by `p_uppercase_username` default TRUE).
  Participant/owner в нижнем → `ORA-20987`. Это же — мост к identity-bridge BAS→APEX.
- **`Reuse Application ID XX`** при импорте = **удаляет и заменяет** существующее приложение —
  осознанно.
- **Формат экспорта проекта — APEXlang** (`apex export -as-apexlang`, `.zip`); UI-импорт APEXlang
  требует ORDS 26.1.1+; постранично APEXlang через UI не импортируется → SQLcl.
- **Self-lockout**: включил `Disable Administrator Login` — назад только SQL:
  `APEX_INSTANCE_ADMIN.SET_PARAMETER('DISABLE_ADMIN_LOGIN','N')` как SYS (см. stand-admin.md).
- **SMTP не настроен → письма Human Task не уходят** (уведомления маршрутов висят на инстанс-SMTP).

## Границы

- Точные сигнатуры `apex_acl`/`apex_instance_admin`/`apex_web_service` — **`apex-plsql-apis`**
  (здесь — когда/зачем звать, не как).
- Роутинг/Human Task (`apex_workflow`) — **`apex-workflow`** (другая глава мануала).
- `.apx`, компиляция — **`apexlang`**. Пайплайн миграции — **`bas2apex`**.
- Мультитенант-хостинг (провижининг воркспейсов, изоляция, self-service) — **вне scope** (стенд
  одно-воркспейсный); упомянуто в stand-admin.md как «есть, не нужно».
