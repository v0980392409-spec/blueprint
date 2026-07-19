-- =====================================================================
-- grant-roles.sql — идемпотентная перевыдача ACL-ролей после apex import
-- =====================================================================
-- Зачем: APEXlang-експорт (applications/<alias>/) НЕ тримає призначень
-- користувач→роль — вони живуть у метаданих APEX і не їдуть з .apx. Тому
-- після кожного `apex import` (або пересбору схеми) ролі треба перевидати.
-- Це — обов'язковий крок після імпорту (див. README).
--
-- ⚠️ На цій збірці APEX 26.1 перевантаження p_role_static_id падає з
--    ORA-01403 (перевірено). Робочий і портируемый шлях — знайти role_id за
--    static_id у рантаймі й звати p_role_id (role_id може пересоздаватись при
--    імпорті, тому саме LOOKUP, а не хардкод).
--
-- Запуск (SQLcl/sqlplus під схемою BAS_REVERSE, НЕ sysdba):
--   @grant-roles.sql <APP_ID> <ROLE_STATIC_ID> <USER1,USER2,...>
-- Приклад:
--   @grant-roles.sql 200 admin CLAUDE,VIKTOR
-- =====================================================================
define app_id  = &1
define role_sid = "&2"
define users   = "&3"
set serveroutput on size unlimited
set verify off feedback off
declare
  l_role_id number;
  l_users   apex_t_varchar2 := apex_string.split('&users.', ',');
  l_un      varchar2(100);
  l_dummy   number;
begin
  apex_session.create_session(p_app_id => &app_id., p_page_id => 1,
                              p_username => upper(trim(l_users(1))));
  select role_id into l_role_id
    from apex_appl_acl_roles
   where application_id = &app_id. and role_static_id = '&role_sid.';

  for i in 1 .. l_users.count loop
    l_un := upper(trim(l_users(i)));
    begin
      select 1 into l_dummy from apex_appl_acl_user_roles
       where application_id = &app_id. and user_name = l_un
         and role_id = l_role_id and rownum = 1;
      dbms_output.put_line(l_un || ': вже має роль &role_sid. — ok');
    exception when no_data_found then
      apex_acl.add_user_role(p_application_id => &app_id.,
                             p_user_name => l_un, p_role_id => l_role_id);
      dbms_output.put_line(l_un || ': видано роль &role_sid.');
    end;
  end loop;
  commit;
exception when no_data_found then
  raise_application_error(-20001,
    'Роль "&role_sid." не знайдена в app &app_id. (apex_appl_acl_roles). '||
    'Спершу імпортуй застосунок — визначення ролей у .apx.');
end;
/
undefine app_id
undefine role_sid
undefine users
