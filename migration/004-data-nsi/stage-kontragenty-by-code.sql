-- =============================================================================
-- Батч 004: повне довантаження Контрагентів у RSD_ODATA_RAW через партиціювання
-- за префіксом Code. Причина: ця публікація 1С OData ЗАБОРОНЯЄ eq/gt/ge/lt на
-- Code («Операція не дозволена у ГДЕ») і НЕ застосовує $orderby (asc=desc), тож
-- ні $skip (cap ~3000), ні keyset (GUID/лексикографічний порядок) не працюють.
-- Але `startswith(Code, ...)` дозволений. Коди — ДО-NNNNNN (послідовні);
-- префікси ДО-000..ДО-010 = 11 партицій ≤1000 рядків, разом рівно 10597.
-- Кожна партиція тягнеться ОДНИМ запитом (без skip/курсора). NLS_LANG=.AL32UTF8.
-- =============================================================================
exec apex_session.create_session(p_app_id=>200, p_page_id=>1, p_username=>'CLAUDE');
set serveroutput on
declare
    l_clob clob; l_got number; l_pfx varchar2(30);
    -- ДО- у percent-encoding для URL
    c_do constant varchar2(20) := '%D0%94%D0%9E-0';
begin
    for n in 0 .. 12 loop
        l_pfx := c_do || lpad(to_char(n), 2, '0');   -- %..%-000 .. -012
        l_clob := apex_web_service.make_rest_request(
            p_url => 'https://rv.entercom.ua:5683/bas_doc/odata/standard.odata/'
                  || 'Catalog_%D0%9A%D0%BE%D0%BD%D1%82%D1%80%D0%B0%D0%B3%D0%B5%D0%BD%D1%82%D1%8B'
                  || '?$format=json&$top=1200'
                  || '&$filter=startswith%28Code%2C%27' || l_pfx || '%27%29%20eq%20true',
            p_http_method => 'GET', p_credential_static_id => 'BAS_DOC_CRED',
            p_transfer_timeout => 120);
        merge into rsd_odata_raw t using (
            select rk, dc from json_table(l_clob, '$.value[*]' columns (
                rk varchar2(36) path '$.Ref_Key', dc clob format json path '$'))
        ) s on (t.entity = 'Catalog.Контрагенты' and t.ref_key = s.rk)
        when matched then update set t.doc = s.dc, t.loaded_at = systimestamp
        when not matched then insert (entity, ref_key, doc) values ('Catalog.Контрагенты', s.rk, s.dc);
        l_got := sql%rowcount;
        commit;
        dbms_output.put_line('prefix ' || n || ': merged ' || l_got);
    end loop;
end;
/
