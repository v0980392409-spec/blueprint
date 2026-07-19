-- Батч 004: stage сирих даних НСІ у RSD_ODATA_RAW. NLS_LANG=.AL32UTF8.
-- Потрібен контекст APEX-сесії (Web Credential BAS_DOC_CRED):
exec apex_session.create_session(p_app_id=>200, p_page_id=>1, p_username=>'CLAUDE');
set serveroutput on

-- Catalog.УсловияМаршрутизации
declare
    l_clob clob; l_got number; l_skip number := 0;
begin
    loop
        l_clob := apex_web_service.make_rest_request(
            p_url => 'https://rv.entercom.ua:5683/bas_doc/odata/standard.odata/Catalog_%D0%A3%D1%81%D0%BB%D0%BE%D0%B2%D0%B8%D1%8F%D0%9C%D0%B0%D1%80%D1%88%D1%80%D1%83%D1%82%D0%B8%D0%B7%D0%B0%D1%86%D0%B8%D0%B8?$format=json&$top=500&$skip=' || l_skip,
            p_http_method => 'GET', p_credential_static_id => 'BAS_DOC_CRED',
            p_transfer_timeout => 120);
        select count(*) into l_got
          from json_table(l_clob, '$.value[*]' columns (rk varchar2(36) path '$.Ref_Key'));
        exit when l_got = 0;
        merge into rsd_odata_raw t using (
            select rk, dc from json_table(l_clob, '$.value[*]' columns (
                rk varchar2(36) path '$.Ref_Key',
                dc clob format json path '$'))
        ) s on (t.entity = 'Catalog.УсловияМаршрутизации' and t.ref_key = s.rk)
        when matched then update set t.doc = s.dc, t.loaded_at = systimestamp
        when not matched then insert (entity, ref_key, doc) values ('Catalog.УсловияМаршрутизации', s.rk, s.dc);
        commit;
        l_skip := l_skip + 500;
        exit when l_got < 500;   -- остання (неповна) сторінка
    end loop;
    dbms_output.put_line('Catalog.УсловияМаршрутизации: staged ' || l_skip);
end;
/

-- Catalog.ВидыВходящихДокументов
declare
    l_clob clob; l_got number; l_skip number := 0;
begin
    loop
        l_clob := apex_web_service.make_rest_request(
            p_url => 'https://rv.entercom.ua:5683/bas_doc/odata/standard.odata/Catalog_%D0%92%D0%B8%D0%B4%D1%8B%D0%92%D1%85%D0%BE%D0%B4%D1%8F%D1%89%D0%B8%D1%85%D0%94%D0%BE%D0%BA%D1%83%D0%BC%D0%B5%D0%BD%D1%82%D0%BE%D0%B2?$format=json&$top=500&$skip=' || l_skip,
            p_http_method => 'GET', p_credential_static_id => 'BAS_DOC_CRED',
            p_transfer_timeout => 120);
        select count(*) into l_got
          from json_table(l_clob, '$.value[*]' columns (rk varchar2(36) path '$.Ref_Key'));
        exit when l_got = 0;
        merge into rsd_odata_raw t using (
            select rk, dc from json_table(l_clob, '$.value[*]' columns (
                rk varchar2(36) path '$.Ref_Key',
                dc clob format json path '$'))
        ) s on (t.entity = 'Catalog.ВидыВходящихДокументов' and t.ref_key = s.rk)
        when matched then update set t.doc = s.dc, t.loaded_at = systimestamp
        when not matched then insert (entity, ref_key, doc) values ('Catalog.ВидыВходящихДокументов', s.rk, s.dc);
        commit;
        l_skip := l_skip + 500;
        exit when l_got < 500;   -- остання (неповна) сторінка
    end loop;
    dbms_output.put_line('Catalog.ВидыВходящихДокументов: staged ' || l_skip);
end;
/

-- Catalog.СтруктураПредприятия
declare
    l_clob clob; l_got number; l_skip number := 0;
begin
    loop
        l_clob := apex_web_service.make_rest_request(
            p_url => 'https://rv.entercom.ua:5683/bas_doc/odata/standard.odata/Catalog_%D0%A1%D1%82%D1%80%D1%83%D0%BA%D1%82%D1%83%D1%80%D0%B0%D0%9F%D1%80%D0%B5%D0%B4%D0%BF%D1%80%D0%B8%D1%8F%D1%82%D0%B8%D1%8F?$format=json&$top=500&$skip=' || l_skip,
            p_http_method => 'GET', p_credential_static_id => 'BAS_DOC_CRED',
            p_transfer_timeout => 120);
        select count(*) into l_got
          from json_table(l_clob, '$.value[*]' columns (rk varchar2(36) path '$.Ref_Key'));
        exit when l_got = 0;
        merge into rsd_odata_raw t using (
            select rk, dc from json_table(l_clob, '$.value[*]' columns (
                rk varchar2(36) path '$.Ref_Key',
                dc clob format json path '$'))
        ) s on (t.entity = 'Catalog.СтруктураПредприятия' and t.ref_key = s.rk)
        when matched then update set t.doc = s.dc, t.loaded_at = systimestamp
        when not matched then insert (entity, ref_key, doc) values ('Catalog.СтруктураПредприятия', s.rk, s.dc);
        commit;
        l_skip := l_skip + 500;
        exit when l_got < 500;   -- остання (неповна) сторінка
    end loop;
    dbms_output.put_line('Catalog.СтруктураПредприятия: staged ' || l_skip);
end;
/

-- Catalog.ВидыВнутреннихДокументов
declare
    l_clob clob; l_got number; l_skip number := 0;
begin
    loop
        l_clob := apex_web_service.make_rest_request(
            p_url => 'https://rv.entercom.ua:5683/bas_doc/odata/standard.odata/Catalog_%D0%92%D0%B8%D0%B4%D1%8B%D0%92%D0%BD%D1%83%D1%82%D1%80%D0%B5%D0%BD%D0%BD%D0%B8%D1%85%D0%94%D0%BE%D0%BA%D1%83%D0%BC%D0%B5%D0%BD%D1%82%D0%BE%D0%B2?$format=json&$top=500&$skip=' || l_skip,
            p_http_method => 'GET', p_credential_static_id => 'BAS_DOC_CRED',
            p_transfer_timeout => 120);
        select count(*) into l_got
          from json_table(l_clob, '$.value[*]' columns (rk varchar2(36) path '$.Ref_Key'));
        exit when l_got = 0;
        merge into rsd_odata_raw t using (
            select rk, dc from json_table(l_clob, '$.value[*]' columns (
                rk varchar2(36) path '$.Ref_Key',
                dc clob format json path '$'))
        ) s on (t.entity = 'Catalog.ВидыВнутреннихДокументов' and t.ref_key = s.rk)
        when matched then update set t.doc = s.dc, t.loaded_at = systimestamp
        when not matched then insert (entity, ref_key, doc) values ('Catalog.ВидыВнутреннихДокументов', s.rk, s.dc);
        commit;
        l_skip := l_skip + 500;
        exit when l_got < 500;   -- остання (неповна) сторінка
    end loop;
    dbms_output.put_line('Catalog.ВидыВнутреннихДокументов: staged ' || l_skip);
end;
/

-- Catalog.ПрофилиГруппДоступа
declare
    l_clob clob; l_got number; l_skip number := 0;
begin
    loop
        l_clob := apex_web_service.make_rest_request(
            p_url => 'https://rv.entercom.ua:5683/bas_doc/odata/standard.odata/Catalog_%D0%9F%D1%80%D0%BE%D1%84%D0%B8%D0%BB%D0%B8%D0%93%D1%80%D1%83%D0%BF%D0%BF%D0%94%D0%BE%D1%81%D1%82%D1%83%D0%BF%D0%B0?$format=json&$top=500&$skip=' || l_skip,
            p_http_method => 'GET', p_credential_static_id => 'BAS_DOC_CRED',
            p_transfer_timeout => 120);
        select count(*) into l_got
          from json_table(l_clob, '$.value[*]' columns (rk varchar2(36) path '$.Ref_Key'));
        exit when l_got = 0;
        merge into rsd_odata_raw t using (
            select rk, dc from json_table(l_clob, '$.value[*]' columns (
                rk varchar2(36) path '$.Ref_Key',
                dc clob format json path '$'))
        ) s on (t.entity = 'Catalog.ПрофилиГруппДоступа' and t.ref_key = s.rk)
        when matched then update set t.doc = s.dc, t.loaded_at = systimestamp
        when not matched then insert (entity, ref_key, doc) values ('Catalog.ПрофилиГруппДоступа', s.rk, s.dc);
        commit;
        l_skip := l_skip + 500;
        exit when l_got < 500;   -- остання (неповна) сторінка
    end loop;
    dbms_output.put_line('Catalog.ПрофилиГруппДоступа: staged ' || l_skip);
end;
/

-- Catalog.РабочиеГруппы
declare
    l_clob clob; l_got number; l_skip number := 0;
begin
    loop
        l_clob := apex_web_service.make_rest_request(
            p_url => 'https://rv.entercom.ua:5683/bas_doc/odata/standard.odata/Catalog_%D0%A0%D0%B0%D0%B1%D0%BE%D1%87%D0%B8%D0%B5%D0%93%D1%80%D1%83%D0%BF%D0%BF%D1%8B?$format=json&$top=500&$skip=' || l_skip,
            p_http_method => 'GET', p_credential_static_id => 'BAS_DOC_CRED',
            p_transfer_timeout => 120);
        select count(*) into l_got
          from json_table(l_clob, '$.value[*]' columns (rk varchar2(36) path '$.Ref_Key'));
        exit when l_got = 0;
        merge into rsd_odata_raw t using (
            select rk, dc from json_table(l_clob, '$.value[*]' columns (
                rk varchar2(36) path '$.Ref_Key',
                dc clob format json path '$'))
        ) s on (t.entity = 'Catalog.РабочиеГруппы' and t.ref_key = s.rk)
        when matched then update set t.doc = s.dc, t.loaded_at = systimestamp
        when not matched then insert (entity, ref_key, doc) values ('Catalog.РабочиеГруппы', s.rk, s.dc);
        commit;
        l_skip := l_skip + 500;
        exit when l_got < 500;   -- остання (неповна) сторінка
    end loop;
    dbms_output.put_line('Catalog.РабочиеГруппы: staged ' || l_skip);
end;
/

-- Catalog.ТерриторииИПомещения
declare
    l_clob clob; l_got number; l_skip number := 0;
begin
    loop
        l_clob := apex_web_service.make_rest_request(
            p_url => 'https://rv.entercom.ua:5683/bas_doc/odata/standard.odata/Catalog_%D0%A2%D0%B5%D1%80%D1%80%D0%B8%D1%82%D0%BE%D1%80%D0%B8%D0%B8%D0%98%D0%9F%D0%BE%D0%BC%D0%B5%D1%89%D0%B5%D0%BD%D0%B8%D1%8F?$format=json&$top=500&$skip=' || l_skip,
            p_http_method => 'GET', p_credential_static_id => 'BAS_DOC_CRED',
            p_transfer_timeout => 120);
        select count(*) into l_got
          from json_table(l_clob, '$.value[*]' columns (rk varchar2(36) path '$.Ref_Key'));
        exit when l_got = 0;
        merge into rsd_odata_raw t using (
            select rk, dc from json_table(l_clob, '$.value[*]' columns (
                rk varchar2(36) path '$.Ref_Key',
                dc clob format json path '$'))
        ) s on (t.entity = 'Catalog.ТерриторииИПомещения' and t.ref_key = s.rk)
        when matched then update set t.doc = s.dc, t.loaded_at = systimestamp
        when not matched then insert (entity, ref_key, doc) values ('Catalog.ТерриторииИПомещения', s.rk, s.dc);
        commit;
        l_skip := l_skip + 500;
        exit when l_got < 500;   -- остання (неповна) сторінка
    end loop;
    dbms_output.put_line('Catalog.ТерриторииИПомещения: staged ' || l_skip);
end;
/

-- Catalog.ПапкиВнутреннихДокументов
declare
    l_clob clob; l_got number; l_skip number := 0;
begin
    loop
        l_clob := apex_web_service.make_rest_request(
            p_url => 'https://rv.entercom.ua:5683/bas_doc/odata/standard.odata/Catalog_%D0%9F%D0%B0%D0%BF%D0%BA%D0%B8%D0%92%D0%BD%D1%83%D1%82%D1%80%D0%B5%D0%BD%D0%BD%D0%B8%D1%85%D0%94%D0%BE%D0%BA%D1%83%D0%BC%D0%B5%D0%BD%D1%82%D0%BE%D0%B2?$format=json&$top=500&$skip=' || l_skip,
            p_http_method => 'GET', p_credential_static_id => 'BAS_DOC_CRED',
            p_transfer_timeout => 120);
        select count(*) into l_got
          from json_table(l_clob, '$.value[*]' columns (rk varchar2(36) path '$.Ref_Key'));
        exit when l_got = 0;
        merge into rsd_odata_raw t using (
            select rk, dc from json_table(l_clob, '$.value[*]' columns (
                rk varchar2(36) path '$.Ref_Key',
                dc clob format json path '$'))
        ) s on (t.entity = 'Catalog.ПапкиВнутреннихДокументов' and t.ref_key = s.rk)
        when matched then update set t.doc = s.dc, t.loaded_at = systimestamp
        when not matched then insert (entity, ref_key, doc) values ('Catalog.ПапкиВнутреннихДокументов', s.rk, s.dc);
        commit;
        l_skip := l_skip + 500;
        exit when l_got < 500;   -- остання (неповна) сторінка
    end loop;
    dbms_output.put_line('Catalog.ПапкиВнутреннихДокументов: staged ' || l_skip);
end;
/

-- Catalog.УсловияЗадач
declare
    l_clob clob; l_got number; l_skip number := 0;
begin
    loop
        l_clob := apex_web_service.make_rest_request(
            p_url => 'https://rv.entercom.ua:5683/bas_doc/odata/standard.odata/Catalog_%D0%A3%D1%81%D0%BB%D0%BE%D0%B2%D0%B8%D1%8F%D0%97%D0%B0%D0%B4%D0%B0%D1%87?$format=json&$top=500&$skip=' || l_skip,
            p_http_method => 'GET', p_credential_static_id => 'BAS_DOC_CRED',
            p_transfer_timeout => 120);
        select count(*) into l_got
          from json_table(l_clob, '$.value[*]' columns (rk varchar2(36) path '$.Ref_Key'));
        exit when l_got = 0;
        merge into rsd_odata_raw t using (
            select rk, dc from json_table(l_clob, '$.value[*]' columns (
                rk varchar2(36) path '$.Ref_Key',
                dc clob format json path '$'))
        ) s on (t.entity = 'Catalog.УсловияЗадач' and t.ref_key = s.rk)
        when matched then update set t.doc = s.dc, t.loaded_at = systimestamp
        when not matched then insert (entity, ref_key, doc) values ('Catalog.УсловияЗадач', s.rk, s.dc);
        commit;
        l_skip := l_skip + 500;
        exit when l_got < 500;   -- остання (неповна) сторінка
    end loop;
    dbms_output.put_line('Catalog.УсловияЗадач: staged ' || l_skip);
end;
/

-- Catalog.ВидыИсходящихДокументов
declare
    l_clob clob; l_got number; l_skip number := 0;
begin
    loop
        l_clob := apex_web_service.make_rest_request(
            p_url => 'https://rv.entercom.ua:5683/bas_doc/odata/standard.odata/Catalog_%D0%92%D0%B8%D0%B4%D1%8B%D0%98%D1%81%D1%85%D0%BE%D0%B4%D1%8F%D1%89%D0%B8%D1%85%D0%94%D0%BE%D0%BA%D1%83%D0%BC%D0%B5%D0%BD%D1%82%D0%BE%D0%B2?$format=json&$top=500&$skip=' || l_skip,
            p_http_method => 'GET', p_credential_static_id => 'BAS_DOC_CRED',
            p_transfer_timeout => 120);
        select count(*) into l_got
          from json_table(l_clob, '$.value[*]' columns (rk varchar2(36) path '$.Ref_Key'));
        exit when l_got = 0;
        merge into rsd_odata_raw t using (
            select rk, dc from json_table(l_clob, '$.value[*]' columns (
                rk varchar2(36) path '$.Ref_Key',
                dc clob format json path '$'))
        ) s on (t.entity = 'Catalog.ВидыИсходящихДокументов' and t.ref_key = s.rk)
        when matched then update set t.doc = s.dc, t.loaded_at = systimestamp
        when not matched then insert (entity, ref_key, doc) values ('Catalog.ВидыИсходящихДокументов', s.rk, s.dc);
        commit;
        l_skip := l_skip + 500;
        exit when l_got < 500;   -- остання (неповна) сторінка
    end loop;
    dbms_output.put_line('Catalog.ВидыИсходящихДокументов: staged ' || l_skip);
end;
/

-- Catalog.Нумераторы
declare
    l_clob clob; l_got number; l_skip number := 0;
begin
    loop
        l_clob := apex_web_service.make_rest_request(
            p_url => 'https://rv.entercom.ua:5683/bas_doc/odata/standard.odata/Catalog_%D0%9D%D1%83%D0%BC%D0%B5%D1%80%D0%B0%D1%82%D0%BE%D1%80%D1%8B?$format=json&$top=500&$skip=' || l_skip,
            p_http_method => 'GET', p_credential_static_id => 'BAS_DOC_CRED',
            p_transfer_timeout => 120);
        select count(*) into l_got
          from json_table(l_clob, '$.value[*]' columns (rk varchar2(36) path '$.Ref_Key'));
        exit when l_got = 0;
        merge into rsd_odata_raw t using (
            select rk, dc from json_table(l_clob, '$.value[*]' columns (
                rk varchar2(36) path '$.Ref_Key',
                dc clob format json path '$'))
        ) s on (t.entity = 'Catalog.Нумераторы' and t.ref_key = s.rk)
        when matched then update set t.doc = s.dc, t.loaded_at = systimestamp
        when not matched then insert (entity, ref_key, doc) values ('Catalog.Нумераторы', s.rk, s.dc);
        commit;
        l_skip := l_skip + 500;
        exit when l_got < 500;   -- остання (неповна) сторінка
    end loop;
    dbms_output.put_line('Catalog.Нумераторы: staged ' || l_skip);
end;
/

-- Catalog.ПапкиФорума
declare
    l_clob clob; l_got number; l_skip number := 0;
begin
    loop
        l_clob := apex_web_service.make_rest_request(
            p_url => 'https://rv.entercom.ua:5683/bas_doc/odata/standard.odata/Catalog_%D0%9F%D0%B0%D0%BF%D0%BA%D0%B8%D0%A4%D0%BE%D1%80%D1%83%D0%BC%D0%B0?$format=json&$top=500&$skip=' || l_skip,
            p_http_method => 'GET', p_credential_static_id => 'BAS_DOC_CRED',
            p_transfer_timeout => 120);
        select count(*) into l_got
          from json_table(l_clob, '$.value[*]' columns (rk varchar2(36) path '$.Ref_Key'));
        exit when l_got = 0;
        merge into rsd_odata_raw t using (
            select rk, dc from json_table(l_clob, '$.value[*]' columns (
                rk varchar2(36) path '$.Ref_Key',
                dc clob format json path '$'))
        ) s on (t.entity = 'Catalog.ПапкиФорума' and t.ref_key = s.rk)
        when matched then update set t.doc = s.dc, t.loaded_at = systimestamp
        when not matched then insert (entity, ref_key, doc) values ('Catalog.ПапкиФорума', s.rk, s.dc);
        commit;
        l_skip := l_skip + 500;
        exit when l_got < 500;   -- остання (неповна) сторінка
    end loop;
    dbms_output.put_line('Catalog.ПапкиФорума: staged ' || l_skip);
end;
/

-- Catalog.КатегорииДанных
declare
    l_clob clob; l_got number; l_skip number := 0;
begin
    loop
        l_clob := apex_web_service.make_rest_request(
            p_url => 'https://rv.entercom.ua:5683/bas_doc/odata/standard.odata/Catalog_%D0%9A%D0%B0%D1%82%D0%B5%D0%B3%D0%BE%D1%80%D0%B8%D0%B8%D0%94%D0%B0%D0%BD%D0%BD%D1%8B%D1%85?$format=json&$top=500&$skip=' || l_skip,
            p_http_method => 'GET', p_credential_static_id => 'BAS_DOC_CRED',
            p_transfer_timeout => 120);
        select count(*) into l_got
          from json_table(l_clob, '$.value[*]' columns (rk varchar2(36) path '$.Ref_Key'));
        exit when l_got = 0;
        merge into rsd_odata_raw t using (
            select rk, dc from json_table(l_clob, '$.value[*]' columns (
                rk varchar2(36) path '$.Ref_Key',
                dc clob format json path '$'))
        ) s on (t.entity = 'Catalog.КатегорииДанных' and t.ref_key = s.rk)
        when matched then update set t.doc = s.dc, t.loaded_at = systimestamp
        when not matched then insert (entity, ref_key, doc) values ('Catalog.КатегорииДанных', s.rk, s.dc);
        commit;
        l_skip := l_skip + 500;
        exit when l_got < 500;   -- остання (неповна) сторінка
    end loop;
    dbms_output.put_line('Catalog.КатегорииДанных: staged ' || l_skip);
end;
/

-- Catalog.Должности
declare
    l_clob clob; l_got number; l_skip number := 0;
begin
    loop
        l_clob := apex_web_service.make_rest_request(
            p_url => 'https://rv.entercom.ua:5683/bas_doc/odata/standard.odata/Catalog_%D0%94%D0%BE%D0%BB%D0%B6%D0%BD%D0%BE%D1%81%D1%82%D0%B8?$format=json&$top=500&$skip=' || l_skip,
            p_http_method => 'GET', p_credential_static_id => 'BAS_DOC_CRED',
            p_transfer_timeout => 120);
        select count(*) into l_got
          from json_table(l_clob, '$.value[*]' columns (rk varchar2(36) path '$.Ref_Key'));
        exit when l_got = 0;
        merge into rsd_odata_raw t using (
            select rk, dc from json_table(l_clob, '$.value[*]' columns (
                rk varchar2(36) path '$.Ref_Key',
                dc clob format json path '$'))
        ) s on (t.entity = 'Catalog.Должности' and t.ref_key = s.rk)
        when matched then update set t.doc = s.dc, t.loaded_at = systimestamp
        when not matched then insert (entity, ref_key, doc) values ('Catalog.Должности', s.rk, s.dc);
        commit;
        l_skip := l_skip + 500;
        exit when l_got < 500;   -- остання (неповна) сторінка
    end loop;
    dbms_output.put_line('Catalog.Должности: staged ' || l_skip);
end;
/

-- Catalog.ШаблоныТекстов
declare
    l_clob clob; l_got number; l_skip number := 0;
begin
    loop
        l_clob := apex_web_service.make_rest_request(
            p_url => 'https://rv.entercom.ua:5683/bas_doc/odata/standard.odata/Catalog_%D0%A8%D0%B0%D0%B1%D0%BB%D0%BE%D0%BD%D1%8B%D0%A2%D0%B5%D0%BA%D1%81%D1%82%D0%BE%D0%B2?$format=json&$top=500&$skip=' || l_skip,
            p_http_method => 'GET', p_credential_static_id => 'BAS_DOC_CRED',
            p_transfer_timeout => 120);
        select count(*) into l_got
          from json_table(l_clob, '$.value[*]' columns (rk varchar2(36) path '$.Ref_Key'));
        exit when l_got = 0;
        merge into rsd_odata_raw t using (
            select rk, dc from json_table(l_clob, '$.value[*]' columns (
                rk varchar2(36) path '$.Ref_Key',
                dc clob format json path '$'))
        ) s on (t.entity = 'Catalog.ШаблоныТекстов' and t.ref_key = s.rk)
        when matched then update set t.doc = s.dc, t.loaded_at = systimestamp
        when not matched then insert (entity, ref_key, doc) values ('Catalog.ШаблоныТекстов', s.rk, s.dc);
        commit;
        l_skip := l_skip + 500;
        exit when l_got < 500;   -- остання (неповна) сторінка
    end loop;
    dbms_output.put_line('Catalog.ШаблоныТекстов: staged ' || l_skip);
end;
/

-- Catalog.ГруппыДоступаКонтрагентов
declare
    l_clob clob; l_got number; l_skip number := 0;
begin
    loop
        l_clob := apex_web_service.make_rest_request(
            p_url => 'https://rv.entercom.ua:5683/bas_doc/odata/standard.odata/Catalog_%D0%93%D1%80%D1%83%D0%BF%D0%BF%D1%8B%D0%94%D0%BE%D1%81%D1%82%D1%83%D0%BF%D0%B0%D0%9A%D0%BE%D0%BD%D1%82%D1%80%D0%B0%D0%B3%D0%B5%D0%BD%D1%82%D0%BE%D0%B2?$format=json&$top=500&$skip=' || l_skip,
            p_http_method => 'GET', p_credential_static_id => 'BAS_DOC_CRED',
            p_transfer_timeout => 120);
        select count(*) into l_got
          from json_table(l_clob, '$.value[*]' columns (rk varchar2(36) path '$.Ref_Key'));
        exit when l_got = 0;
        merge into rsd_odata_raw t using (
            select rk, dc from json_table(l_clob, '$.value[*]' columns (
                rk varchar2(36) path '$.Ref_Key',
                dc clob format json path '$'))
        ) s on (t.entity = 'Catalog.ГруппыДоступаКонтрагентов' and t.ref_key = s.rk)
        when matched then update set t.doc = s.dc, t.loaded_at = systimestamp
        when not matched then insert (entity, ref_key, doc) values ('Catalog.ГруппыДоступаКонтрагентов', s.rk, s.dc);
        commit;
        l_skip := l_skip + 500;
        exit when l_got < 500;   -- остання (неповна) сторінка
    end loop;
    dbms_output.put_line('Catalog.ГруппыДоступаКонтрагентов: staged ' || l_skip);
end;
/

-- Catalog.ГрафикиРаботы
declare
    l_clob clob; l_got number; l_skip number := 0;
begin
    loop
        l_clob := apex_web_service.make_rest_request(
            p_url => 'https://rv.entercom.ua:5683/bas_doc/odata/standard.odata/Catalog_%D0%93%D1%80%D0%B0%D1%84%D0%B8%D0%BA%D0%B8%D0%A0%D0%B0%D0%B1%D0%BE%D1%82%D1%8B?$format=json&$top=500&$skip=' || l_skip,
            p_http_method => 'GET', p_credential_static_id => 'BAS_DOC_CRED',
            p_transfer_timeout => 120);
        select count(*) into l_got
          from json_table(l_clob, '$.value[*]' columns (rk varchar2(36) path '$.Ref_Key'));
        exit when l_got = 0;
        merge into rsd_odata_raw t using (
            select rk, dc from json_table(l_clob, '$.value[*]' columns (
                rk varchar2(36) path '$.Ref_Key',
                dc clob format json path '$'))
        ) s on (t.entity = 'Catalog.ГрафикиРаботы' and t.ref_key = s.rk)
        when matched then update set t.doc = s.dc, t.loaded_at = systimestamp
        when not matched then insert (entity, ref_key, doc) values ('Catalog.ГрафикиРаботы', s.rk, s.dc);
        commit;
        l_skip := l_skip + 500;
        exit when l_got < 500;   -- остання (неповна) сторінка
    end loop;
    dbms_output.put_line('Catalog.ГрафикиРаботы: staged ' || l_skip);
end;
/
