-- Батч 004: типізована проекція RAW → RSD_*. Запускати ДВІЧІ (цикли).
-- NLS_LANG=.AL32UTF8.
set define off

-- BusinessProcess.РешениеВопросовВыполненияЗадач → RSD_RESHENIEVOPROSOVVYPOLNENIYAZADACH
merge into RSD_RESHENIEVOPROSOVVYPOLNENIYAZADACH t using (
    select
        json_value(doc, '$.Ref_Key') as LEGACY_REF,
        case when lower(json_value(doc, '$."DeletionMark"')) = 'true' then true else false end as IS_DELETED,
        to_timestamp(substr(json_value(doc, '$."Date"'), 1, 19), 'YYYY-MM-DD"T"HH24:MI:SS') as DOC_DATE,
        (select tgt.id from RSD_POLZOVATELI tgt where tgt.legacy_ref = nullif(json_value(doc, '$."Автор_Key"'), '00000000-0000-0000-0000-000000000000')) as AVTOR_ID,
        (select id from rsd_enums where enum_type = 'ВариантыВажностиЗадачи' and value_key = json_value(doc, '$."Важность"')) as VAZHNOST_ID,
        (select id from rsd_enums where enum_type = 'ВидыВопросовВыполненияЗадач' and value_key = json_value(doc, '$."ВидВопроса"')) as VIDVOPROSA_ID,
        cast(null as number) as GLAVNAYAZADACHA_ID,
        to_timestamp(substr(json_value(doc, '$."ДатаЗавершения"'), 1, 19), 'YYYY-MM-DD"T"HH24:MI:SS') as DATAZAVERSHENIYA,
        to_timestamp(substr(json_value(doc, '$."ДатаНачала"'), 1, 19), 'YYYY-MM-DD"T"HH24:MI:SS') as DATANACHALA,
        to_number(json_value(doc, '$."Итерация"') default null on conversion error) as ITERATSIYA,
        json_value(doc, '$."Наименование"') as NAIMENOVANIE,
        json_value(doc, '$."Описание"') as OPISANIE,
        to_timestamp(substr(json_value(doc, '$."НовыйСрок"'), 1, 19), 'YYYY-MM-DD"T"HH24:MI:SS') as NOVYYSROK,
        case when lower(json_value(doc, '$."ОтправитьНаУточнение"')) = 'true' then true else false end as OTPRAVITNAUTOCHNENIE,
        cast(null as number) as PREDMETRASSMOTRENIYA_ID,
        json_value(doc, '$."ПринятоеРешение"') as PRINYATOERESHENIE,
        to_timestamp(substr(json_value(doc, '$."СрокИсполнения"'), 1, 19), 'YYYY-MM-DD"T"HH24:MI:SS') as SROKISPOLNENIYA,
        json_value(doc, '$."ПричинаПрерывания"') as PRICHINAPRERYVANIYA,
        cast(null as number) as PROEKT_ID,
        cast(null as number) as PROEKTNAYAZADACHA_ID,
        (select id from rsd_enums where enum_type = 'СостоянияБизнесПроцессов' and value_key = json_value(doc, '$."Состояние"')) as SOSTOYANIE_ID,
        json_value(doc, '$."УдалитьРезультатВыполнения"') as UDALITREZULTATVYPOLNENIYA,
        json_value(doc, '$."УзелОбмена"') as UZELOBMENA
    from rsd_odata_raw where entity = 'BusinessProcess.РешениеВопросовВыполненияЗадач'
) s on (t.legacy_ref = s.LEGACY_REF)
when matched then update set
        t.IS_DELETED = s.IS_DELETED,
        t.DOC_DATE = s.DOC_DATE,
        t.AVTOR_ID = s.AVTOR_ID,
        t.VAZHNOST_ID = s.VAZHNOST_ID,
        t.VIDVOPROSA_ID = s.VIDVOPROSA_ID,
        t.GLAVNAYAZADACHA_ID = s.GLAVNAYAZADACHA_ID,
        t.DATAZAVERSHENIYA = s.DATAZAVERSHENIYA,
        t.DATANACHALA = s.DATANACHALA,
        t.ITERATSIYA = s.ITERATSIYA,
        t.NAIMENOVANIE = s.NAIMENOVANIE,
        t.OPISANIE = s.OPISANIE,
        t.NOVYYSROK = s.NOVYYSROK,
        t.OTPRAVITNAUTOCHNENIE = s.OTPRAVITNAUTOCHNENIE,
        t.PREDMETRASSMOTRENIYA_ID = s.PREDMETRASSMOTRENIYA_ID,
        t.PRINYATOERESHENIE = s.PRINYATOERESHENIE,
        t.SROKISPOLNENIYA = s.SROKISPOLNENIYA,
        t.PRICHINAPRERYVANIYA = s.PRICHINAPRERYVANIYA,
        t.PROEKT_ID = s.PROEKT_ID,
        t.PROEKTNAYAZADACHA_ID = s.PROEKTNAYAZADACHA_ID,
        t.SOSTOYANIE_ID = s.SOSTOYANIE_ID,
        t.UDALITREZULTATVYPOLNENIYA = s.UDALITREZULTATVYPOLNENIYA,
        t.UZELOBMENA = s.UZELOBMENA
when not matched then insert (LEGACY_REF, IS_DELETED, DOC_DATE, AVTOR_ID, VAZHNOST_ID, VIDVOPROSA_ID, GLAVNAYAZADACHA_ID, DATAZAVERSHENIYA, DATANACHALA, ITERATSIYA, NAIMENOVANIE, OPISANIE, NOVYYSROK, OTPRAVITNAUTOCHNENIE, PREDMETRASSMOTRENIYA_ID, PRINYATOERESHENIE, SROKISPOLNENIYA, PRICHINAPRERYVANIYA, PROEKT_ID, PROEKTNAYAZADACHA_ID, SOSTOYANIE_ID, UDALITREZULTATVYPOLNENIYA, UZELOBMENA)
    values (s.LEGACY_REF, s.IS_DELETED, s.DOC_DATE, s.AVTOR_ID, s.VAZHNOST_ID, s.VIDVOPROSA_ID, s.GLAVNAYAZADACHA_ID, s.DATAZAVERSHENIYA, s.DATANACHALA, s.ITERATSIYA, s.NAIMENOVANIE, s.OPISANIE, s.NOVYYSROK, s.OTPRAVITNAUTOCHNENIE, s.PREDMETRASSMOTRENIYA_ID, s.PRINYATOERESHENIE, s.SROKISPOLNENIYA, s.PRICHINAPRERYVANIYA, s.PROEKT_ID, s.PROEKTNAYAZADACHA_ID, s.SOSTOYANIE_ID, s.UDALITREZULTATVYPOLNENIYA, s.UZELOBMENA);
commit;

-- ТЧ ДополнительныеРеквизиты → RSD_RESHENIEVOPROSOVVYPOLNENIYAZADACH_DOPOLNITELNYEREKVIZITY
delete from RSD_RESHENIEVOPROSOVVYPOLNENIYAZADACH_DOPOLNITELNYEREKVIZITY where owner_id in (select id from RSD_RESHENIEVOPROSOVVYPOLNENIYAZADACH);
insert into RSD_RESHENIEVOPROSOVVYPOLNENIYAZADACH_DOPOLNITELNYEREKVIZITY (OWNER_ID, LINE_NO, SVOYSTVO_ID, TEKSTOVAYASTROKA)
select p.id, jt.LINE_NO, cast(null as number), jt.c1
from rsd_odata_raw r
    join RSD_RESHENIEVOPROSOVVYPOLNENIYAZADACH p on p.legacy_ref = r.ref_key
    cross join json_table(r.doc, '$."ДополнительныеРеквизиты"[*]' columns (
            LINE_NO for ordinality,
            c0 varchar2(4000) path '$."Свойство_Key"',
            c1 varchar2(4000) path '$."ТекстоваяСтрока"'
    )) jt
where r.entity = 'BusinessProcess.РешениеВопросовВыполненияЗадач';
commit;

-- ТЧ Предметы → RSD_RESHENIEVOPROSOVVYPOLNENIYAZADACH_PREDMETY
delete from RSD_RESHENIEVOPROSOVVYPOLNENIYAZADACH_PREDMETY where owner_id in (select id from RSD_RESHENIEVOPROSOVVYPOLNENIYAZADACH);
insert into RSD_RESHENIEVOPROSOVVYPOLNENIYAZADACH_PREDMETY (OWNER_ID, LINE_NO, ROLPREDMETA_ID, IMYAPREDMETA_ID, IMYAPREDMETAOSNOVANIE_ID)
select p.id, jt.LINE_NO, (select id from rsd_enums where enum_type = 'РолиПредметов' and value_key = jt.c0), cast(null as number), cast(null as number)
from rsd_odata_raw r
    join RSD_RESHENIEVOPROSOVVYPOLNENIYAZADACH p on p.legacy_ref = r.ref_key
    cross join json_table(r.doc, '$."Предметы"[*]' columns (
            LINE_NO for ordinality,
            c0 varchar2(4000) path '$."РольПредмета"',
            c1 varchar2(4000) path '$."ИмяПредмета_Key"',
            c2 varchar2(4000) path '$."ИмяПредметаОснование_Key"'
    )) jt
where r.entity = 'BusinessProcess.РешениеВопросовВыполненияЗадач';
commit;

-- ТЧ ПредметыЗадач → RSD_RESHENIEVOPROSOVVYPOLNENIYAZADACH_PREDMETYZADACH
delete from RSD_RESHENIEVOPROSOVVYPOLNENIYAZADACH_PREDMETYZADACH where owner_id in (select id from RSD_RESHENIEVOPROSOVVYPOLNENIYAZADACH);
insert into RSD_RESHENIEVOPROSOVVYPOLNENIYAZADACH_PREDMETYZADACH (OWNER_ID, LINE_NO, TOCHKAMARSHRUTA_ID, IMYAPREDMETA_ID, OBYAZATELNOEZAPOLNENIE, DOSTUPNOUDALENIE)
select p.id, jt.LINE_NO, cast(null as number), cast(null as number), case when lower(jt.c2) = 'true' then true else false end, case when lower(jt.c3) = 'true' then true else false end
from rsd_odata_raw r
    join RSD_RESHENIEVOPROSOVVYPOLNENIYAZADACH p on p.legacy_ref = r.ref_key
    cross join json_table(r.doc, '$."ПредметыЗадач"[*]' columns (
            LINE_NO for ordinality,
            c0 varchar2(4000) path '$."ТочкаМаршрута_Key"',
            c1 varchar2(4000) path '$."ИмяПредмета_Key"',
            c2 varchar2(4000) path '$."ОбязательноеЗаполнение"',
            c3 varchar2(4000) path '$."ДоступноУдаление"'
    )) jt
where r.entity = 'BusinessProcess.РешениеВопросовВыполненияЗадач';
commit;

-- ТЧ ЦиклыРассмотрения → RSD_RESHENIEVOPROSOVVYPOLNENIYAZADACH_TSIKLYRASSMOTRENIYA
delete from RSD_RESHENIEVOPROSOVVYPOLNENIYAZADACH_TSIKLYRASSMOTRENIYA where owner_id in (select id from RSD_RESHENIEVOPROSOVVYPOLNENIYAZADACH);
insert into RSD_RESHENIEVOPROSOVVYPOLNENIYAZADACH_TSIKLYRASSMOTRENIYA (OWNER_ID, LINE_NO, TSIKL, ZADACHA_ID)
select p.id, jt.LINE_NO, to_number(jt.c0 default null on conversion error), cast(null as number)
from rsd_odata_raw r
    join RSD_RESHENIEVOPROSOVVYPOLNENIYAZADACH p on p.legacy_ref = r.ref_key
    cross join json_table(r.doc, '$."ЦиклыРассмотрения"[*]' columns (
            LINE_NO for ordinality,
            c0 varchar2(4000) path '$."Цикл"',
            c1 varchar2(4000) path '$."Задача_Key"'
    )) jt
where r.entity = 'BusinessProcess.РешениеВопросовВыполненияЗадач';
commit;

-- BusinessProcess.Рассмотрение → RSD_RASSMOTRENIE
merge into RSD_RASSMOTRENIE t using (
    select
        json_value(doc, '$.Ref_Key') as LEGACY_REF,
        case when lower(json_value(doc, '$."DeletionMark"')) = 'true' then true else false end as IS_DELETED,
        to_timestamp(substr(json_value(doc, '$."Date"'), 1, 19), 'YYYY-MM-DD"T"HH24:MI:SS') as DOC_DATE,
        (select tgt.id from RSD_POLZOVATELI tgt where tgt.legacy_ref = nullif(json_value(doc, '$."Автор_Key"'), '00000000-0000-0000-0000-000000000000')) as AVTOR_ID,
        (select id from rsd_enums where enum_type = 'ВариантыВажностиЗадачи' and value_key = json_value(doc, '$."Важность"')) as VAZHNOST_ID,
        (select id from rsd_enums where enum_type = 'ВариантыВажностиЗадачи' and value_key = json_value(doc, '$."ВажностьИсполнения"')) as VAZHNOSTISPOLNENIYA_ID,
        (select id from rsd_enums where enum_type = 'ВариантыВажностиЗадачи' and value_key = json_value(doc, '$."ВажностьОзнакомления"')) as VAZHNOSTOZNAKOMLENIYA_ID,
        (select id from rsd_enums where enum_type = 'ВариантыМаршрутизацииЗадач' and value_key = json_value(doc, '$."ВариантИсполнения"')) as VARIANTISPOLNENIYA_ID,
        (select id from rsd_enums where enum_type = 'ВариантыОбработкиРезолюции' and value_key = json_value(doc, '$."ВариантОбработкиРезолюции"')) as VARIANTOBRABOTKIREZOLYUTSII_ID,
        (select id from rsd_enums where enum_type = 'ВариантыРассмотрения' and value_key = json_value(doc, '$."ВариантРассмотрения"')) as VARIANTRASSMOTRENIYA_ID,
        (select id from rsd_enums where enum_type = 'ВариантыУстановкиСрокаИсполнения' and value_key = json_value(doc, '$."ВариантУстановкиСрокаИсполнения"')) as VARIANTUSTANOVKISROKAISPOLNENIYA_ID,
        (select id from rsd_enums where enum_type = 'ВариантыУстановкиСрокаИсполнения' and value_key = json_value(doc, '$."ВариантУстановкиСрокаОбработкиРезультатов"')) as VARIANTUSTANOVKISROKAOBRABOTKIREZULTATOV_ID,
        (select id from rsd_enums where enum_type = 'ВариантыУстановкиСрокаИсполнения' and value_key = json_value(doc, '$."ВариантУстановкиСрокаОбработкиРезультатовИсполнения"')) as VARIANTUSTANOVKISROKAOBRABOTKIREZULTATOVISPOLNENIYA_ID,
        cast(null as number) as GLAVNAYAZADACHA_ID,
        to_timestamp(substr(json_value(doc, '$."ДатаЗавершения"'), 1, 19), 'YYYY-MM-DD"T"HH24:MI:SS') as DATAZAVERSHENIYA,
        to_timestamp(substr(json_value(doc, '$."ДатаНачала"'), 1, 19), 'YYYY-MM-DD"T"HH24:MI:SS') as DATANACHALA,
        to_number(json_value(doc, '$."КоличествоИтерацийИсполнения"') default null on conversion error) as KOLICHESTVOITERATSIYISPOLNENIYA,
        json_value(doc, '$."Наименование"') as NAIMENOVANIE,
        json_value(doc, '$."НаименованиеИсполнения"') as NAIMENOVANIEISPOLNENIYA,
        json_value(doc, '$."НаименованиеОзнакомления"') as NAIMENOVANIEOZNAKOMLENIYA,
        json_value(doc, '$."Описание"') as OPISANIE,
        json_value(doc, '$."ОписаниеИсполнения"') as OPISANIEISPOLNENIYA,
        json_value(doc, '$."ОписаниеОзнакомления"') as OPISANIEOZNAKOMLENIYA,
        case when lower(json_value(doc, '$."ПоставитьДокументНаКонтроль"')) = 'true' then true else false end as POSTAVITDOKUMENTNAKONTROL,
        json_value(doc, '$."ПричинаПрерывания"') as PRICHINAPRERYVANIYA,
        cast(null as number) as PROEKT_ID,
        cast(null as number) as PROEKTNAYAZADACHA_ID,
        json_value(doc, '$."Резолюция"') as REZOLYUTSIYA,
        (select id from rsd_enums where enum_type = 'СостоянияБизнесПроцессов' and value_key = json_value(doc, '$."Состояние"')) as SOSTOYANIE_ID,
        to_timestamp(substr(json_value(doc, '$."СрокИсполнения"'), 1, 19), 'YYYY-MM-DD"T"HH24:MI:SS') as SROKISPOLNENIYA,
        to_number(json_value(doc, '$."СрокИсполненияДни"') default null on conversion error) as SROKISPOLNENIYADNI,
        to_number(json_value(doc, '$."СрокИсполненияМинуты"') default null on conversion error) as SROKISPOLNENIYAMINUTY,
        to_timestamp(substr(json_value(doc, '$."СрокИсполненияПроцесса"'), 1, 19), 'YYYY-MM-DD"T"HH24:MI:SS') as SROKISPOLNENIYAPROTSESSA,
        to_timestamp(substr(json_value(doc, '$."СрокИсполненияПроцессаИсполнения"'), 1, 19), 'YYYY-MM-DD"T"HH24:MI:SS') as SROKISPOLNENIYAPROTSESSAISPOLNENIYA,
        to_timestamp(substr(json_value(doc, '$."СрокИсполненияПроцессаОзнакомления"'), 1, 19), 'YYYY-MM-DD"T"HH24:MI:SS') as SROKISPOLNENIYAPROTSESSAOZNAKOMLENIYA,
        to_number(json_value(doc, '$."СрокИсполненияЧасы"') default null on conversion error) as SROKISPOLNENIYACHASY,
        to_timestamp(substr(json_value(doc, '$."СрокОбработкиРезультатов"'), 1, 19), 'YYYY-MM-DD"T"HH24:MI:SS') as SROKOBRABOTKIREZULTATOV,
        to_number(json_value(doc, '$."СрокОбработкиРезультатовДни"') default null on conversion error) as SROKOBRABOTKIREZULTATOVDNI,
        to_number(json_value(doc, '$."СрокОбработкиРезультатовДниИсполнения"') default null on conversion error) as SROKOBRABOTKIREZULTATOVDNIISPOLNENIYA,
        to_timestamp(substr(json_value(doc, '$."СрокОбработкиРезультатовИсполнения"'), 1, 19), 'YYYY-MM-DD"T"HH24:MI:SS') as SROKOBRABOTKIREZULTATOVISPOLNENIYA,
        to_number(json_value(doc, '$."СрокОбработкиРезультатовМинуты"') default null on conversion error) as SROKOBRABOTKIREZULTATOVMINUTY,
        to_number(json_value(doc, '$."СрокОбработкиРезультатовМинутыИсполнения"') default null on conversion error) as SROKOBRABOTKIREZULTATOVMINUTYISPOLNENIYA,
        to_number(json_value(doc, '$."СрокОбработкиРезультатовЧасы"') default null on conversion error) as SROKOBRABOTKIREZULTATOVCHASY,
        to_number(json_value(doc, '$."СрокОбработкиРезультатовЧасыИсполнения"') default null on conversion error) as SROKOBRABOTKIREZULTATOVCHASYISPOLNENIYA,
        to_number(json_value(doc, '$."ТрудозатратыПланАвтора"') default null on conversion error) as TRUDOZATRATYPLANAVTORA,
        to_number(json_value(doc, '$."ТрудозатратыПланИсполнителя"') default null on conversion error) as TRUDOZATRATYPLANISPOLNITELYA,
        to_number(json_value(doc, '$."ТрудозатратыПланИсполнителяОзнакомления"') default null on conversion error) as TRUDOZATRATYPLANISPOLNITELYAOZNAKOMLENIYA,
        to_number(json_value(doc, '$."ТрудозатратыПланКонтролера"') default null on conversion error) as TRUDOZATRATYPLANKONTROLERA,
        to_number(json_value(doc, '$."ТрудозатратыПланПроверяющего"') default null on conversion error) as TRUDOZATRATYPLANPROVERYAYUSHCHEGO,
        to_timestamp(substr(json_value(doc, '$."УдалитьСрокИсполнения"'), 1, 19), 'YYYY-MM-DD"T"HH24:MI:SS') as UDALITSROKISPOLNENIYA,
        to_timestamp(substr(json_value(doc, '$."УдалитьСрокИсполненияОбщий"'), 1, 19), 'YYYY-MM-DD"T"HH24:MI:SS') as UDALITSROKISPOLNENIYAOBSHCHIY,
        to_timestamp(substr(json_value(doc, '$."УдалитьСрокОзнакомления"'), 1, 19), 'YYYY-MM-DD"T"HH24:MI:SS') as UDALITSROKOZNAKOMLENIYA,
        json_value(doc, '$."УзелОбмена"') as UZELOBMENA,
        cast(null as number) as SHABLON_ID,
        cast(null as number) as SHABLONISPOLNENIYA_ID,
        cast(null as number) as SHABLONOZNAKOMLENIYA_ID
    from rsd_odata_raw where entity = 'BusinessProcess.Рассмотрение'
) s on (t.legacy_ref = s.LEGACY_REF)
when matched then update set
        t.IS_DELETED = s.IS_DELETED,
        t.DOC_DATE = s.DOC_DATE,
        t.AVTOR_ID = s.AVTOR_ID,
        t.VAZHNOST_ID = s.VAZHNOST_ID,
        t.VAZHNOSTISPOLNENIYA_ID = s.VAZHNOSTISPOLNENIYA_ID,
        t.VAZHNOSTOZNAKOMLENIYA_ID = s.VAZHNOSTOZNAKOMLENIYA_ID,
        t.VARIANTISPOLNENIYA_ID = s.VARIANTISPOLNENIYA_ID,
        t.VARIANTOBRABOTKIREZOLYUTSII_ID = s.VARIANTOBRABOTKIREZOLYUTSII_ID,
        t.VARIANTRASSMOTRENIYA_ID = s.VARIANTRASSMOTRENIYA_ID,
        t.VARIANTUSTANOVKISROKAISPOLNENIYA_ID = s.VARIANTUSTANOVKISROKAISPOLNENIYA_ID,
        t.VARIANTUSTANOVKISROKAOBRABOTKIREZULTATOV_ID = s.VARIANTUSTANOVKISROKAOBRABOTKIREZULTATOV_ID,
        t.VARIANTUSTANOVKISROKAOBRABOTKIREZULTATOVISPOLNENIYA_ID = s.VARIANTUSTANOVKISROKAOBRABOTKIREZULTATOVISPOLNENIYA_ID,
        t.GLAVNAYAZADACHA_ID = s.GLAVNAYAZADACHA_ID,
        t.DATAZAVERSHENIYA = s.DATAZAVERSHENIYA,
        t.DATANACHALA = s.DATANACHALA,
        t.KOLICHESTVOITERATSIYISPOLNENIYA = s.KOLICHESTVOITERATSIYISPOLNENIYA,
        t.NAIMENOVANIE = s.NAIMENOVANIE,
        t.NAIMENOVANIEISPOLNENIYA = s.NAIMENOVANIEISPOLNENIYA,
        t.NAIMENOVANIEOZNAKOMLENIYA = s.NAIMENOVANIEOZNAKOMLENIYA,
        t.OPISANIE = s.OPISANIE,
        t.OPISANIEISPOLNENIYA = s.OPISANIEISPOLNENIYA,
        t.OPISANIEOZNAKOMLENIYA = s.OPISANIEOZNAKOMLENIYA,
        t.POSTAVITDOKUMENTNAKONTROL = s.POSTAVITDOKUMENTNAKONTROL,
        t.PRICHINAPRERYVANIYA = s.PRICHINAPRERYVANIYA,
        t.PROEKT_ID = s.PROEKT_ID,
        t.PROEKTNAYAZADACHA_ID = s.PROEKTNAYAZADACHA_ID,
        t.REZOLYUTSIYA = s.REZOLYUTSIYA,
        t.SOSTOYANIE_ID = s.SOSTOYANIE_ID,
        t.SROKISPOLNENIYA = s.SROKISPOLNENIYA,
        t.SROKISPOLNENIYADNI = s.SROKISPOLNENIYADNI,
        t.SROKISPOLNENIYAMINUTY = s.SROKISPOLNENIYAMINUTY,
        t.SROKISPOLNENIYAPROTSESSA = s.SROKISPOLNENIYAPROTSESSA,
        t.SROKISPOLNENIYAPROTSESSAISPOLNENIYA = s.SROKISPOLNENIYAPROTSESSAISPOLNENIYA,
        t.SROKISPOLNENIYAPROTSESSAOZNAKOMLENIYA = s.SROKISPOLNENIYAPROTSESSAOZNAKOMLENIYA,
        t.SROKISPOLNENIYACHASY = s.SROKISPOLNENIYACHASY,
        t.SROKOBRABOTKIREZULTATOV = s.SROKOBRABOTKIREZULTATOV,
        t.SROKOBRABOTKIREZULTATOVDNI = s.SROKOBRABOTKIREZULTATOVDNI,
        t.SROKOBRABOTKIREZULTATOVDNIISPOLNENIYA = s.SROKOBRABOTKIREZULTATOVDNIISPOLNENIYA,
        t.SROKOBRABOTKIREZULTATOVISPOLNENIYA = s.SROKOBRABOTKIREZULTATOVISPOLNENIYA,
        t.SROKOBRABOTKIREZULTATOVMINUTY = s.SROKOBRABOTKIREZULTATOVMINUTY,
        t.SROKOBRABOTKIREZULTATOVMINUTYISPOLNENIYA = s.SROKOBRABOTKIREZULTATOVMINUTYISPOLNENIYA,
        t.SROKOBRABOTKIREZULTATOVCHASY = s.SROKOBRABOTKIREZULTATOVCHASY,
        t.SROKOBRABOTKIREZULTATOVCHASYISPOLNENIYA = s.SROKOBRABOTKIREZULTATOVCHASYISPOLNENIYA,
        t.TRUDOZATRATYPLANAVTORA = s.TRUDOZATRATYPLANAVTORA,
        t.TRUDOZATRATYPLANISPOLNITELYA = s.TRUDOZATRATYPLANISPOLNITELYA,
        t.TRUDOZATRATYPLANISPOLNITELYAOZNAKOMLENIYA = s.TRUDOZATRATYPLANISPOLNITELYAOZNAKOMLENIYA,
        t.TRUDOZATRATYPLANKONTROLERA = s.TRUDOZATRATYPLANKONTROLERA,
        t.TRUDOZATRATYPLANPROVERYAYUSHCHEGO = s.TRUDOZATRATYPLANPROVERYAYUSHCHEGO,
        t.UDALITSROKISPOLNENIYA = s.UDALITSROKISPOLNENIYA,
        t.UDALITSROKISPOLNENIYAOBSHCHIY = s.UDALITSROKISPOLNENIYAOBSHCHIY,
        t.UDALITSROKOZNAKOMLENIYA = s.UDALITSROKOZNAKOMLENIYA,
        t.UZELOBMENA = s.UZELOBMENA,
        t.SHABLON_ID = s.SHABLON_ID,
        t.SHABLONISPOLNENIYA_ID = s.SHABLONISPOLNENIYA_ID,
        t.SHABLONOZNAKOMLENIYA_ID = s.SHABLONOZNAKOMLENIYA_ID
when not matched then insert (LEGACY_REF, IS_DELETED, DOC_DATE, AVTOR_ID, VAZHNOST_ID, VAZHNOSTISPOLNENIYA_ID, VAZHNOSTOZNAKOMLENIYA_ID, VARIANTISPOLNENIYA_ID, VARIANTOBRABOTKIREZOLYUTSII_ID, VARIANTRASSMOTRENIYA_ID, VARIANTUSTANOVKISROKAISPOLNENIYA_ID, VARIANTUSTANOVKISROKAOBRABOTKIREZULTATOV_ID, VARIANTUSTANOVKISROKAOBRABOTKIREZULTATOVISPOLNENIYA_ID, GLAVNAYAZADACHA_ID, DATAZAVERSHENIYA, DATANACHALA, KOLICHESTVOITERATSIYISPOLNENIYA, NAIMENOVANIE, NAIMENOVANIEISPOLNENIYA, NAIMENOVANIEOZNAKOMLENIYA, OPISANIE, OPISANIEISPOLNENIYA, OPISANIEOZNAKOMLENIYA, POSTAVITDOKUMENTNAKONTROL, PRICHINAPRERYVANIYA, PROEKT_ID, PROEKTNAYAZADACHA_ID, REZOLYUTSIYA, SOSTOYANIE_ID, SROKISPOLNENIYA, SROKISPOLNENIYADNI, SROKISPOLNENIYAMINUTY, SROKISPOLNENIYAPROTSESSA, SROKISPOLNENIYAPROTSESSAISPOLNENIYA, SROKISPOLNENIYAPROTSESSAOZNAKOMLENIYA, SROKISPOLNENIYACHASY, SROKOBRABOTKIREZULTATOV, SROKOBRABOTKIREZULTATOVDNI, SROKOBRABOTKIREZULTATOVDNIISPOLNENIYA, SROKOBRABOTKIREZULTATOVISPOLNENIYA, SROKOBRABOTKIREZULTATOVMINUTY, SROKOBRABOTKIREZULTATOVMINUTYISPOLNENIYA, SROKOBRABOTKIREZULTATOVCHASY, SROKOBRABOTKIREZULTATOVCHASYISPOLNENIYA, TRUDOZATRATYPLANAVTORA, TRUDOZATRATYPLANISPOLNITELYA, TRUDOZATRATYPLANISPOLNITELYAOZNAKOMLENIYA, TRUDOZATRATYPLANKONTROLERA, TRUDOZATRATYPLANPROVERYAYUSHCHEGO, UDALITSROKISPOLNENIYA, UDALITSROKISPOLNENIYAOBSHCHIY, UDALITSROKOZNAKOMLENIYA, UZELOBMENA, SHABLON_ID, SHABLONISPOLNENIYA_ID, SHABLONOZNAKOMLENIYA_ID)
    values (s.LEGACY_REF, s.IS_DELETED, s.DOC_DATE, s.AVTOR_ID, s.VAZHNOST_ID, s.VAZHNOSTISPOLNENIYA_ID, s.VAZHNOSTOZNAKOMLENIYA_ID, s.VARIANTISPOLNENIYA_ID, s.VARIANTOBRABOTKIREZOLYUTSII_ID, s.VARIANTRASSMOTRENIYA_ID, s.VARIANTUSTANOVKISROKAISPOLNENIYA_ID, s.VARIANTUSTANOVKISROKAOBRABOTKIREZULTATOV_ID, s.VARIANTUSTANOVKISROKAOBRABOTKIREZULTATOVISPOLNENIYA_ID, s.GLAVNAYAZADACHA_ID, s.DATAZAVERSHENIYA, s.DATANACHALA, s.KOLICHESTVOITERATSIYISPOLNENIYA, s.NAIMENOVANIE, s.NAIMENOVANIEISPOLNENIYA, s.NAIMENOVANIEOZNAKOMLENIYA, s.OPISANIE, s.OPISANIEISPOLNENIYA, s.OPISANIEOZNAKOMLENIYA, s.POSTAVITDOKUMENTNAKONTROL, s.PRICHINAPRERYVANIYA, s.PROEKT_ID, s.PROEKTNAYAZADACHA_ID, s.REZOLYUTSIYA, s.SOSTOYANIE_ID, s.SROKISPOLNENIYA, s.SROKISPOLNENIYADNI, s.SROKISPOLNENIYAMINUTY, s.SROKISPOLNENIYAPROTSESSA, s.SROKISPOLNENIYAPROTSESSAISPOLNENIYA, s.SROKISPOLNENIYAPROTSESSAOZNAKOMLENIYA, s.SROKISPOLNENIYACHASY, s.SROKOBRABOTKIREZULTATOV, s.SROKOBRABOTKIREZULTATOVDNI, s.SROKOBRABOTKIREZULTATOVDNIISPOLNENIYA, s.SROKOBRABOTKIREZULTATOVISPOLNENIYA, s.SROKOBRABOTKIREZULTATOVMINUTY, s.SROKOBRABOTKIREZULTATOVMINUTYISPOLNENIYA, s.SROKOBRABOTKIREZULTATOVCHASY, s.SROKOBRABOTKIREZULTATOVCHASYISPOLNENIYA, s.TRUDOZATRATYPLANAVTORA, s.TRUDOZATRATYPLANISPOLNITELYA, s.TRUDOZATRATYPLANISPOLNITELYAOZNAKOMLENIYA, s.TRUDOZATRATYPLANKONTROLERA, s.TRUDOZATRATYPLANPROVERYAYUSHCHEGO, s.UDALITSROKISPOLNENIYA, s.UDALITSROKISPOLNENIYAOBSHCHIY, s.UDALITSROKOZNAKOMLENIYA, s.UZELOBMENA, s.SHABLON_ID, s.SHABLONISPOLNENIYA_ID, s.SHABLONOZNAKOMLENIYA_ID);
commit;

-- ТЧ ДополнительныеРеквизиты → RSD_RASSMOTRENIE_DOPOLNITELNYEREKVIZITY
delete from RSD_RASSMOTRENIE_DOPOLNITELNYEREKVIZITY where owner_id in (select id from RSD_RASSMOTRENIE);
insert into RSD_RASSMOTRENIE_DOPOLNITELNYEREKVIZITY (OWNER_ID, LINE_NO, SVOYSTVO_ID, TEKSTOVAYASTROKA)
select p.id, jt.LINE_NO, cast(null as number), jt.c1
from rsd_odata_raw r
    join RSD_RASSMOTRENIE p on p.legacy_ref = r.ref_key
    cross join json_table(r.doc, '$."ДополнительныеРеквизиты"[*]' columns (
            LINE_NO for ordinality,
            c0 varchar2(4000) path '$."Свойство_Key"',
            c1 varchar2(4000) path '$."ТекстоваяСтрока"'
    )) jt
where r.entity = 'BusinessProcess.Рассмотрение';
commit;

-- ТЧ ИсполнителиИсполнения → RSD_RASSMOTRENIE_ISPOLNITELIISPOLNENIYA
delete from RSD_RASSMOTRENIE_ISPOLNITELIISPOLNENIYA where owner_id in (select id from RSD_RASSMOTRENIE);
insert into RSD_RASSMOTRENIE_ISPOLNITELIISPOLNENIYA (OWNER_ID, LINE_NO, VARIANTUSTANOVKISROKAISPOLNENIYA_ID, OPISANIE, OTVETSTVENNYY, PORYADOKISPOLNENIYA_ID, SROKISPOLNENIYA, SROKISPOLNENIYADNI, SROKISPOLNENIYAMINUTY, SROKISPOLNENIYACHASY, TRUDOZATRATYPLANISPOLNITELYA, UDALITDLITELNOSTISPOLNENIYADNI, UDALITDLITELNOSTISPOLNENIYACHASY, UDALITSROKISPOLNENIYA)
select p.id, jt.LINE_NO, (select id from rsd_enums where enum_type = 'ВариантыУстановкиСрокаИсполнения' and value_key = jt.c0), jt.c1, case when lower(jt.c2) = 'true' then true else false end, (select id from rsd_enums where enum_type = 'ПорядокВыполненияЗадач' and value_key = jt.c3), to_timestamp(substr(jt.c4, 1, 19), 'YYYY-MM-DD"T"HH24:MI:SS'), to_number(jt.c5 default null on conversion error), to_number(jt.c6 default null on conversion error), to_number(jt.c7 default null on conversion error), to_number(jt.c8 default null on conversion error), to_number(jt.c9 default null on conversion error), to_number(jt.c10 default null on conversion error), to_timestamp(substr(jt.c11, 1, 19), 'YYYY-MM-DD"T"HH24:MI:SS')
from rsd_odata_raw r
    join RSD_RASSMOTRENIE p on p.legacy_ref = r.ref_key
    cross join json_table(r.doc, '$."ИсполнителиИсполнения"[*]' columns (
            LINE_NO for ordinality,
            c0 varchar2(4000) path '$."ВариантУстановкиСрокаИсполнения"',
            c1 varchar2(4000) path '$."Описание"',
            c2 varchar2(4000) path '$."Ответственный"',
            c3 varchar2(4000) path '$."ПорядокИсполнения"',
            c4 varchar2(4000) path '$."СрокИсполнения"',
            c5 varchar2(4000) path '$."СрокИсполненияДни"',
            c6 varchar2(4000) path '$."СрокИсполненияМинуты"',
            c7 varchar2(4000) path '$."СрокИсполненияЧасы"',
            c8 varchar2(4000) path '$."ТрудозатратыПланИсполнителя"',
            c9 varchar2(4000) path '$."УдалитьДлительностьИсполненияДни"',
            c10 varchar2(4000) path '$."УдалитьДлительностьИсполненияЧасы"',
            c11 varchar2(4000) path '$."УдалитьСрокИсполнения"'
    )) jt
where r.entity = 'BusinessProcess.Рассмотрение';
commit;

-- ТЧ ИсполнителиОзнакомления → RSD_RASSMOTRENIE_ISPOLNITELIOZNAKOMLENIYA
delete from RSD_RASSMOTRENIE_ISPOLNITELIOZNAKOMLENIYA where owner_id in (select id from RSD_RASSMOTRENIE);
insert into RSD_RASSMOTRENIE_ISPOLNITELIOZNAKOMLENIYA (OWNER_ID, LINE_NO, VARIANTUSTANOVKISROKAISPOLNENIYA_ID, SROKISPOLNENIYA, SROKISPOLNENIYADNI, SROKISPOLNENIYAMINUTY, SROKISPOLNENIYACHASY)
select p.id, jt.LINE_NO, (select id from rsd_enums where enum_type = 'ВариантыУстановкиСрокаИсполнения' and value_key = jt.c0), to_timestamp(substr(jt.c1, 1, 19), 'YYYY-MM-DD"T"HH24:MI:SS'), to_number(jt.c2 default null on conversion error), to_number(jt.c3 default null on conversion error), to_number(jt.c4 default null on conversion error)
from rsd_odata_raw r
    join RSD_RASSMOTRENIE p on p.legacy_ref = r.ref_key
    cross join json_table(r.doc, '$."ИсполнителиОзнакомления"[*]' columns (
            LINE_NO for ordinality,
            c0 varchar2(4000) path '$."ВариантУстановкиСрокаИсполнения"',
            c1 varchar2(4000) path '$."СрокИсполнения"',
            c2 varchar2(4000) path '$."СрокИсполненияДни"',
            c3 varchar2(4000) path '$."СрокИсполненияМинуты"',
            c4 varchar2(4000) path '$."СрокИсполненияЧасы"'
    )) jt
where r.entity = 'BusinessProcess.Рассмотрение';
commit;

-- ТЧ Предметы → RSD_RASSMOTRENIE_PREDMETY
delete from RSD_RASSMOTRENIE_PREDMETY where owner_id in (select id from RSD_RASSMOTRENIE);
insert into RSD_RASSMOTRENIE_PREDMETY (OWNER_ID, LINE_NO, ROLPREDMETA_ID, IMYAPREDMETA_ID, IMYAPREDMETAOSNOVANIE_ID)
select p.id, jt.LINE_NO, (select id from rsd_enums where enum_type = 'РолиПредметов' and value_key = jt.c0), cast(null as number), cast(null as number)
from rsd_odata_raw r
    join RSD_RASSMOTRENIE p on p.legacy_ref = r.ref_key
    cross join json_table(r.doc, '$."Предметы"[*]' columns (
            LINE_NO for ordinality,
            c0 varchar2(4000) path '$."РольПредмета"',
            c1 varchar2(4000) path '$."ИмяПредмета_Key"',
            c2 varchar2(4000) path '$."ИмяПредметаОснование_Key"'
    )) jt
where r.entity = 'BusinessProcess.Рассмотрение';
commit;

-- ТЧ ПредметыЗадач → RSD_RASSMOTRENIE_PREDMETYZADACH
delete from RSD_RASSMOTRENIE_PREDMETYZADACH where owner_id in (select id from RSD_RASSMOTRENIE);
insert into RSD_RASSMOTRENIE_PREDMETYZADACH (OWNER_ID, LINE_NO, TOCHKAMARSHRUTA_ID, IMYAPREDMETA_ID, OBYAZATELNOEZAPOLNENIE, DOSTUPNOUDALENIE)
select p.id, jt.LINE_NO, cast(null as number), cast(null as number), case when lower(jt.c2) = 'true' then true else false end, case when lower(jt.c3) = 'true' then true else false end
from rsd_odata_raw r
    join RSD_RASSMOTRENIE p on p.legacy_ref = r.ref_key
    cross join json_table(r.doc, '$."ПредметыЗадач"[*]' columns (
            LINE_NO for ordinality,
            c0 varchar2(4000) path '$."ТочкаМаршрута_Key"',
            c1 varchar2(4000) path '$."ИмяПредмета_Key"',
            c2 varchar2(4000) path '$."ОбязательноеЗаполнение"',
            c3 varchar2(4000) path '$."ДоступноУдаление"'
    )) jt
where r.entity = 'BusinessProcess.Рассмотрение';
commit;

-- ТЧ УдалитьДополнительныеИсполнители → RSD_RASSMOTRENIE_UDALITDOPOLNITELNYEISPOLNITELI
delete from RSD_RASSMOTRENIE_UDALITDOPOLNITELNYEISPOLNITELI where owner_id in (select id from RSD_RASSMOTRENIE);
insert into RSD_RASSMOTRENIE_UDALITDOPOLNITELNYEISPOLNITELI (OWNER_ID, LINE_NO)
select p.id, jt.LINE_NO
from rsd_odata_raw r
    join RSD_RASSMOTRENIE p on p.legacy_ref = r.ref_key
    cross join json_table(r.doc, '$."УдалитьДополнительныеИсполнители"[*]' columns (
            LINE_NO for ordinality
    )) jt
where r.entity = 'BusinessProcess.Рассмотрение';
commit;

-- BusinessProcess.ОбработкаВнутреннегоДокумента → RSD_OBRABOTKAVNUTRENNEGODOKUMENTA
merge into RSD_OBRABOTKAVNUTRENNEGODOKUMENTA t using (
    select
        json_value(doc, '$.Ref_Key') as LEGACY_REF,
        case when lower(json_value(doc, '$."DeletionMark"')) = 'true' then true else false end as IS_DELETED,
        to_timestamp(substr(json_value(doc, '$."Date"'), 1, 19), 'YYYY-MM-DD"T"HH24:MI:SS') as DOC_DATE,
        (select tgt.id from RSD_POLZOVATELI tgt where tgt.legacy_ref = nullif(json_value(doc, '$."Автор_Key"'), '00000000-0000-0000-0000-000000000000')) as AVTOR_ID,
        (select id from rsd_enums where enum_type = 'ВариантыВажностиЗадачи' and value_key = json_value(doc, '$."Важность"')) as VAZHNOST_ID,
        cast(null as number) as GLAVNAYAZADACHA_ID,
        to_timestamp(substr(json_value(doc, '$."ДатаЗавершения"'), 1, 19), 'YYYY-MM-DD"T"HH24:MI:SS') as DATAZAVERSHENIYA,
        to_timestamp(substr(json_value(doc, '$."ДатаНачала"'), 1, 19), 'YYYY-MM-DD"T"HH24:MI:SS') as DATANACHALA,
        json_value(doc, '$."Наименование"') as NAIMENOVANIE,
        json_value(doc, '$."ПричинаПрерывания"') as PRICHINAPRERYVANIYA,
        cast(null as number) as PROEKT_ID,
        cast(null as number) as PROEKTNAYAZADACHA_ID,
        cast(null as number) as RASSMOTRENIE_ID,
        (select id from rsd_enums where enum_type = 'СостоянияБизнесПроцессов' and value_key = json_value(doc, '$."Состояние"')) as SOSTOYANIE_ID,
        to_timestamp(substr(json_value(doc, '$."СрокИсполненияПроцесса"'), 1, 19), 'YYYY-MM-DD"T"HH24:MI:SS') as SROKISPOLNENIYAPROTSESSA,
        cast(null as number) as UDALITPREDMET_ID,
        json_value(doc, '$."УзелОбмена"') as UZELOBMENA,
        cast(null as number) as SHABLON_ID,
        cast(null as number) as SHABLONPORUCHENIYA_ID,
        cast(null as number) as SHABLONRASSMOTRENIYA_ID,
        cast(null as number) as SHABLONREGISTRATSII_ID,
        cast(null as number) as SHABLONSOGLASOVANIYA_ID,
        cast(null as number) as SHABLONUTVERZHDENIYA_ID
    from rsd_odata_raw where entity = 'BusinessProcess.ОбработкаВнутреннегоДокумента'
) s on (t.legacy_ref = s.LEGACY_REF)
when matched then update set
        t.IS_DELETED = s.IS_DELETED,
        t.DOC_DATE = s.DOC_DATE,
        t.AVTOR_ID = s.AVTOR_ID,
        t.VAZHNOST_ID = s.VAZHNOST_ID,
        t.GLAVNAYAZADACHA_ID = s.GLAVNAYAZADACHA_ID,
        t.DATAZAVERSHENIYA = s.DATAZAVERSHENIYA,
        t.DATANACHALA = s.DATANACHALA,
        t.NAIMENOVANIE = s.NAIMENOVANIE,
        t.PRICHINAPRERYVANIYA = s.PRICHINAPRERYVANIYA,
        t.PROEKT_ID = s.PROEKT_ID,
        t.PROEKTNAYAZADACHA_ID = s.PROEKTNAYAZADACHA_ID,
        t.RASSMOTRENIE_ID = s.RASSMOTRENIE_ID,
        t.SOSTOYANIE_ID = s.SOSTOYANIE_ID,
        t.SROKISPOLNENIYAPROTSESSA = s.SROKISPOLNENIYAPROTSESSA,
        t.UDALITPREDMET_ID = s.UDALITPREDMET_ID,
        t.UZELOBMENA = s.UZELOBMENA,
        t.SHABLON_ID = s.SHABLON_ID,
        t.SHABLONPORUCHENIYA_ID = s.SHABLONPORUCHENIYA_ID,
        t.SHABLONRASSMOTRENIYA_ID = s.SHABLONRASSMOTRENIYA_ID,
        t.SHABLONREGISTRATSII_ID = s.SHABLONREGISTRATSII_ID,
        t.SHABLONSOGLASOVANIYA_ID = s.SHABLONSOGLASOVANIYA_ID,
        t.SHABLONUTVERZHDENIYA_ID = s.SHABLONUTVERZHDENIYA_ID
when not matched then insert (LEGACY_REF, IS_DELETED, DOC_DATE, AVTOR_ID, VAZHNOST_ID, GLAVNAYAZADACHA_ID, DATAZAVERSHENIYA, DATANACHALA, NAIMENOVANIE, PRICHINAPRERYVANIYA, PROEKT_ID, PROEKTNAYAZADACHA_ID, RASSMOTRENIE_ID, SOSTOYANIE_ID, SROKISPOLNENIYAPROTSESSA, UDALITPREDMET_ID, UZELOBMENA, SHABLON_ID, SHABLONPORUCHENIYA_ID, SHABLONRASSMOTRENIYA_ID, SHABLONREGISTRATSII_ID, SHABLONSOGLASOVANIYA_ID, SHABLONUTVERZHDENIYA_ID)
    values (s.LEGACY_REF, s.IS_DELETED, s.DOC_DATE, s.AVTOR_ID, s.VAZHNOST_ID, s.GLAVNAYAZADACHA_ID, s.DATAZAVERSHENIYA, s.DATANACHALA, s.NAIMENOVANIE, s.PRICHINAPRERYVANIYA, s.PROEKT_ID, s.PROEKTNAYAZADACHA_ID, s.RASSMOTRENIE_ID, s.SOSTOYANIE_ID, s.SROKISPOLNENIYAPROTSESSA, s.UDALITPREDMET_ID, s.UZELOBMENA, s.SHABLON_ID, s.SHABLONPORUCHENIYA_ID, s.SHABLONRASSMOTRENIYA_ID, s.SHABLONREGISTRATSII_ID, s.SHABLONSOGLASOVANIYA_ID, s.SHABLONUTVERZHDENIYA_ID);
commit;

-- ТЧ ДополнительныеРеквизиты → RSD_OBRABOTKAVNUTRENNEGODOKUMENTA_DOPOLNITELNYEREKVIZITY
delete from RSD_OBRABOTKAVNUTRENNEGODOKUMENTA_DOPOLNITELNYEREKVIZITY where owner_id in (select id from RSD_OBRABOTKAVNUTRENNEGODOKUMENTA);
insert into RSD_OBRABOTKAVNUTRENNEGODOKUMENTA_DOPOLNITELNYEREKVIZITY (OWNER_ID, LINE_NO, SVOYSTVO_ID, TEKSTOVAYASTROKA)
select p.id, jt.LINE_NO, cast(null as number), jt.c1
from rsd_odata_raw r
    join RSD_OBRABOTKAVNUTRENNEGODOKUMENTA p on p.legacy_ref = r.ref_key
    cross join json_table(r.doc, '$."ДополнительныеРеквизиты"[*]' columns (
            LINE_NO for ordinality,
            c0 varchar2(4000) path '$."Свойство_Key"',
            c1 varchar2(4000) path '$."ТекстоваяСтрока"'
    )) jt
where r.entity = 'BusinessProcess.ОбработкаВнутреннегоДокумента';
commit;

-- ТЧ Предметы → RSD_OBRABOTKAVNUTRENNEGODOKUMENTA_PREDMETY
delete from RSD_OBRABOTKAVNUTRENNEGODOKUMENTA_PREDMETY where owner_id in (select id from RSD_OBRABOTKAVNUTRENNEGODOKUMENTA);
insert into RSD_OBRABOTKAVNUTRENNEGODOKUMENTA_PREDMETY (OWNER_ID, LINE_NO, ROLPREDMETA_ID, IMYAPREDMETA_ID, IMYAPREDMETAOSNOVANIE_ID)
select p.id, jt.LINE_NO, (select id from rsd_enums where enum_type = 'РолиПредметов' and value_key = jt.c0), cast(null as number), cast(null as number)
from rsd_odata_raw r
    join RSD_OBRABOTKAVNUTRENNEGODOKUMENTA p on p.legacy_ref = r.ref_key
    cross join json_table(r.doc, '$."Предметы"[*]' columns (
            LINE_NO for ordinality,
            c0 varchar2(4000) path '$."РольПредмета"',
            c1 varchar2(4000) path '$."ИмяПредмета_Key"',
            c2 varchar2(4000) path '$."ИмяПредметаОснование_Key"'
    )) jt
where r.entity = 'BusinessProcess.ОбработкаВнутреннегоДокумента';
commit;

-- ТЧ ПредметыЗадач → RSD_OBRABOTKAVNUTRENNEGODOKUMENTA_PREDMETYZADACH
delete from RSD_OBRABOTKAVNUTRENNEGODOKUMENTA_PREDMETYZADACH where owner_id in (select id from RSD_OBRABOTKAVNUTRENNEGODOKUMENTA);
insert into RSD_OBRABOTKAVNUTRENNEGODOKUMENTA_PREDMETYZADACH (OWNER_ID, LINE_NO, TOCHKAMARSHRUTA_ID, IMYAPREDMETA_ID, OBYAZATELNOEZAPOLNENIE, DOSTUPNOUDALENIE)
select p.id, jt.LINE_NO, cast(null as number), cast(null as number), case when lower(jt.c2) = 'true' then true else false end, case when lower(jt.c3) = 'true' then true else false end
from rsd_odata_raw r
    join RSD_OBRABOTKAVNUTRENNEGODOKUMENTA p on p.legacy_ref = r.ref_key
    cross join json_table(r.doc, '$."ПредметыЗадач"[*]' columns (
            LINE_NO for ordinality,
            c0 varchar2(4000) path '$."ТочкаМаршрута_Key"',
            c1 varchar2(4000) path '$."ИмяПредмета_Key"',
            c2 varchar2(4000) path '$."ОбязательноеЗаполнение"',
            c3 varchar2(4000) path '$."ДоступноУдаление"'
    )) jt
where r.entity = 'BusinessProcess.ОбработкаВнутреннегоДокумента';
commit;
