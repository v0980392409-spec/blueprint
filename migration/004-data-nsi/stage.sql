-- Батч 004: stage сирих даних НСІ у RSD_ODATA_RAW. NLS_LANG=.AL32UTF8.
-- Потрібен контекст APEX-сесії (Web Credential BAS_DOC_CRED):
exec apex_session.create_session(p_app_id=>200, p_page_id=>1, p_username=>'CLAUDE');
set serveroutput on

-- Catalog.Контрагенты
declare
    l_clob clob; l_got number;
    l_last varchar2(36) := '00000000-0000-0000-0000-000000000000';
    l_next varchar2(36);
begin
    loop
        l_clob := apex_web_service.make_rest_request(
            p_url => 'https://rv.entercom.ua:5683/bas_doc/odata/standard.odata/Catalog_%D0%9A%D0%BE%D0%BD%D1%82%D1%80%D0%B0%D0%B3%D0%B5%D0%BD%D1%82%D1%8B?$format=json&$top=500'
                  || '&$orderby=Ref_Key%20asc&$filter=Ref_Key%20gt%20%27' || l_last || '%27',
            p_http_method => 'GET', p_credential_static_id => 'BAS_DOC_CRED',
            p_transfer_timeout => 120);
        select count(*), max(rk) into l_got, l_next
          from json_table(l_clob, '$.value[*]' columns (rk varchar2(36) path '$.Ref_Key'));
        exit when l_got = 0;
        merge into rsd_odata_raw t using (
            select rk, dc from json_table(l_clob, '$.value[*]' columns (
                rk varchar2(36) path '$.Ref_Key',
                dc clob format json path '$'))
        ) s on (t.entity = 'Catalog.Контрагенты' and t.ref_key = s.rk)
        when matched then update set t.doc = s.dc, t.loaded_at = systimestamp
        when not matched then insert (entity, ref_key, doc) values ('Catalog.Контрагенты', s.rk, s.dc);
        commit;
        exit when l_next = l_last;   -- курсор не зрушив — кінець
        l_last := l_next;
    end loop;
    dbms_output.put_line('Catalog.Контрагенты: staged');
end;
/

-- Catalog.Пользователи
declare
    l_clob clob; l_got number;
    l_last varchar2(36) := '00000000-0000-0000-0000-000000000000';
    l_next varchar2(36);
begin
    loop
        l_clob := apex_web_service.make_rest_request(
            p_url => 'https://rv.entercom.ua:5683/bas_doc/odata/standard.odata/Catalog_%D0%9F%D0%BE%D0%BB%D1%8C%D0%B7%D0%BE%D0%B2%D0%B0%D1%82%D0%B5%D0%BB%D0%B8?$format=json&$top=500'
                  || '&$orderby=Ref_Key%20asc&$filter=Ref_Key%20gt%20%27' || l_last || '%27',
            p_http_method => 'GET', p_credential_static_id => 'BAS_DOC_CRED',
            p_transfer_timeout => 120);
        select count(*), max(rk) into l_got, l_next
          from json_table(l_clob, '$.value[*]' columns (rk varchar2(36) path '$.Ref_Key'));
        exit when l_got = 0;
        merge into rsd_odata_raw t using (
            select rk, dc from json_table(l_clob, '$.value[*]' columns (
                rk varchar2(36) path '$.Ref_Key',
                dc clob format json path '$'))
        ) s on (t.entity = 'Catalog.Пользователи' and t.ref_key = s.rk)
        when matched then update set t.doc = s.dc, t.loaded_at = systimestamp
        when not matched then insert (entity, ref_key, doc) values ('Catalog.Пользователи', s.rk, s.dc);
        commit;
        exit when l_next = l_last;   -- курсор не зрушив — кінець
        l_last := l_next;
    end loop;
    dbms_output.put_line('Catalog.Пользователи: staged');
end;
/

-- Catalog.ФизическиеЛица
declare
    l_clob clob; l_got number;
    l_last varchar2(36) := '00000000-0000-0000-0000-000000000000';
    l_next varchar2(36);
begin
    loop
        l_clob := apex_web_service.make_rest_request(
            p_url => 'https://rv.entercom.ua:5683/bas_doc/odata/standard.odata/Catalog_%D0%A4%D0%B8%D0%B7%D0%B8%D1%87%D0%B5%D1%81%D0%BA%D0%B8%D0%B5%D0%9B%D0%B8%D1%86%D0%B0?$format=json&$top=500'
                  || '&$orderby=Ref_Key%20asc&$filter=Ref_Key%20gt%20%27' || l_last || '%27',
            p_http_method => 'GET', p_credential_static_id => 'BAS_DOC_CRED',
            p_transfer_timeout => 120);
        select count(*), max(rk) into l_got, l_next
          from json_table(l_clob, '$.value[*]' columns (rk varchar2(36) path '$.Ref_Key'));
        exit when l_got = 0;
        merge into rsd_odata_raw t using (
            select rk, dc from json_table(l_clob, '$.value[*]' columns (
                rk varchar2(36) path '$.Ref_Key',
                dc clob format json path '$'))
        ) s on (t.entity = 'Catalog.ФизическиеЛица' and t.ref_key = s.rk)
        when matched then update set t.doc = s.dc, t.loaded_at = systimestamp
        when not matched then insert (entity, ref_key, doc) values ('Catalog.ФизическиеЛица', s.rk, s.dc);
        commit;
        exit when l_next = l_last;   -- курсор не зрушив — кінець
        l_last := l_next;
    end loop;
    dbms_output.put_line('Catalog.ФизическиеЛица: staged');
end;
/

-- Catalog.БанковскиеСчета
declare
    l_clob clob; l_got number;
    l_last varchar2(36) := '00000000-0000-0000-0000-000000000000';
    l_next varchar2(36);
begin
    loop
        l_clob := apex_web_service.make_rest_request(
            p_url => 'https://rv.entercom.ua:5683/bas_doc/odata/standard.odata/Catalog_%D0%91%D0%B0%D0%BD%D0%BA%D0%BE%D0%B2%D1%81%D0%BA%D0%B8%D0%B5%D0%A1%D1%87%D0%B5%D1%82%D0%B0?$format=json&$top=500'
                  || '&$orderby=Ref_Key%20asc&$filter=Ref_Key%20gt%20%27' || l_last || '%27',
            p_http_method => 'GET', p_credential_static_id => 'BAS_DOC_CRED',
            p_transfer_timeout => 120);
        select count(*), max(rk) into l_got, l_next
          from json_table(l_clob, '$.value[*]' columns (rk varchar2(36) path '$.Ref_Key'));
        exit when l_got = 0;
        merge into rsd_odata_raw t using (
            select rk, dc from json_table(l_clob, '$.value[*]' columns (
                rk varchar2(36) path '$.Ref_Key',
                dc clob format json path '$'))
        ) s on (t.entity = 'Catalog.БанковскиеСчета' and t.ref_key = s.rk)
        when matched then update set t.doc = s.dc, t.loaded_at = systimestamp
        when not matched then insert (entity, ref_key, doc) values ('Catalog.БанковскиеСчета', s.rk, s.dc);
        commit;
        exit when l_next = l_last;   -- курсор не зрушив — кінець
        l_last := l_next;
    end loop;
    dbms_output.put_line('Catalog.БанковскиеСчета: staged');
end;
/

-- Catalog.Валюты
declare
    l_clob clob; l_got number;
    l_last varchar2(36) := '00000000-0000-0000-0000-000000000000';
    l_next varchar2(36);
begin
    loop
        l_clob := apex_web_service.make_rest_request(
            p_url => 'https://rv.entercom.ua:5683/bas_doc/odata/standard.odata/Catalog_%D0%92%D0%B0%D0%BB%D1%8E%D1%82%D1%8B?$format=json&$top=500'
                  || '&$orderby=Ref_Key%20asc&$filter=Ref_Key%20gt%20%27' || l_last || '%27',
            p_http_method => 'GET', p_credential_static_id => 'BAS_DOC_CRED',
            p_transfer_timeout => 120);
        select count(*), max(rk) into l_got, l_next
          from json_table(l_clob, '$.value[*]' columns (rk varchar2(36) path '$.Ref_Key'));
        exit when l_got = 0;
        merge into rsd_odata_raw t using (
            select rk, dc from json_table(l_clob, '$.value[*]' columns (
                rk varchar2(36) path '$.Ref_Key',
                dc clob format json path '$'))
        ) s on (t.entity = 'Catalog.Валюты' and t.ref_key = s.rk)
        when matched then update set t.doc = s.dc, t.loaded_at = systimestamp
        when not matched then insert (entity, ref_key, doc) values ('Catalog.Валюты', s.rk, s.dc);
        commit;
        exit when l_next = l_last;   -- курсор не зрушив — кінець
        l_last := l_next;
    end loop;
    dbms_output.put_line('Catalog.Валюты: staged');
end;
/
