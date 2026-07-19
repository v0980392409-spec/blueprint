-- Батч 006: dedup seed vs live. Предопределённые (seed з батча 003) мають
-- LEGACY_REF = metadata-UUID, живі записи OData — Ref_Key; вони НЕ збігаються,
-- тож seed дублює живі елементи. Живі дані авторитетні: прибираємо рядки,
-- чиїх legacy_ref немає у RAW (= seed-залишки). Ідемпотентно. NLS_LANG=.AL32UTF8.
set serveroutput on
declare l number; begin
  delete from RSD_USLOVIYAMARSHRUTIZATSII where legacy_ref not in (select ref_key from rsd_odata_raw where entity='Catalog.УсловияМаршрутизации');
  l := sql%rowcount; if l>0 then dbms_output.put_line('RSD_USLOVIYAMARSHRUTIZATSII: -'||l||' seed'); end if;
  delete from RSD_VIDYVKHODYASHCHIKHDOKUMENTOV where legacy_ref not in (select ref_key from rsd_odata_raw where entity='Catalog.ВидыВходящихДокументов');
  l := sql%rowcount; if l>0 then dbms_output.put_line('RSD_VIDYVKHODYASHCHIKHDOKUMENTOV: -'||l||' seed'); end if;
  delete from RSD_STRUKTURAPREDPRIYATIYA where legacy_ref not in (select ref_key from rsd_odata_raw where entity='Catalog.СтруктураПредприятия');
  l := sql%rowcount; if l>0 then dbms_output.put_line('RSD_STRUKTURAPREDPRIYATIYA: -'||l||' seed'); end if;
  delete from RSD_VIDYVNUTRENNIKHDOKUMENTOV where legacy_ref not in (select ref_key from rsd_odata_raw where entity='Catalog.ВидыВнутреннихДокументов');
  l := sql%rowcount; if l>0 then dbms_output.put_line('RSD_VIDYVNUTRENNIKHDOKUMENTOV: -'||l||' seed'); end if;
  delete from RSD_PROFILIGRUPPDOSTUPA where legacy_ref not in (select ref_key from rsd_odata_raw where entity='Catalog.ПрофилиГруппДоступа');
  l := sql%rowcount; if l>0 then dbms_output.put_line('RSD_PROFILIGRUPPDOSTUPA: -'||l||' seed'); end if;
  delete from RSD_RABOCHIEGRUPPY where legacy_ref not in (select ref_key from rsd_odata_raw where entity='Catalog.РабочиеГруппы');
  l := sql%rowcount; if l>0 then dbms_output.put_line('RSD_RABOCHIEGRUPPY: -'||l||' seed'); end if;
  delete from RSD_TERRITORIIIPOMESHCHENIYA where legacy_ref not in (select ref_key from rsd_odata_raw where entity='Catalog.ТерриторииИПомещения');
  l := sql%rowcount; if l>0 then dbms_output.put_line('RSD_TERRITORIIIPOMESHCHENIYA: -'||l||' seed'); end if;
  delete from RSD_PAPKIVNUTRENNIKHDOKUMENTOV where legacy_ref not in (select ref_key from rsd_odata_raw where entity='Catalog.ПапкиВнутреннихДокументов');
  l := sql%rowcount; if l>0 then dbms_output.put_line('RSD_PAPKIVNUTRENNIKHDOKUMENTOV: -'||l||' seed'); end if;
  delete from RSD_USLOVIYAZADACH where legacy_ref not in (select ref_key from rsd_odata_raw where entity='Catalog.УсловияЗадач');
  l := sql%rowcount; if l>0 then dbms_output.put_line('RSD_USLOVIYAZADACH: -'||l||' seed'); end if;
  delete from RSD_VIDYISKHODYASHCHIKHDOKUMENTOV where legacy_ref not in (select ref_key from rsd_odata_raw where entity='Catalog.ВидыИсходящихДокументов');
  l := sql%rowcount; if l>0 then dbms_output.put_line('RSD_VIDYISKHODYASHCHIKHDOKUMENTOV: -'||l||' seed'); end if;
  delete from RSD_NUMERATORY where legacy_ref not in (select ref_key from rsd_odata_raw where entity='Catalog.Нумераторы');
  l := sql%rowcount; if l>0 then dbms_output.put_line('RSD_NUMERATORY: -'||l||' seed'); end if;
  delete from RSD_PAPKIFORUMA where legacy_ref not in (select ref_key from rsd_odata_raw where entity='Catalog.ПапкиФорума');
  l := sql%rowcount; if l>0 then dbms_output.put_line('RSD_PAPKIFORUMA: -'||l||' seed'); end if;
  delete from RSD_KATEGORIIDANNYKH where legacy_ref not in (select ref_key from rsd_odata_raw where entity='Catalog.КатегорииДанных');
  l := sql%rowcount; if l>0 then dbms_output.put_line('RSD_KATEGORIIDANNYKH: -'||l||' seed'); end if;
  delete from RSD_DOLZHNOSTI where legacy_ref not in (select ref_key from rsd_odata_raw where entity='Catalog.Должности');
  l := sql%rowcount; if l>0 then dbms_output.put_line('RSD_DOLZHNOSTI: -'||l||' seed'); end if;
  delete from RSD_SHABLONYTEKSTOV where legacy_ref not in (select ref_key from rsd_odata_raw where entity='Catalog.ШаблоныТекстов');
  l := sql%rowcount; if l>0 then dbms_output.put_line('RSD_SHABLONYTEKSTOV: -'||l||' seed'); end if;
  delete from RSD_GRUPPYDOSTUPAKONTRAGENTOV where legacy_ref not in (select ref_key from rsd_odata_raw where entity='Catalog.ГруппыДоступаКонтрагентов');
  l := sql%rowcount; if l>0 then dbms_output.put_line('RSD_GRUPPYDOSTUPAKONTRAGENTOV: -'||l||' seed'); end if;
  delete from RSD_GRAFIKIRABOTY where legacy_ref not in (select ref_key from rsd_odata_raw where entity='Catalog.ГрафикиРаботы');
  l := sql%rowcount; if l>0 then dbms_output.put_line('RSD_GRAFIKIRABOTY: -'||l||' seed'); end if;
  commit;
end;
/
