-- Батч 004: reconcile крос-FK (добивання посилань після повного
-- завантаження). Резолвить <Поле>_Key (UUID з RAW) → локальний ID цілі за
-- LEGACY_REF. Лише для завантажених цілей; заповнює NULL. Ідемпотентний.
-- NLS_LANG=.AL32UTF8.
set serveroutput on

begin
    update RSD_BANKOVSKIESCHETA t set t.VALYUTADENEZHNYKHSREDSTV_ID = (
        select tgt.id from rsd_odata_raw r join RSD_VALYUTY tgt
            on tgt.legacy_ref = nullif(json_value(r.doc, '$."ВалютаДенежныхСредств_Key"'), '00000000-0000-0000-0000-000000000000')
        where r.entity = 'Catalog.БанковскиеСчета' and r.ref_key = t.legacy_ref)
    where t.VALYUTADENEZHNYKHSREDSTV_ID is null
      and exists (select 1 from rsd_odata_raw r join RSD_VALYUTY tgt
            on tgt.legacy_ref = nullif(json_value(r.doc, '$."ВалютаДенежныхСредств_Key"'), '00000000-0000-0000-0000-000000000000')
          where r.entity = 'Catalog.БанковскиеСчета' and r.ref_key = t.legacy_ref);
    dbms_output.put_line('RSD_BANKOVSKIESCHETA.VALYUTADENEZHNYKHSREDSTV_ID -> RSD_VALYUTY: ' || sql%rowcount || ' filled');
    commit;
end;
/

begin
    update RSD_KONTRAGENTY t set t.OSNOVNOYBANKOVSKIYSCHET_ID = (
        select tgt.id from rsd_odata_raw r join RSD_BANKOVSKIESCHETA tgt
            on tgt.legacy_ref = nullif(json_value(r.doc, '$."ОсновнойБанковскийСчет_Key"'), '00000000-0000-0000-0000-000000000000')
        where r.entity = 'Catalog.Контрагенты' and r.ref_key = t.legacy_ref)
    where t.OSNOVNOYBANKOVSKIYSCHET_ID is null
      and exists (select 1 from rsd_odata_raw r join RSD_BANKOVSKIESCHETA tgt
            on tgt.legacy_ref = nullif(json_value(r.doc, '$."ОсновнойБанковскийСчет_Key"'), '00000000-0000-0000-0000-000000000000')
          where r.entity = 'Catalog.Контрагенты' and r.ref_key = t.legacy_ref);
    dbms_output.put_line('RSD_KONTRAGENTY.OSNOVNOYBANKOVSKIYSCHET_ID -> RSD_BANKOVSKIESCHETA: ' || sql%rowcount || ' filled');
    commit;
end;
/

begin
    update RSD_KONTRAGENTY t set t.OTVETSTVENNYY_ID = (
        select tgt.id from rsd_odata_raw r join RSD_POLZOVATELI tgt
            on tgt.legacy_ref = nullif(json_value(r.doc, '$."Ответственный_Key"'), '00000000-0000-0000-0000-000000000000')
        where r.entity = 'Catalog.Контрагенты' and r.ref_key = t.legacy_ref)
    where t.OTVETSTVENNYY_ID is null
      and exists (select 1 from rsd_odata_raw r join RSD_POLZOVATELI tgt
            on tgt.legacy_ref = nullif(json_value(r.doc, '$."Ответственный_Key"'), '00000000-0000-0000-0000-000000000000')
          where r.entity = 'Catalog.Контрагенты' and r.ref_key = t.legacy_ref);
    dbms_output.put_line('RSD_KONTRAGENTY.OTVETSTVENNYY_ID -> RSD_POLZOVATELI: ' || sql%rowcount || ' filled');
    commit;
end;
/

begin
    update RSD_KONTRAGENTY t set t.FIZLITSO_ID = (
        select tgt.id from rsd_odata_raw r join RSD_FIZICHESKIELITSA tgt
            on tgt.legacy_ref = nullif(json_value(r.doc, '$."ФизЛицо_Key"'), '00000000-0000-0000-0000-000000000000')
        where r.entity = 'Catalog.Контрагенты' and r.ref_key = t.legacy_ref)
    where t.FIZLITSO_ID is null
      and exists (select 1 from rsd_odata_raw r join RSD_FIZICHESKIELITSA tgt
            on tgt.legacy_ref = nullif(json_value(r.doc, '$."ФизЛицо_Key"'), '00000000-0000-0000-0000-000000000000')
          where r.entity = 'Catalog.Контрагенты' and r.ref_key = t.legacy_ref);
    dbms_output.put_line('RSD_KONTRAGENTY.FIZLITSO_ID -> RSD_FIZICHESKIELITSA: ' || sql%rowcount || ' filled');
    commit;
end;
/

begin
    update RSD_POLZOVATELI t set t.FIZLITSO_ID = (
        select tgt.id from rsd_odata_raw r join RSD_FIZICHESKIELITSA tgt
            on tgt.legacy_ref = nullif(json_value(r.doc, '$."ФизЛицо_Key"'), '00000000-0000-0000-0000-000000000000')
        where r.entity = 'Catalog.Пользователи' and r.ref_key = t.legacy_ref)
    where t.FIZLITSO_ID is null
      and exists (select 1 from rsd_odata_raw r join RSD_FIZICHESKIELITSA tgt
            on tgt.legacy_ref = nullif(json_value(r.doc, '$."ФизЛицо_Key"'), '00000000-0000-0000-0000-000000000000')
          where r.entity = 'Catalog.Пользователи' and r.ref_key = t.legacy_ref);
    dbms_output.put_line('RSD_POLZOVATELI.FIZLITSO_ID -> RSD_FIZICHESKIELITSA: ' || sql%rowcount || ' filled');
    commit;
end;
/

begin
    update RSD_VALYUTY t set t.OSNOVNAYAVALYUTA_ID = (
        select tgt.id from rsd_odata_raw r join RSD_VALYUTY tgt
            on tgt.legacy_ref = nullif(json_value(r.doc, '$."ОсновнаяВалюта_Key"'), '00000000-0000-0000-0000-000000000000')
        where r.entity = 'Catalog.Валюты' and r.ref_key = t.legacy_ref)
    where t.OSNOVNAYAVALYUTA_ID is null
      and exists (select 1 from rsd_odata_raw r join RSD_VALYUTY tgt
            on tgt.legacy_ref = nullif(json_value(r.doc, '$."ОсновнаяВалюта_Key"'), '00000000-0000-0000-0000-000000000000')
          where r.entity = 'Catalog.Валюты' and r.ref_key = t.legacy_ref);
    dbms_output.put_line('RSD_VALYUTY.OSNOVNAYAVALYUTA_ID -> RSD_VALYUTY: ' || sql%rowcount || ' filled');
    commit;
end;
/

commit;
