-- Батч 004: reconcile крос-FK (добивання посилань після повного
-- завантаження). Резолвить <Поле>_Key (UUID з RAW) → локальний ID цілі за
-- LEGACY_REF. Лише для завантажених цілей; заповнює NULL. Ідемпотентний.
-- NLS_LANG=.AL32UTF8.
set serveroutput on

begin
    update RSD_STRUKTURAPREDPRIYATIYA t set t.GRAFIKRABOTY_ID = (
        select tgt.id from rsd_odata_raw r join RSD_GRAFIKIRABOTY tgt
            on tgt.legacy_ref = nullif(json_value(r.doc, '$."ГрафикРаботы_Key"'), '00000000-0000-0000-0000-000000000000')
        where r.entity = 'Catalog.СтруктураПредприятия' and r.ref_key = t.legacy_ref)
    where t.GRAFIKRABOTY_ID is null
      and exists (select 1 from rsd_odata_raw r join RSD_GRAFIKIRABOTY tgt
            on tgt.legacy_ref = nullif(json_value(r.doc, '$."ГрафикРаботы_Key"'), '00000000-0000-0000-0000-000000000000')
          where r.entity = 'Catalog.СтруктураПредприятия' and r.ref_key = t.legacy_ref);
    dbms_output.put_line('RSD_STRUKTURAPREDPRIYATIYA.GRAFIKRABOTY_ID -> RSD_GRAFIKIRABOTY: ' || sql%rowcount || ' filled');
    commit;
end;
/

begin
    update RSD_VIDYISKHODYASHCHIKHDOKUMENTOV t set t.UDALITNUMERATOR_ID = (
        select tgt.id from rsd_odata_raw r join RSD_NUMERATORY tgt
            on tgt.legacy_ref = nullif(json_value(r.doc, '$."УдалитьНумератор_Key"'), '00000000-0000-0000-0000-000000000000')
        where r.entity = 'Catalog.ВидыИсходящихДокументов' and r.ref_key = t.legacy_ref)
    where t.UDALITNUMERATOR_ID is null
      and exists (select 1 from rsd_odata_raw r join RSD_NUMERATORY tgt
            on tgt.legacy_ref = nullif(json_value(r.doc, '$."УдалитьНумератор_Key"'), '00000000-0000-0000-0000-000000000000')
          where r.entity = 'Catalog.ВидыИсходящихДокументов' and r.ref_key = t.legacy_ref);
    dbms_output.put_line('RSD_VIDYISKHODYASHCHIKHDOKUMENTOV.UDALITNUMERATOR_ID -> RSD_NUMERATORY: ' || sql%rowcount || ' filled');
    commit;
end;
/

begin
    update RSD_VIDYVKHODYASHCHIKHDOKUMENTOV t set t.UDALITNUMERATOR_ID = (
        select tgt.id from rsd_odata_raw r join RSD_NUMERATORY tgt
            on tgt.legacy_ref = nullif(json_value(r.doc, '$."УдалитьНумератор_Key"'), '00000000-0000-0000-0000-000000000000')
        where r.entity = 'Catalog.ВидыВходящихДокументов' and r.ref_key = t.legacy_ref)
    where t.UDALITNUMERATOR_ID is null
      and exists (select 1 from rsd_odata_raw r join RSD_NUMERATORY tgt
            on tgt.legacy_ref = nullif(json_value(r.doc, '$."УдалитьНумератор_Key"'), '00000000-0000-0000-0000-000000000000')
          where r.entity = 'Catalog.ВидыВходящихДокументов' and r.ref_key = t.legacy_ref);
    dbms_output.put_line('RSD_VIDYVKHODYASHCHIKHDOKUMENTOV.UDALITNUMERATOR_ID -> RSD_NUMERATORY: ' || sql%rowcount || ' filled');
    commit;
end;
/

begin
    update RSD_VIDYVNUTRENNIKHDOKUMENTOV t set t.UDALITNUMERATOR_ID = (
        select tgt.id from rsd_odata_raw r join RSD_NUMERATORY tgt
            on tgt.legacy_ref = nullif(json_value(r.doc, '$."УдалитьНумератор_Key"'), '00000000-0000-0000-0000-000000000000')
        where r.entity = 'Catalog.ВидыВнутреннихДокументов' and r.ref_key = t.legacy_ref)
    where t.UDALITNUMERATOR_ID is null
      and exists (select 1 from rsd_odata_raw r join RSD_NUMERATORY tgt
            on tgt.legacy_ref = nullif(json_value(r.doc, '$."УдалитьНумератор_Key"'), '00000000-0000-0000-0000-000000000000')
          where r.entity = 'Catalog.ВидыВнутреннихДокументов' and r.ref_key = t.legacy_ref);
    dbms_output.put_line('RSD_VIDYVNUTRENNIKHDOKUMENTOV.UDALITNUMERATOR_ID -> RSD_NUMERATORY: ' || sql%rowcount || ' filled');
    commit;
end;
/

commit;
