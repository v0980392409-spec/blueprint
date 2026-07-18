-- =============================================================================
-- Батч 003: замикання відкладених FK батча 001, розблокованих цим батчем.
-- RSD_ORGANIZATIONS посилалась на Контрагенти й Банківські рахунки (цикл хвилі 4,
-- §9.5 батча 001) — тепер їхні таблиці існують. Ідемпотентний. NLS_LANG=.AL32UTF8.
-- =============================================================================
declare
    procedure add_fk(p_name varchar2, p_sql varchar2) is
        n number;
    begin
        select count(*) into n from user_constraints where constraint_name = p_name;
        if n = 0 then
            execute immediate p_sql;
            dbms_output.put_line(p_name || ' added');
        else
            dbms_output.put_line(p_name || ' already exists');
        end if;
    end;
begin
    add_fk('RSD_ORGANIZATIONS_FK_DEVELOPER',
        'alter table RSD_ORGANIZATIONS add constraint RSD_ORGANIZATIONS_FK_DEVELOPER '
        || 'foreign key (DEVELOPER_ID) references RSD_KONTRAGENTY (ID)');
    add_fk('RSD_ORGANIZATIONS_FK_BANK_ACCT',
        'alter table RSD_ORGANIZATIONS add constraint RSD_ORGANIZATIONS_FK_BANK_ACCT '
        || 'foreign key (MAIN_BANK_ACCOUNT_ID) references RSD_BANKOVSKIESCHETA (ID)');
end;
/
