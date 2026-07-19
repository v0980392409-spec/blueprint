# Батч 015 — ролі не злітають після `apex import` (app 200)

Робить призначення ACL-ролей **детермінованими після кожного імпорту**: `grant-roles.sql`
(ідемпотентний) + `regrant.sh` (обгортка на стенд). Обов'язковий крок після `apex import`.

## Корінь проблеми (перевірено на стенді)

Access Control розрізняє дві речі:
- **Визначення ролей** (`admin`/`contributor`/`reader` + authorization schemes) — це метадані
  застосунку → лежать у `applications/budynky/shared-components/acl-roles.apx` і **їдуть** з `.apx`.
- **Призначення користувач→роль** (CLAUDE/VIKTOR → `admin`) — живуть у **метаданих APEX**
  (`apex_appl_acl_user_roles`), **НЕ** в `.apx` і **не** експортуються APEXlang'ом. Тому повний
  `apex import` (replace) їх втрачає, і застосунок дає «Немає доступу» усім.

## Знахідка (важлива, суперечить доці Oracle)

На **цій збірці APEX 26.1** перевантаження `apex_acl.add_user_role(p_role_static_id => 'admin')`
падає з **`ORA-01403: no data found`** (перевірено). Робочий шлях — `p_role_id`. Але хардкодити
`role_id` не можна (він може пересоздаватись при імпорті), тому:

> **Робоча й портируемая форма**: знайти `role_id` за `static_id` у рантаймі, звати `p_role_id`.
> ```sql
> select role_id into l_role_id from apex_appl_acl_roles
>  where application_id = 200 and role_static_id = 'admin';
> apex_acl.add_user_role(p_application_id => 200, p_user_name => 'CLAUDE', p_role_id => l_role_id);
> ```

(Офіційний фікс через **Supporting Objects Installation Script** — для SQL-формату/packaged-app.
Наш трек — APEXlang, застосунок не має Supporting Objects → правильний шлях тут — цей post-import
скрипт.)

## Артефакти

- **`grant-roles.sql`** — ідемпотентний: `@grant-roles.sql <APP_ID> <ROLE_STATIC_ID> <USERS_CSV>`,
  напр. `@grant-roles.sql 200 admin CLAUDE,VIKTOR`. Знаходить `role_id`, видає роль лише якщо її
  немає (інакше «вже має роль»). Під схемою **BAS_REVERSE** (не sysdba — треба APEX-контекст).
  Багаторазовий: годиться і для app 201, і для майбутнього 122 (передати свій app/role/users).
- **`regrant.sh`** — обгортка: заливає скрипт у контейнер ords і виконує на стенді.
  `./regrant.sh [APP_ID] [ROLE] [USERS]` (дефолт `200 admin CLAUDE,VIKTOR`).

## Як вбудувати в рутину імпорту

Після **кожного** `apex import` застосунку 200 (чи пересбору схеми) — одразу:
```bash
migration/016-acl-grant-fix/regrant.sh 200 admin CLAUDE,VIKTOR
```
Це обов'язковий фінальний крок деплою app 200. Ідемпотентний → безпечно ганяти завжди.

## Перевірка (що прогнано)

1. `apex_appl_acl_roles` app 200 → `admin`(role_id 9175702711962663)/`contributor`/`reader`;
   `apex_appl_acl_user_roles` → CLAUDE+VIKTOR = `admin` (created SYS).
2. Форми `add_user_role`: `p_role_static_id` → **FAIL ORA-01403**; `p_role_id` (lookup) → **OK**.
3. Цикл: зняти ролі CLAUDE/VIKTOR → 0 рядків → `grant-roles.sql` → **CLAUDE+VIKTOR знову `admin`**.
4. Ідемпотентність: повторний `regrant.sh` → «вже має роль admin — ok» (без помилок).

## Межі

- Живий повний `apex import` тут не проганявся (точна форма команди `-workspaceId` для цієї збірки
  в заметках суперечлива; ризикувати робочим пілотом заради того, що вже доведено зняттям ролей —
  зайве). Фікс детермінований у будь-якому разі: після імпорту скрипт або відновить, або
  зробить no-op.
- Ролі досі пілотні (CLAUDE/VIKTOR статичні). Продакшн — identity-bridge BAS→APEX (логіни 1С ↔
  APEX, ВЕРХНІЙ регістр) — окремий трек.
