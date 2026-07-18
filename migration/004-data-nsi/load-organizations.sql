-- =============================================================================
-- Батч 004 (дані): завантаження живих Організацій з OData → RSD_ORGANIZATIONS.
-- Джерело: bas_doc /Catalog_Организации. Реконсиляція за Ref_Key → LEGACY_REF.
-- ЮрФизЛицо (рядок значення) → ENTITY_KIND_ID через RSD_ENUMS (батч 002).
-- Ідемпотентний (MERGE). Виконувати з NLS_LANG=.AL32UTF8.
-- Потрібні: Web Credential BAS_DOC_CRED + ACL до хоста OData (є на стенді).
-- =============================================================================
set serveroutput on
declare
    l_clob   clob;
    l_url    varchar2(600) :=
        'https://rv.entercom.ua:5683/bas_doc/odata/standard.odata/'
        || 'Catalog_%D0%9E%D1%80%D0%B3%D0%B0%D0%BD%D0%B8%D0%B7%D0%B0%D1%86%D0%B8%D0%B8'
        || '?$format=json&$top=5000';
    l_merged number;
begin
    -- контекст APEX-сесії потрібен для доступу до Web Credential
    apex_session.create_session(p_app_id => 200, p_page_id => 1, p_username => 'CLAUDE');

    l_clob := apex_web_service.make_rest_request(
        p_url                  => l_url,
        p_http_method          => 'GET',
        p_credential_static_id => 'BAS_DOC_CRED');

    merge into rsd_organizations t
    using (
        select * from json_table(l_clob, '$.value[*]' columns (
            ref_key      varchar2(36)   path '$.Ref_Key',
            code         varchar2(9)    path '$.Code',
            nm           varchar2(150)  path '$.Description',
            tax_id       varchar2(12)   path '$."ИНН"',
            edrpou       varchar2(12)   path '$."КодПоЕДРПОУ"',
            comment_text varchar2(4000) path '$."Комментарий"',
            full_name    varchar2(4000) path '$."НаименованиеПолное"',
            prefix       varchar2(2)    path '$."Префикс"',
            entity_kind  varchar2(60)   path '$."ЮрФизЛицо"',
            vat          varchar2(8)    path '$."ПлательщикНДС"',
            del          varchar2(8)    path '$.DeletionMark'
        ))
    ) s
    on (t.legacy_ref = s.ref_key)
    when matched then update set
        t.code           = s.code,
        t.name           = s.nm,
        t.tax_id         = nullif(s.tax_id, ''),
        t.edrpou_code    = nullif(s.edrpou, ''),
        t.comment_text   = nullif(s.comment_text, ''),
        t.full_name      = nullif(s.full_name, ''),
        t.doc_prefix     = nullif(s.prefix, ''),
        t.entity_kind_id = (select id from rsd_enums
                             where enum_type = 'ЮрФизЛицо' and value_key = s.entity_kind),
        t.is_vat_payer   = case when lower(s.vat) = 'true' then true else false end,
        t.is_deleted     = case when lower(s.del) = 'true' then true else false end,
        t.updated_at     = systimestamp
    when not matched then insert (
        legacy_ref, code, name, tax_id, edrpou_code, comment_text, full_name,
        doc_prefix, entity_kind_id, is_vat_payer, is_deleted)
    values (
        s.ref_key, s.code, s.nm, nullif(s.tax_id, ''), nullif(s.edrpou, ''),
        nullif(s.comment_text, ''), nullif(s.full_name, ''), nullif(s.prefix, ''),
        (select id from rsd_enums where enum_type = 'ЮрФизЛицо' and value_key = s.entity_kind),
        case when lower(s.vat) = 'true' then true else false end,
        case when lower(s.del) = 'true' then true else false end);

    l_merged := sql%rowcount;
    commit;
    dbms_output.put_line('MERGED rows: ' || l_merged);
end;
/
