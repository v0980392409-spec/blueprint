-- Батч 004: stage сирих даних НСІ у RSD_ODATA_RAW. NLS_LANG=.AL32UTF8.
-- Потрібен контекст APEX-сесії (Web Credential BAS_DOC_CRED):
exec apex_session.create_session(p_app_id=>200, p_page_id=>1, p_username=>'CLAUDE');
set serveroutput on

-- BusinessProcess.Согласование (bounded 500)
declare
    l_clob clob;
begin
    l_clob := apex_web_service.make_rest_request(
        p_url => 'https://rv.entercom.ua:5683/bas_doc/odata/standard.odata/BusinessProcess_%D0%A1%D0%BE%D0%B3%D0%BB%D0%B0%D1%81%D0%BE%D0%B2%D0%B0%D0%BD%D0%B8%D0%B5?$format=json&$top=500',
        p_http_method => 'GET', p_credential_static_id => 'BAS_DOC_CRED',
        p_transfer_timeout => 300);
    merge into rsd_odata_raw t using (
        select rk, dc from json_table(l_clob, '$.value[*]' columns (
            rk varchar2(36) path '$.Ref_Key',
            dc clob format json path '$'))
    ) s on (t.entity = 'BusinessProcess.Согласование' and t.ref_key = s.rk)
    when matched then update set t.doc = s.dc, t.loaded_at = systimestamp
    when not matched then insert (entity, ref_key, doc) values ('BusinessProcess.Согласование', s.rk, s.dc);
    dbms_output.put_line('BusinessProcess.Согласование: bounded ' || sql%rowcount);  -- до commit (інакше rowcount 0)
    commit;
end;
/

-- BusinessProcess.КомплексныйПроцесс (bounded 500)
declare
    l_clob clob;
begin
    l_clob := apex_web_service.make_rest_request(
        p_url => 'https://rv.entercom.ua:5683/bas_doc/odata/standard.odata/BusinessProcess_%D0%9A%D0%BE%D0%BC%D0%BF%D0%BB%D0%B5%D0%BA%D1%81%D0%BD%D1%8B%D0%B9%D0%9F%D1%80%D0%BE%D1%86%D0%B5%D1%81%D1%81?$format=json&$top=500',
        p_http_method => 'GET', p_credential_static_id => 'BAS_DOC_CRED',
        p_transfer_timeout => 300);
    merge into rsd_odata_raw t using (
        select rk, dc from json_table(l_clob, '$.value[*]' columns (
            rk varchar2(36) path '$.Ref_Key',
            dc clob format json path '$'))
    ) s on (t.entity = 'BusinessProcess.КомплексныйПроцесс' and t.ref_key = s.rk)
    when matched then update set t.doc = s.dc, t.loaded_at = systimestamp
    when not matched then insert (entity, ref_key, doc) values ('BusinessProcess.КомплексныйПроцесс', s.rk, s.dc);
    dbms_output.put_line('BusinessProcess.КомплексныйПроцесс: bounded ' || sql%rowcount);  -- до commit (інакше rowcount 0)
    commit;
end;
/

-- BusinessProcess.Ознакомление (bounded 500)
declare
    l_clob clob;
begin
    l_clob := apex_web_service.make_rest_request(
        p_url => 'https://rv.entercom.ua:5683/bas_doc/odata/standard.odata/BusinessProcess_%D0%9E%D0%B7%D0%BD%D0%B0%D0%BA%D0%BE%D0%BC%D0%BB%D0%B5%D0%BD%D0%B8%D0%B5?$format=json&$top=500',
        p_http_method => 'GET', p_credential_static_id => 'BAS_DOC_CRED',
        p_transfer_timeout => 300);
    merge into rsd_odata_raw t using (
        select rk, dc from json_table(l_clob, '$.value[*]' columns (
            rk varchar2(36) path '$.Ref_Key',
            dc clob format json path '$'))
    ) s on (t.entity = 'BusinessProcess.Ознакомление' and t.ref_key = s.rk)
    when matched then update set t.doc = s.dc, t.loaded_at = systimestamp
    when not matched then insert (entity, ref_key, doc) values ('BusinessProcess.Ознакомление', s.rk, s.dc);
    dbms_output.put_line('BusinessProcess.Ознакомление: bounded ' || sql%rowcount);  -- до commit (інакше rowcount 0)
    commit;
end;
/

-- BusinessProcess.Исполнение (bounded 500)
declare
    l_clob clob;
begin
    l_clob := apex_web_service.make_rest_request(
        p_url => 'https://rv.entercom.ua:5683/bas_doc/odata/standard.odata/BusinessProcess_%D0%98%D1%81%D0%BF%D0%BE%D0%BB%D0%BD%D0%B5%D0%BD%D0%B8%D0%B5?$format=json&$top=500',
        p_http_method => 'GET', p_credential_static_id => 'BAS_DOC_CRED',
        p_transfer_timeout => 300);
    merge into rsd_odata_raw t using (
        select rk, dc from json_table(l_clob, '$.value[*]' columns (
            rk varchar2(36) path '$.Ref_Key',
            dc clob format json path '$'))
    ) s on (t.entity = 'BusinessProcess.Исполнение' and t.ref_key = s.rk)
    when matched then update set t.doc = s.dc, t.loaded_at = systimestamp
    when not matched then insert (entity, ref_key, doc) values ('BusinessProcess.Исполнение', s.rk, s.dc);
    dbms_output.put_line('BusinessProcess.Исполнение: bounded ' || sql%rowcount);  -- до commit (інакше rowcount 0)
    commit;
end;
/

-- BusinessProcess.Утверждение (bounded 500)
declare
    l_clob clob;
begin
    l_clob := apex_web_service.make_rest_request(
        p_url => 'https://rv.entercom.ua:5683/bas_doc/odata/standard.odata/BusinessProcess_%D0%A3%D1%82%D0%B2%D0%B5%D1%80%D0%B6%D0%B4%D0%B5%D0%BD%D0%B8%D0%B5?$format=json&$top=500',
        p_http_method => 'GET', p_credential_static_id => 'BAS_DOC_CRED',
        p_transfer_timeout => 300);
    merge into rsd_odata_raw t using (
        select rk, dc from json_table(l_clob, '$.value[*]' columns (
            rk varchar2(36) path '$.Ref_Key',
            dc clob format json path '$'))
    ) s on (t.entity = 'BusinessProcess.Утверждение' and t.ref_key = s.rk)
    when matched then update set t.doc = s.dc, t.loaded_at = systimestamp
    when not matched then insert (entity, ref_key, doc) values ('BusinessProcess.Утверждение', s.rk, s.dc);
    dbms_output.put_line('BusinessProcess.Утверждение: bounded ' || sql%rowcount);  -- до commit (інакше rowcount 0)
    commit;
end;
/
