-- Батч 004: stage сирих даних НСІ у RSD_ODATA_RAW. NLS_LANG=.AL32UTF8.
-- Потрібен контекст APEX-сесії (Web Credential BAS_DOC_CRED):
exec apex_session.create_session(p_app_id=>200, p_page_id=>1, p_username=>'CLAUDE');
set serveroutput on

-- BusinessProcess.РешениеВопросовВыполненияЗадач
declare
    l_clob clob; l_got number; l_skip number := 0;
begin
    loop
        l_clob := apex_web_service.make_rest_request(
            p_url => 'https://rv.entercom.ua:5683/bas_doc/odata/standard.odata/BusinessProcess_%D0%A0%D0%B5%D1%88%D0%B5%D0%BD%D0%B8%D0%B5%D0%92%D0%BE%D0%BF%D1%80%D0%BE%D1%81%D0%BE%D0%B2%D0%92%D1%8B%D0%BF%D0%BE%D0%BB%D0%BD%D0%B5%D0%BD%D0%B8%D1%8F%D0%97%D0%B0%D0%B4%D0%B0%D1%87?$format=json&$top=500&$skip=' || l_skip,
            p_http_method => 'GET', p_credential_static_id => 'BAS_DOC_CRED',
            p_transfer_timeout => 120);
        select count(*) into l_got
          from json_table(l_clob, '$.value[*]' columns (rk varchar2(36) path '$.Ref_Key'));
        exit when l_got = 0;
        merge into rsd_odata_raw t using (
            select rk, dc from json_table(l_clob, '$.value[*]' columns (
                rk varchar2(36) path '$.Ref_Key',
                dc clob format json path '$'))
        ) s on (t.entity = 'BusinessProcess.РешениеВопросовВыполненияЗадач' and t.ref_key = s.rk)
        when matched then update set t.doc = s.dc, t.loaded_at = systimestamp
        when not matched then insert (entity, ref_key, doc) values ('BusinessProcess.РешениеВопросовВыполненияЗадач', s.rk, s.dc);
        commit;
        l_skip := l_skip + 500;
        exit when l_got < 500;   -- остання (неповна) сторінка
    end loop;
    dbms_output.put_line('BusinessProcess.РешениеВопросовВыполненияЗадач: staged ' || l_skip);
end;
/

-- BusinessProcess.Рассмотрение
declare
    l_clob clob; l_got number; l_skip number := 0;
begin
    loop
        l_clob := apex_web_service.make_rest_request(
            p_url => 'https://rv.entercom.ua:5683/bas_doc/odata/standard.odata/BusinessProcess_%D0%A0%D0%B0%D1%81%D1%81%D0%BC%D0%BE%D1%82%D1%80%D0%B5%D0%BD%D0%B8%D0%B5?$format=json&$top=500&$skip=' || l_skip,
            p_http_method => 'GET', p_credential_static_id => 'BAS_DOC_CRED',
            p_transfer_timeout => 120);
        select count(*) into l_got
          from json_table(l_clob, '$.value[*]' columns (rk varchar2(36) path '$.Ref_Key'));
        exit when l_got = 0;
        merge into rsd_odata_raw t using (
            select rk, dc from json_table(l_clob, '$.value[*]' columns (
                rk varchar2(36) path '$.Ref_Key',
                dc clob format json path '$'))
        ) s on (t.entity = 'BusinessProcess.Рассмотрение' and t.ref_key = s.rk)
        when matched then update set t.doc = s.dc, t.loaded_at = systimestamp
        when not matched then insert (entity, ref_key, doc) values ('BusinessProcess.Рассмотрение', s.rk, s.dc);
        commit;
        l_skip := l_skip + 500;
        exit when l_got < 500;   -- остання (неповна) сторінка
    end loop;
    dbms_output.put_line('BusinessProcess.Рассмотрение: staged ' || l_skip);
end;
/

-- BusinessProcess.ОбработкаВнутреннегоДокумента
declare
    l_clob clob; l_got number; l_skip number := 0;
begin
    loop
        l_clob := apex_web_service.make_rest_request(
            p_url => 'https://rv.entercom.ua:5683/bas_doc/odata/standard.odata/BusinessProcess_%D0%9E%D0%B1%D1%80%D0%B0%D0%B1%D0%BE%D1%82%D0%BA%D0%B0%D0%92%D0%BD%D1%83%D1%82%D1%80%D0%B5%D0%BD%D0%BD%D0%B5%D0%B3%D0%BE%D0%94%D0%BE%D0%BA%D1%83%D0%BC%D0%B5%D0%BD%D1%82%D0%B0?$format=json&$top=500&$skip=' || l_skip,
            p_http_method => 'GET', p_credential_static_id => 'BAS_DOC_CRED',
            p_transfer_timeout => 120);
        select count(*) into l_got
          from json_table(l_clob, '$.value[*]' columns (rk varchar2(36) path '$.Ref_Key'));
        exit when l_got = 0;
        merge into rsd_odata_raw t using (
            select rk, dc from json_table(l_clob, '$.value[*]' columns (
                rk varchar2(36) path '$.Ref_Key',
                dc clob format json path '$'))
        ) s on (t.entity = 'BusinessProcess.ОбработкаВнутреннегоДокумента' and t.ref_key = s.rk)
        when matched then update set t.doc = s.dc, t.loaded_at = systimestamp
        when not matched then insert (entity, ref_key, doc) values ('BusinessProcess.ОбработкаВнутреннегоДокумента', s.rk, s.dc);
        commit;
        l_skip := l_skip + 500;
        exit when l_got < 500;   -- остання (неповна) сторінка
    end loop;
    dbms_output.put_line('BusinessProcess.ОбработкаВнутреннегоДокумента: staged ' || l_skip);
end;
/
