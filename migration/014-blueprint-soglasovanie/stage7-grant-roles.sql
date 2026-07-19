-- Stage 7 (частина 3): видача ролі ADMIN користувачам після import.
-- Імпортований застосунок має ACL-ролі, але без призначень → кожен логін
-- отримує «Немає доступу». apex_acl.add_user_role з p_role_id (не static_id:
-- static_id-оверлоад падає ORA-01403). Запускати як BAS_REVERSE.
set serveroutput on size unlimited
declare
    l_admin_role_id number;
begin
    dbms_output.put_line('=== ACL-ролі app 201 ===');
    for r in (select role_id, role_static_id, role_name
                from apex_appl_acl_roles where application_id = 201 order by role_id) loop
        dbms_output.put_line('  '||r.role_id||' / '||r.role_static_id||' / '||r.role_name);
    end loop;

    select role_id into l_admin_role_id
      from apex_appl_acl_roles
     where application_id = 201 and upper(role_static_id) = 'ADMIN';

    apex_session.create_session(p_app_id => 201, p_page_id => 1, p_username => 'CLAUDE');
    for u in (select column_value uname
                from table(sys.odcivarchar2list('CLAUDE','VIKTOR'))) loop
        begin
            apex_acl.add_user_role(p_application_id => 201,
                                   p_user_name      => u.uname,
                                   p_role_id        => l_admin_role_id);
            dbms_output.put_line('  granted ADMIN -> '||u.uname);
        exception when others then
            dbms_output.put_line('  grant '||u.uname||' failed: '||sqlerrm);
        end;
    end loop;
    commit;
end;
/
exit
