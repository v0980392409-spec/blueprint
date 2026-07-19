-- staging сирого OData JSON (ключ entity+ref_key). NLS_LANG=.AL32UTF8.
declare
    n number;
begin
    select count(*) into n from user_tables where table_name = 'RSD_ODATA_RAW';
    if n = 0 then
        execute immediate q'[
            create table RSD_ODATA_RAW (
                entity   varchar2(100 char) not null,
                ref_key  varchar2(36)       not null,
                doc      clob,
                loaded_at timestamp default systimestamp,
                constraint RSD_ODATA_RAW_PK primary key (entity, ref_key)
            )]';
    end if;
end;
/
