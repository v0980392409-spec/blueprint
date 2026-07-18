-- =============================================================================
-- Батч 002: замикання відкладених FK, які розблоковані перечисленнями.
-- Запускати ПІСЛЯ ddl.sql+seed.sql цього батча і ПІСЛЯ батча, що створив
-- таблицю-джерело. Ідемпотентний (перевірка на існування констрейнта).
-- Виконувати з NLS_LANG=.AL32UTF8.
-- =============================================================================

-- Батч 001 · RSD_ORGANIZATIONS.ENTITY_KIND_ID → Enum.ЮрФизЛицо (був §9.5 EXTERNAL,
-- обовʼязковий NOT NULL). Ціль — уніфікований RSD_ENUMS(ID); коректність типу
-- (enum_type='ЮрФизЛицо') забезпечує LOV на формі організації.
declare
    l_exists number;
begin
    select count(*) into l_exists from user_constraints
     where constraint_name = 'RSD_ORGANIZATIONS_FK_ENTITY_KIND';
    if l_exists = 0 then
        execute immediate
            'alter table RSD_ORGANIZATIONS add constraint RSD_ORGANIZATIONS_FK_ENTITY_KIND '
            || 'foreign key (ENTITY_KIND_ID) references RSD_ENUMS (ID)';
        dbms_output.put_line('RSD_ORGANIZATIONS_FK_ENTITY_KIND added');
    else
        dbms_output.put_line('RSD_ORGANIZATIONS_FK_ENTITY_KIND already exists');
    end if;
end;
/
