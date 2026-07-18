-- =============================================================================
-- Батч 004: реконсиляція крос-FK Організацій, розблокованих завантаженням
-- Контрагентів і Банківських рахунків. Организации.Застройщик_Key → DEVELOPER_ID,
-- ОсновнойБанковскийСчет_Key → MAIN_BANK_ACCOUNT_ID. Ідемпотентний.
-- Потрібно: RSD_ODATA_RAW має рядки Организации (нижче — дозавантаження в RAW),
-- та вже завантажені RSD_KONTRAGENTY / RSD_BANKOVSKIESCHETA. NLS_LANG=.AL32UTF8.
-- =============================================================================
exec apex_session.create_session(p_app_id=>200, p_page_id=>1, p_username=>'CLAUDE');
set serveroutput on

-- 1) дозавантажити сирі Організації в RAW (для доступу до *_Key)
declare
    l_clob clob; l_skip number := 0; l_got number;
begin
    loop
        l_clob := apex_web_service.make_rest_request(
            p_url => 'https://rv.entercom.ua:5683/bas_doc/odata/standard.odata/'
                  || 'Catalog_%D0%9E%D1%80%D0%B3%D0%B0%D0%BD%D0%B8%D0%B7%D0%B0%D1%86%D0%B8%D0%B8'
                  || '?$format=json&$top=1000&$skip=' || l_skip,
            p_http_method => 'GET', p_credential_static_id => 'BAS_DOC_CRED');
        select count(*) into l_got from json_table(l_clob, '$.value[*]' columns (rk varchar2(36) path '$.Ref_Key'));
        merge into rsd_odata_raw t using (
            select rk, dc from json_table(l_clob, '$.value[*]' columns (
                rk varchar2(36) path '$.Ref_Key', dc clob format json path '$'))
        ) s on (t.entity = 'Catalog.Организации' and t.ref_key = s.rk)
        when matched then update set t.doc = s.dc
        when not matched then insert (entity, ref_key, doc) values ('Catalog.Организации', s.rk, s.dc);
        exit when l_got < 1000;
        l_skip := l_skip + 1000;
    end loop;
    commit;
end;
/

-- 2) реконсиляція FK за *_Key → локальний ID цілі
update rsd_organizations o set
    o.developer_id = (
        select k.id from rsd_odata_raw r join rsd_kontragenty k
             on k.legacy_ref = nullif(json_value(r.doc, '$."Застройщик_Key"'), '00000000-0000-0000-0000-000000000000')
        where r.entity = 'Catalog.Организации' and r.ref_key = o.legacy_ref),
    o.main_bank_account_id = (
        select b.id from rsd_odata_raw r join rsd_bankovskiescheta b
             on b.legacy_ref = nullif(json_value(r.doc, '$."ОсновнойБанковскийСчет_Key"'), '00000000-0000-0000-0000-000000000000')
        where r.entity = 'Catalog.Организации' and r.ref_key = o.legacy_ref);
commit;
