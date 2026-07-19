-- Батч 006: релаксація UNIQUE(CODE) перед завантаженням живих даних.
-- Причина: у 1С Code унікальний лише на рівні UI; історичні/предопределённые
-- записи його порушують. Тут seed-рядки (предопределённые з батча 003) і живі
-- записи OData ділять однаковий Code за різними UUID → ORA-00001 при MERGE.
-- Рішення (за skill data-track): знімаємо DB-UNIQUE, унікальність — рівня APEX.
-- Ідемпотентно (ігнорує відсутність constraint, ORA-02443). NLS_LANG=.AL32UTF8.
declare
    type pair is record (tbl varchar2(128), con varchar2(128));
    type pairs is table of pair;
    l pairs := pairs(
        pair('RSD_KATEGORIIDANNYKH', 'RSD_KATEGORIIDANNYKH_UK_CODE_'),
        pair('RSD_PAPKIFORUMA',      'RSD_PAPKIFORUMA_UK_CODE_'),
        pair('RSD_USLOVIYAZADACH',   'RSD_USLOVIYAZADACH_UK_CODE_'));
begin
    for i in 1 .. l.count loop
        begin
            execute immediate 'alter table ' || l(i).tbl || ' drop constraint ' || l(i).con;
            dbms_output.put_line('dropped ' || l(i).con);
        exception
            when others then
                if sqlcode = -2443 then dbms_output.put_line('absent ' || l(i).con);
                else raise; end if;
        end;
    end loop;
end;
/
