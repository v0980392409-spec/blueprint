-- Батч 007 backfill: поліморфний власник RSD_BANKOVSKIESCHETA (5752 живих рядки).
-- OWNER_TYPE з OData Owner_Type; OWNER_ID переразрешаємо за типом проти
-- RSD_KONTRAGENTY / RSD_ORGANIZATIONS (раніше OWNER_ID резолвився неоднозначно).
-- Ідемпотентно. NLS_LANG=.AL32UTF8.
set serveroutput on

-- 1) OWNER_TYPE ← Owner_Type (StandardODATA.Catalog_X → Catalog.X)
update rsd_bankovskiescheta t set owner_type = (
    select case json_value(r.doc, '$.Owner_Type')
             when 'StandardODATA.Catalog_Контрагенты' then 'Catalog.Контрагенты'
             when 'StandardODATA.Catalog_Организации'  then 'Catalog.Организации'
             else json_value(r.doc, '$.Owner_Type') end
    from rsd_odata_raw r
    where r.entity = 'Catalog.БанковскиеСчета' and r.ref_key = t.legacy_ref)
where owner_type is null;

-- 2) OWNER_ID за типом: Контрагенти
update rsd_bankovskiescheta t set owner_id = (
    select k.id from rsd_kontragenty k, rsd_odata_raw r
    where r.entity = 'Catalog.БанковскиеСчета' and r.ref_key = t.legacy_ref
      and k.legacy_ref = json_value(r.doc, '$.Owner'))
where owner_type = 'Catalog.Контрагенты';

-- 3) OWNER_ID за типом: Організації
update rsd_bankovskiescheta t set owner_id = (
    select o.id from rsd_organizations o, rsd_odata_raw r
    where r.entity = 'Catalog.БанковскиеСчета' and r.ref_key = t.legacy_ref
      and o.legacy_ref = json_value(r.doc, '$.Owner'))
where owner_type = 'Catalog.Организации';

commit;

declare
    l_kontr number; l_org number; l_id number; l_null number;
begin
    select count(*) into l_kontr from rsd_bankovskiescheta where owner_type='Catalog.Контрагенты';
    select count(*) into l_org   from rsd_bankovskiescheta where owner_type='Catalog.Организации';
    select count(owner_id), count(*)-count(owner_id) into l_id, l_null from rsd_bankovskiescheta;
    dbms_output.put_line('OWNER_TYPE: Контрагенти='||l_kontr||' Організації='||l_org);
    dbms_output.put_line('OWNER_ID filled='||l_id||' null='||l_null);
end;
/
