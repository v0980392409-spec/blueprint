-- Батч 004: типізована проекція RAW → RSD_*. Запускати ДВІЧІ (цикли).
-- NLS_LANG=.AL32UTF8.
set define off

-- Catalog.Контрагенты → RSD_KONTRAGENTY
merge into RSD_KONTRAGENTY t using (
    select
        json_value(doc, '$.Ref_Key') as LEGACY_REF,
        case when lower(json_value(doc, '$."DeletionMark"')) = 'true' then true else false end as IS_DELETED,
        json_value(doc, '$."Code"') as CODE,
        json_value(doc, '$."Description"') as NAME,
        (select tgt.id from RSD_GRUPPYDOSTUPAKONTRAGENTOV tgt where tgt.legacy_ref = nullif(json_value(doc, '$."ГруппаДоступа_Key"'), '00000000-0000-0000-0000-000000000000')) as GRUPPADOSTUPA_ID,
        json_value(doc, '$."ИНН"') as INN,
        json_value(doc, '$."КодПоЕДРПОУ"') as KODPOEDRPOU,
        json_value(doc, '$."Комментарий"') as KOMMENTARIY,
        json_value(doc, '$."НаименованиеПолное"') as NAIMENOVANIEPOLNOE,
        (select tgt.id from RSD_BANKOVSKIESCHETA tgt where tgt.legacy_ref = nullif(json_value(doc, '$."ОсновнойБанковскийСчет_Key"'), '00000000-0000-0000-0000-000000000000')) as OSNOVNOYBANKOVSKIYSCHET_ID,
        (select tgt.id from RSD_POLZOVATELI tgt where tgt.legacy_ref = nullif(json_value(doc, '$."Ответственный_Key"'), '00000000-0000-0000-0000-000000000000')) as OTVETSTVENNYY_ID,
        (select tgt.id from RSD_FIZICHESKIELITSA tgt where tgt.legacy_ref = nullif(json_value(doc, '$."ФизЛицо_Key"'), '00000000-0000-0000-0000-000000000000')) as FIZLITSO_ID,
        (select id from rsd_enums where enum_type = 'ЮрФизЛицо' and value_key = json_value(doc, '$."ЮрФизЛицо"')) as YURFIZLITSO_ID
    from rsd_odata_raw where entity = 'Catalog.Контрагенты'
) s on (t.legacy_ref = s.LEGACY_REF)
when matched then update set
        t.IS_DELETED = s.IS_DELETED,
        t.CODE = s.CODE,
        t.NAME = s.NAME,
        t.GRUPPADOSTUPA_ID = s.GRUPPADOSTUPA_ID,
        t.INN = s.INN,
        t.KODPOEDRPOU = s.KODPOEDRPOU,
        t.KOMMENTARIY = s.KOMMENTARIY,
        t.NAIMENOVANIEPOLNOE = s.NAIMENOVANIEPOLNOE,
        t.OSNOVNOYBANKOVSKIYSCHET_ID = s.OSNOVNOYBANKOVSKIYSCHET_ID,
        t.OTVETSTVENNYY_ID = s.OTVETSTVENNYY_ID,
        t.FIZLITSO_ID = s.FIZLITSO_ID,
        t.YURFIZLITSO_ID = s.YURFIZLITSO_ID
when not matched then insert (LEGACY_REF, IS_DELETED, CODE, NAME, GRUPPADOSTUPA_ID, INN, KODPOEDRPOU, KOMMENTARIY, NAIMENOVANIEPOLNOE, OSNOVNOYBANKOVSKIYSCHET_ID, OTVETSTVENNYY_ID, FIZLITSO_ID, YURFIZLITSO_ID)
    values (s.LEGACY_REF, s.IS_DELETED, s.CODE, s.NAME, s.GRUPPADOSTUPA_ID, s.INN, s.KODPOEDRPOU, s.KOMMENTARIY, s.NAIMENOVANIEPOLNOE, s.OSNOVNOYBANKOVSKIYSCHET_ID, s.OTVETSTVENNYY_ID, s.FIZLITSO_ID, s.YURFIZLITSO_ID);
commit;

-- Catalog.Пользователи → RSD_POLZOVATELI
merge into RSD_POLZOVATELI t using (
    select
        json_value(doc, '$.Ref_Key') as LEGACY_REF,
        case when lower(json_value(doc, '$."DeletionMark"')) = 'true' then true else false end as IS_DELETED,
        json_value(doc, '$."Description"') as NAME,
        case when lower(json_value(doc, '$."Недействителен"')) = 'true' then true else false end as NEDEYSTVITELEN,
        json_value(doc, '$."ПредставлениеВДокументах"') as PREDSTAVLENIEVDOKUMENTAKH,
        json_value(doc, '$."РазрешенныеВебСерверы"') as RAZRESHENNYEVEBSERVERY,
        (select tgt.id from RSD_FIZICHESKIELITSA tgt where tgt.legacy_ref = nullif(json_value(doc, '$."ФизЛицо_Key"'), '00000000-0000-0000-0000-000000000000')) as FIZLITSO_ID,
        json_value(doc, '$."Комментарий"') as KOMMENTARIY,
        case when lower(json_value(doc, '$."Служебный"')) = 'true' then true else false end as SLUZHEBNYY,
        case when lower(json_value(doc, '$."Подготовлен"')) = 'true' then true else false end as PODGOTOVLEN,
        json_value(doc, '$."ИдентификаторПользователяИБ"') as IDENTIFIKATORPOLZOVATELYAIB,
        json_value(doc, '$."ПредставлениеВПереписке"') as PREDSTAVLENIEVPEREPISKE,
        json_value(doc, '$."ПредставлениеВПерепискеСРангом"') as PREDSTAVLENIEVPEREPISKESRANGOM,
        (select tgt.id from RSD_TERRITORIIIPOMESHCHENIYA tgt where tgt.legacy_ref = nullif(json_value(doc, '$."Помещение_Key"'), '00000000-0000-0000-0000-000000000000')) as POMESHCHENIE_ID,
        json_value(doc, '$."КодЯзыка"') as KODYAZYKA,
        json_value(doc, '$."ИдентификаторПользователяСервиса"') as IDENTIFIKATORPOLZOVATELYASERVISA,
        json_value(doc, '$."СвойстваПользователяИБ"') as SVOYSTVAPOLZOVATELYAIB,
        cast(null as number) as RSD_PARATNERYRASPREDELENIYAPOMESHCHENIY_ID,
        case when lower(json_value(doc, '$."RSD_НовыйИнтерфейсДляСпискаДокументов"')) = 'true' then true else false end as RSD_NOVYYINTERFEYSDLYASPISKADOKUMENTOV
    from rsd_odata_raw where entity = 'Catalog.Пользователи'
) s on (t.legacy_ref = s.LEGACY_REF)
when matched then update set
        t.IS_DELETED = s.IS_DELETED,
        t.NAME = s.NAME,
        t.NEDEYSTVITELEN = s.NEDEYSTVITELEN,
        t.PREDSTAVLENIEVDOKUMENTAKH = s.PREDSTAVLENIEVDOKUMENTAKH,
        t.RAZRESHENNYEVEBSERVERY = s.RAZRESHENNYEVEBSERVERY,
        t.FIZLITSO_ID = s.FIZLITSO_ID,
        t.KOMMENTARIY = s.KOMMENTARIY,
        t.SLUZHEBNYY = s.SLUZHEBNYY,
        t.PODGOTOVLEN = s.PODGOTOVLEN,
        t.IDENTIFIKATORPOLZOVATELYAIB = s.IDENTIFIKATORPOLZOVATELYAIB,
        t.PREDSTAVLENIEVPEREPISKE = s.PREDSTAVLENIEVPEREPISKE,
        t.PREDSTAVLENIEVPEREPISKESRANGOM = s.PREDSTAVLENIEVPEREPISKESRANGOM,
        t.POMESHCHENIE_ID = s.POMESHCHENIE_ID,
        t.KODYAZYKA = s.KODYAZYKA,
        t.IDENTIFIKATORPOLZOVATELYASERVISA = s.IDENTIFIKATORPOLZOVATELYASERVISA,
        t.SVOYSTVAPOLZOVATELYAIB = s.SVOYSTVAPOLZOVATELYAIB,
        t.RSD_PARATNERYRASPREDELENIYAPOMESHCHENIY_ID = s.RSD_PARATNERYRASPREDELENIYAPOMESHCHENIY_ID,
        t.RSD_NOVYYINTERFEYSDLYASPISKADOKUMENTOV = s.RSD_NOVYYINTERFEYSDLYASPISKADOKUMENTOV
when not matched then insert (LEGACY_REF, IS_DELETED, NAME, NEDEYSTVITELEN, PREDSTAVLENIEVDOKUMENTAKH, RAZRESHENNYEVEBSERVERY, FIZLITSO_ID, KOMMENTARIY, SLUZHEBNYY, PODGOTOVLEN, IDENTIFIKATORPOLZOVATELYAIB, PREDSTAVLENIEVPEREPISKE, PREDSTAVLENIEVPEREPISKESRANGOM, POMESHCHENIE_ID, KODYAZYKA, IDENTIFIKATORPOLZOVATELYASERVISA, SVOYSTVAPOLZOVATELYAIB, RSD_PARATNERYRASPREDELENIYAPOMESHCHENIY_ID, RSD_NOVYYINTERFEYSDLYASPISKADOKUMENTOV)
    values (s.LEGACY_REF, s.IS_DELETED, s.NAME, s.NEDEYSTVITELEN, s.PREDSTAVLENIEVDOKUMENTAKH, s.RAZRESHENNYEVEBSERVERY, s.FIZLITSO_ID, s.KOMMENTARIY, s.SLUZHEBNYY, s.PODGOTOVLEN, s.IDENTIFIKATORPOLZOVATELYAIB, s.PREDSTAVLENIEVPEREPISKE, s.PREDSTAVLENIEVPEREPISKESRANGOM, s.POMESHCHENIE_ID, s.KODYAZYKA, s.IDENTIFIKATORPOLZOVATELYASERVISA, s.SVOYSTVAPOLZOVATELYAIB, s.RSD_PARATNERYRASPREDELENIYAPOMESHCHENIY_ID, s.RSD_NOVYYINTERFEYSDLYASPISKADOKUMENTOV);
commit;

-- Catalog.ФизическиеЛица → RSD_FIZICHESKIELITSA
merge into RSD_FIZICHESKIELITSA t using (
    select
        json_value(doc, '$.Ref_Key') as LEGACY_REF,
        case when lower(json_value(doc, '$."DeletionMark"')) = 'true' then true else false end as IS_DELETED,
        json_value(doc, '$."Description"') as NAME,
        to_date(substr(json_value(doc, '$."ДатаРождения"'), 1, 19), 'YYYY-MM-DD"T"HH24:MI:SS') as DATAROZHDENIYA,
        (select id from rsd_enums where enum_type = 'ПолФизическогоЛица' and value_key = json_value(doc, '$."Пол"')) as POL_ID,
        json_value(doc, '$."Комментарий"') as KOMMENTARIY,
        (select tgt.id from RSD_GRUPPYDOSTUPAFIZICHESKIKHLITS tgt where tgt.legacy_ref = nullif(json_value(doc, '$."ГруппаДоступа_Key"'), '00000000-0000-0000-0000-000000000000')) as GRUPPADOSTUPA_ID,
        json_value(doc, '$."ФайлФотографии"') as FAYLFOTOGRAFII
    from rsd_odata_raw where entity = 'Catalog.ФизическиеЛица'
) s on (t.legacy_ref = s.LEGACY_REF)
when matched then update set
        t.IS_DELETED = s.IS_DELETED,
        t.NAME = s.NAME,
        t.DATAROZHDENIYA = s.DATAROZHDENIYA,
        t.POL_ID = s.POL_ID,
        t.KOMMENTARIY = s.KOMMENTARIY,
        t.GRUPPADOSTUPA_ID = s.GRUPPADOSTUPA_ID,
        t.FAYLFOTOGRAFII = s.FAYLFOTOGRAFII
when not matched then insert (LEGACY_REF, IS_DELETED, NAME, DATAROZHDENIYA, POL_ID, KOMMENTARIY, GRUPPADOSTUPA_ID, FAYLFOTOGRAFII)
    values (s.LEGACY_REF, s.IS_DELETED, s.NAME, s.DATAROZHDENIYA, s.POL_ID, s.KOMMENTARIY, s.GRUPPADOSTUPA_ID, s.FAYLFOTOGRAFII);
commit;

-- Catalog.БанковскиеСчета → RSD_BANKOVSKIESCHETA
merge into RSD_BANKOVSKIESCHETA t using (
    select
        json_value(doc, '$.Ref_Key') as LEGACY_REF,
        case when lower(json_value(doc, '$."DeletionMark"')) = 'true' then true else false end as IS_DELETED,
        json_value(doc, '$."Code"') as CODE,
        json_value(doc, '$."Description"') as NAME,
        json_value(doc, '$."НомерСчета"') as NOMERSCHETA,
        cast(null as number) as BANK_ID,
        json_value(doc, '$."ТекстКорреспондента"') as TEKSTKORRESPONDENTA,
        json_value(doc, '$."ТекстНазначения"') as TEKSTNAZNACHENIYA,
        json_value(doc, '$."ВидСчета"') as VIDSCHETA,
        (select tgt.id from RSD_VALYUTY tgt where tgt.legacy_ref = nullif(json_value(doc, '$."ВалютаДенежныхСредств_Key"'), '00000000-0000-0000-0000-000000000000')) as VALYUTADENEZHNYKHSREDSTV_ID,
        json_value(doc, '$."НомерИДатаРазрешения"') as NOMERIDATARAZRESHENIYA,
        to_date(substr(json_value(doc, '$."ДатаОткрытия"'), 1, 19), 'YYYY-MM-DD"T"HH24:MI:SS') as DATAOTKRYTIYA,
        to_date(substr(json_value(doc, '$."ДатаЗакрытия"'), 1, 19), 'YYYY-MM-DD"T"HH24:MI:SS') as DATAZAKRYTIYA,
        case when lower(json_value(doc, '$."МесяцПрописью"')) = 'true' then true else false end as MESYATSPROPISYU
    from rsd_odata_raw where entity = 'Catalog.БанковскиеСчета'
) s on (t.legacy_ref = s.LEGACY_REF)
when matched then update set
        t.IS_DELETED = s.IS_DELETED,
        t.CODE = s.CODE,
        t.NAME = s.NAME,
        t.NOMERSCHETA = s.NOMERSCHETA,
        t.BANK_ID = s.BANK_ID,
        t.TEKSTKORRESPONDENTA = s.TEKSTKORRESPONDENTA,
        t.TEKSTNAZNACHENIYA = s.TEKSTNAZNACHENIYA,
        t.VIDSCHETA = s.VIDSCHETA,
        t.VALYUTADENEZHNYKHSREDSTV_ID = s.VALYUTADENEZHNYKHSREDSTV_ID,
        t.NOMERIDATARAZRESHENIYA = s.NOMERIDATARAZRESHENIYA,
        t.DATAOTKRYTIYA = s.DATAOTKRYTIYA,
        t.DATAZAKRYTIYA = s.DATAZAKRYTIYA,
        t.MESYATSPROPISYU = s.MESYATSPROPISYU
when not matched then insert (LEGACY_REF, IS_DELETED, CODE, NAME, NOMERSCHETA, BANK_ID, TEKSTKORRESPONDENTA, TEKSTNAZNACHENIYA, VIDSCHETA, VALYUTADENEZHNYKHSREDSTV_ID, NOMERIDATARAZRESHENIYA, DATAOTKRYTIYA, DATAZAKRYTIYA, MESYATSPROPISYU)
    values (s.LEGACY_REF, s.IS_DELETED, s.CODE, s.NAME, s.NOMERSCHETA, s.BANK_ID, s.TEKSTKORRESPONDENTA, s.TEKSTNAZNACHENIYA, s.VIDSCHETA, s.VALYUTADENEZHNYKHSREDSTV_ID, s.NOMERIDATARAZRESHENIYA, s.DATAOTKRYTIYA, s.DATAZAKRYTIYA, s.MESYATSPROPISYU);
commit;

-- Catalog.Валюты → RSD_VALYUTY
merge into RSD_VALYUTY t using (
    select
        json_value(doc, '$.Ref_Key') as LEGACY_REF,
        case when lower(json_value(doc, '$."DeletionMark"')) = 'true' then true else false end as IS_DELETED,
        json_value(doc, '$."Code"') as CODE,
        json_value(doc, '$."Description"') as NAME,
        case when lower(json_value(doc, '$."ЗагружаетсяИзИнтернета"')) = 'true' then true else false end as ZAGRUZHAETSYAIZINTERNETA,
        json_value(doc, '$."НаименованиеПолное"') as NAIMENOVANIEPOLNOE,
        to_number(json_value(doc, '$."Наценка"') default null on conversion error) as NATSENKA,
        (select tgt.id from RSD_VALYUTY tgt where tgt.legacy_ref = nullif(json_value(doc, '$."ОсновнаяВалюта_Key"'), '00000000-0000-0000-0000-000000000000')) as OSNOVNAYAVALYUTA_ID,
        json_value(doc, '$."ПараметрыПрописиНаРусском"') as PARAMETRYPROPISINARUSSKOM,
        json_value(doc, '$."ПараметрыПрописиНаУкраинском"') as PARAMETRYPROPISINAUKRAINSKOM,
        json_value(doc, '$."ФормулаРасчетаКурса"') as FORMULARASCHETAKURSA,
        (select id from rsd_enums where enum_type = 'СпособыУстановкиКурсаВалюты' and value_key = json_value(doc, '$."СпособУстановкиКурса"')) as SPOSOBUSTANOVKIKURSA_ID
    from rsd_odata_raw where entity = 'Catalog.Валюты'
) s on (t.legacy_ref = s.LEGACY_REF)
when matched then update set
        t.IS_DELETED = s.IS_DELETED,
        t.CODE = s.CODE,
        t.NAME = s.NAME,
        t.ZAGRUZHAETSYAIZINTERNETA = s.ZAGRUZHAETSYAIZINTERNETA,
        t.NAIMENOVANIEPOLNOE = s.NAIMENOVANIEPOLNOE,
        t.NATSENKA = s.NATSENKA,
        t.OSNOVNAYAVALYUTA_ID = s.OSNOVNAYAVALYUTA_ID,
        t.PARAMETRYPROPISINARUSSKOM = s.PARAMETRYPROPISINARUSSKOM,
        t.PARAMETRYPROPISINAUKRAINSKOM = s.PARAMETRYPROPISINAUKRAINSKOM,
        t.FORMULARASCHETAKURSA = s.FORMULARASCHETAKURSA,
        t.SPOSOBUSTANOVKIKURSA_ID = s.SPOSOBUSTANOVKIKURSA_ID
when not matched then insert (LEGACY_REF, IS_DELETED, CODE, NAME, ZAGRUZHAETSYAIZINTERNETA, NAIMENOVANIEPOLNOE, NATSENKA, OSNOVNAYAVALYUTA_ID, PARAMETRYPROPISINARUSSKOM, PARAMETRYPROPISINAUKRAINSKOM, FORMULARASCHETAKURSA, SPOSOBUSTANOVKIKURSA_ID)
    values (s.LEGACY_REF, s.IS_DELETED, s.CODE, s.NAME, s.ZAGRUZHAETSYAIZINTERNETA, s.NAIMENOVANIEPOLNOE, s.NATSENKA, s.OSNOVNAYAVALYUTA_ID, s.PARAMETRYPROPISINARUSSKOM, s.PARAMETRYPROPISINAUKRAINSKOM, s.FORMULARASCHETAKURSA, s.SPOSOBUSTANOVKIKURSA_ID);
commit;
