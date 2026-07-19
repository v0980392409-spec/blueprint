-- Батч 006: reconcile PARENT_ID (ієрархія). gen_catalog_batch додає колонку
-- PARENT_ID, але НЕ кладе її у field-map → загрузчики її не резолвлять.
-- Тут добиваємо self-FK: PARENT_ID = id рядка з тим же LEGACY_REF, що
-- Parent_Key у RAW. Заповнює лише NULL. Ідемпотентно. NLS_LANG=.AL32UTF8.
set serveroutput on
declare l number; begin
  update RSD_KATEGORIIDANNYKH t set parent_id = (select p.id from RSD_KATEGORIIDANNYKH p, rsd_odata_raw r
    where r.entity='Catalog.КатегорииДанных' and r.ref_key=t.legacy_ref and p.legacy_ref=json_value(r.doc,'$.Parent_Key'))
   where parent_id is null;
  l:=sql%rowcount; if l>0 then dbms_output.put_line('RSD_KATEGORIIDANNYKH: +'||l||' parent'); end if;
  update RSD_PAPKIFORUMA t set parent_id = (select p.id from RSD_PAPKIFORUMA p, rsd_odata_raw r
    where r.entity='Catalog.ПапкиФорума' and r.ref_key=t.legacy_ref and p.legacy_ref=json_value(r.doc,'$.Parent_Key'))
   where parent_id is null;
  l:=sql%rowcount; if l>0 then dbms_output.put_line('RSD_PAPKIFORUMA: +'||l||' parent'); end if;
  update RSD_PAPKIVNUTRENNIKHDOKUMENTOV t set parent_id = (select p.id from RSD_PAPKIVNUTRENNIKHDOKUMENTOV p, rsd_odata_raw r
    where r.entity='Catalog.ПапкиВнутреннихДокументов' and r.ref_key=t.legacy_ref and p.legacy_ref=json_value(r.doc,'$.Parent_Key'))
   where parent_id is null;
  l:=sql%rowcount; if l>0 then dbms_output.put_line('RSD_PAPKIVNUTRENNIKHDOKUMENTOV: +'||l||' parent'); end if;
  update RSD_PROFILIGRUPPDOSTUPA t set parent_id = (select p.id from RSD_PROFILIGRUPPDOSTUPA p, rsd_odata_raw r
    where r.entity='Catalog.ПрофилиГруппДоступа' and r.ref_key=t.legacy_ref and p.legacy_ref=json_value(r.doc,'$.Parent_Key'))
   where parent_id is null;
  l:=sql%rowcount; if l>0 then dbms_output.put_line('RSD_PROFILIGRUPPDOSTUPA: +'||l||' parent'); end if;
  update RSD_RABOCHIEGRUPPY t set parent_id = (select p.id from RSD_RABOCHIEGRUPPY p, rsd_odata_raw r
    where r.entity='Catalog.РабочиеГруппы' and r.ref_key=t.legacy_ref and p.legacy_ref=json_value(r.doc,'$.Parent_Key'))
   where parent_id is null;
  l:=sql%rowcount; if l>0 then dbms_output.put_line('RSD_RABOCHIEGRUPPY: +'||l||' parent'); end if;
  update RSD_STRUKTURAPREDPRIYATIYA t set parent_id = (select p.id from RSD_STRUKTURAPREDPRIYATIYA p, rsd_odata_raw r
    where r.entity='Catalog.СтруктураПредприятия' and r.ref_key=t.legacy_ref and p.legacy_ref=json_value(r.doc,'$.Parent_Key'))
   where parent_id is null;
  l:=sql%rowcount; if l>0 then dbms_output.put_line('RSD_STRUKTURAPREDPRIYATIYA: +'||l||' parent'); end if;
  update RSD_TERRITORIIIPOMESHCHENIYA t set parent_id = (select p.id from RSD_TERRITORIIIPOMESHCHENIYA p, rsd_odata_raw r
    where r.entity='Catalog.ТерриторииИПомещения' and r.ref_key=t.legacy_ref and p.legacy_ref=json_value(r.doc,'$.Parent_Key'))
   where parent_id is null;
  l:=sql%rowcount; if l>0 then dbms_output.put_line('RSD_TERRITORIIIPOMESHCHENIYA: +'||l||' parent'); end if;
  update RSD_USLOVIYAZADACH t set parent_id = (select p.id from RSD_USLOVIYAZADACH p, rsd_odata_raw r
    where r.entity='Catalog.УсловияЗадач' and r.ref_key=t.legacy_ref and p.legacy_ref=json_value(r.doc,'$.Parent_Key'))
   where parent_id is null;
  l:=sql%rowcount; if l>0 then dbms_output.put_line('RSD_USLOVIYAZADACH: +'||l||' parent'); end if;
  update RSD_VIDYISKHODYASHCHIKHDOKUMENTOV t set parent_id = (select p.id from RSD_VIDYISKHODYASHCHIKHDOKUMENTOV p, rsd_odata_raw r
    where r.entity='Catalog.ВидыИсходящихДокументов' and r.ref_key=t.legacy_ref and p.legacy_ref=json_value(r.doc,'$.Parent_Key'))
   where parent_id is null;
  l:=sql%rowcount; if l>0 then dbms_output.put_line('RSD_VIDYISKHODYASHCHIKHDOKUMENTOV: +'||l||' parent'); end if;
  update RSD_VIDYVKHODYASHCHIKHDOKUMENTOV t set parent_id = (select p.id from RSD_VIDYVKHODYASHCHIKHDOKUMENTOV p, rsd_odata_raw r
    where r.entity='Catalog.ВидыВходящихДокументов' and r.ref_key=t.legacy_ref and p.legacy_ref=json_value(r.doc,'$.Parent_Key'))
   where parent_id is null;
  l:=sql%rowcount; if l>0 then dbms_output.put_line('RSD_VIDYVKHODYASHCHIKHDOKUMENTOV: +'||l||' parent'); end if;
  update RSD_VIDYVNUTRENNIKHDOKUMENTOV t set parent_id = (select p.id from RSD_VIDYVNUTRENNIKHDOKUMENTOV p, rsd_odata_raw r
    where r.entity='Catalog.ВидыВнутреннихДокументов' and r.ref_key=t.legacy_ref and p.legacy_ref=json_value(r.doc,'$.Parent_Key'))
   where parent_id is null;
  l:=sql%rowcount; if l>0 then dbms_output.put_line('RSD_VIDYVNUTRENNIKHDOKUMENTOV: +'||l||' parent'); end if;
  commit; end;
/
