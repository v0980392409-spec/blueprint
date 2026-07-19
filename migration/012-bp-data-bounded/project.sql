-- Батч 004: типізована проекція RAW → RSD_*. Запускати ДВІЧІ (цикли).
-- NLS_LANG=.AL32UTF8.
set define off

-- BusinessProcess.Согласование → RSD_SOGLASOVANIE
merge into RSD_SOGLASOVANIE t using (
    select
        json_value(doc, '$.Ref_Key') as LEGACY_REF,
        case when lower(json_value(doc, '$."DeletionMark"')) = 'true' then true else false end as IS_DELETED,
        to_timestamp(substr(json_value(doc, '$."Date"'), 1, 19), 'YYYY-MM-DD"T"HH24:MI:SS') as DOC_DATE,
        (select tgt.id from RSD_POLZOVATELI tgt where tgt.legacy_ref = nullif(json_value(doc, '$."Автор_Key"'), '00000000-0000-0000-0000-000000000000')) as AVTOR_ID,
        (select id from rsd_enums where enum_type = 'ВариантыВажностиЗадачи' and value_key = json_value(doc, '$."Важность"')) as VAZHNOST_ID,
        (select id from rsd_enums where enum_type = 'ВариантыМаршрутизацииЗадач' and value_key = json_value(doc, '$."ВариантСогласования"')) as VARIANTSOGLASOVANIYA_ID,
        (select id from rsd_enums where enum_type = 'ВариантыУстановкиСрокаИсполнения' and value_key = json_value(doc, '$."ВариантУстановкиСрокаОбработкиРезультатов"')) as VARIANTUSTANOVKISROKAOBRABOTKIREZULTATOV_ID,
        cast(null as number) as GLAVNAYAZADACHA_ID,
        to_timestamp(substr(json_value(doc, '$."ДатаЗавершения"'), 1, 19), 'YYYY-MM-DD"T"HH24:MI:SS') as DATAZAVERSHENIYA,
        to_timestamp(substr(json_value(doc, '$."ДатаНачала"'), 1, 19), 'YYYY-MM-DD"T"HH24:MI:SS') as DATANACHALA,
        to_number(json_value(doc, '$."КоличествоИтераций"') default null on conversion error) as KOLICHESTVOITERATSIY,
        json_value(doc, '$."Наименование"') as NAIMENOVANIE,
        to_number(json_value(doc, '$."НомерИтерации"') default null on conversion error) as NOMERITERATSII,
        json_value(doc, '$."Описание"') as OPISANIE,
        case when lower(json_value(doc, '$."ПовторитьСогласование"')) = 'true' then true else false end as POVTORITSOGLASOVANIE,
        case when lower(json_value(doc, '$."ПодписыватьЭП"')) = 'true' then true else false end as PODPISYVATEP,
        json_value(doc, '$."ПричинаПрерывания"') as PRICHINAPRERYVANIYA,
        cast(null as number) as PROEKT_ID,
        cast(null as number) as PROEKTNAYAZADACHA_ID,
        (select id from rsd_enums where enum_type = 'РезультатыСогласования' and value_key = json_value(doc, '$."РезультатСогласования"')) as REZULTATSOGLASOVANIYA_ID,
        (select id from rsd_enums where enum_type = 'СостоянияБизнесПроцессов' and value_key = json_value(doc, '$."Состояние"')) as SOSTOYANIE_ID,
        to_timestamp(substr(json_value(doc, '$."СрокИсполненияПроцесса"'), 1, 19), 'YYYY-MM-DD"T"HH24:MI:SS') as SROKISPOLNENIYAPROTSESSA,
        to_timestamp(substr(json_value(doc, '$."СрокОбработкиРезультатов"'), 1, 19), 'YYYY-MM-DD"T"HH24:MI:SS') as SROKOBRABOTKIREZULTATOV,
        to_number(json_value(doc, '$."СрокОбработкиРезультатовДни"') default null on conversion error) as SROKOBRABOTKIREZULTATOVDNI,
        to_number(json_value(doc, '$."СрокОбработкиРезультатовМинуты"') default null on conversion error) as SROKOBRABOTKIREZULTATOVMINUTY,
        to_number(json_value(doc, '$."СрокОбработкиРезультатовЧасы"') default null on conversion error) as SROKOBRABOTKIREZULTATOVCHASY,
        to_number(json_value(doc, '$."ТрудозатратыПланАвтора"') default null on conversion error) as TRUDOZATRATYPLANAVTORA,
        to_number(json_value(doc, '$."ТрудозатратыПланИсполнителя"') default null on conversion error) as TRUDOZATRATYPLANISPOLNITELYA,
        case when lower(json_value(doc, '$."УдалитьРазныеСроки"')) = 'true' then true else false end as UDALITRAZNYESROKI,
        to_number(json_value(doc, '$."УдалитьСрокИсполнения"') default null on conversion error) as UDALITSROKISPOLNENIYA,
        to_timestamp(substr(json_value(doc, '$."УдалитьСрокИсполненияДатой"'), 1, 19), 'YYYY-MM-DD"T"HH24:MI:SS') as UDALITSROKISPOLNENIYADATOY,
        to_number(json_value(doc, '$."УдалитьСрокИсполненияЧас"') default null on conversion error) as UDALITSROKISPOLNENIYACHAS,
        json_value(doc, '$."УзелОбмена"') as UZELOBMENA,
        cast(null as number) as SHABLON_ID,
        json_value(doc, '$."ЭтапОбработкиПредмета"') as ETAPOBRABOTKIPREDMETA
    from rsd_odata_raw where entity = 'BusinessProcess.Согласование'
) s on (t.legacy_ref = s.LEGACY_REF)
when matched then update set
        t.IS_DELETED = s.IS_DELETED,
        t.DOC_DATE = s.DOC_DATE,
        t.AVTOR_ID = s.AVTOR_ID,
        t.VAZHNOST_ID = s.VAZHNOST_ID,
        t.VARIANTSOGLASOVANIYA_ID = s.VARIANTSOGLASOVANIYA_ID,
        t.VARIANTUSTANOVKISROKAOBRABOTKIREZULTATOV_ID = s.VARIANTUSTANOVKISROKAOBRABOTKIREZULTATOV_ID,
        t.GLAVNAYAZADACHA_ID = s.GLAVNAYAZADACHA_ID,
        t.DATAZAVERSHENIYA = s.DATAZAVERSHENIYA,
        t.DATANACHALA = s.DATANACHALA,
        t.KOLICHESTVOITERATSIY = s.KOLICHESTVOITERATSIY,
        t.NAIMENOVANIE = s.NAIMENOVANIE,
        t.NOMERITERATSII = s.NOMERITERATSII,
        t.OPISANIE = s.OPISANIE,
        t.POVTORITSOGLASOVANIE = s.POVTORITSOGLASOVANIE,
        t.PODPISYVATEP = s.PODPISYVATEP,
        t.PRICHINAPRERYVANIYA = s.PRICHINAPRERYVANIYA,
        t.PROEKT_ID = s.PROEKT_ID,
        t.PROEKTNAYAZADACHA_ID = s.PROEKTNAYAZADACHA_ID,
        t.REZULTATSOGLASOVANIYA_ID = s.REZULTATSOGLASOVANIYA_ID,
        t.SOSTOYANIE_ID = s.SOSTOYANIE_ID,
        t.SROKISPOLNENIYAPROTSESSA = s.SROKISPOLNENIYAPROTSESSA,
        t.SROKOBRABOTKIREZULTATOV = s.SROKOBRABOTKIREZULTATOV,
        t.SROKOBRABOTKIREZULTATOVDNI = s.SROKOBRABOTKIREZULTATOVDNI,
        t.SROKOBRABOTKIREZULTATOVMINUTY = s.SROKOBRABOTKIREZULTATOVMINUTY,
        t.SROKOBRABOTKIREZULTATOVCHASY = s.SROKOBRABOTKIREZULTATOVCHASY,
        t.TRUDOZATRATYPLANAVTORA = s.TRUDOZATRATYPLANAVTORA,
        t.TRUDOZATRATYPLANISPOLNITELYA = s.TRUDOZATRATYPLANISPOLNITELYA,
        t.UDALITRAZNYESROKI = s.UDALITRAZNYESROKI,
        t.UDALITSROKISPOLNENIYA = s.UDALITSROKISPOLNENIYA,
        t.UDALITSROKISPOLNENIYADATOY = s.UDALITSROKISPOLNENIYADATOY,
        t.UDALITSROKISPOLNENIYACHAS = s.UDALITSROKISPOLNENIYACHAS,
        t.UZELOBMENA = s.UZELOBMENA,
        t.SHABLON_ID = s.SHABLON_ID,
        t.ETAPOBRABOTKIPREDMETA = s.ETAPOBRABOTKIPREDMETA
when not matched then insert (LEGACY_REF, IS_DELETED, DOC_DATE, AVTOR_ID, VAZHNOST_ID, VARIANTSOGLASOVANIYA_ID, VARIANTUSTANOVKISROKAOBRABOTKIREZULTATOV_ID, GLAVNAYAZADACHA_ID, DATAZAVERSHENIYA, DATANACHALA, KOLICHESTVOITERATSIY, NAIMENOVANIE, NOMERITERATSII, OPISANIE, POVTORITSOGLASOVANIE, PODPISYVATEP, PRICHINAPRERYVANIYA, PROEKT_ID, PROEKTNAYAZADACHA_ID, REZULTATSOGLASOVANIYA_ID, SOSTOYANIE_ID, SROKISPOLNENIYAPROTSESSA, SROKOBRABOTKIREZULTATOV, SROKOBRABOTKIREZULTATOVDNI, SROKOBRABOTKIREZULTATOVMINUTY, SROKOBRABOTKIREZULTATOVCHASY, TRUDOZATRATYPLANAVTORA, TRUDOZATRATYPLANISPOLNITELYA, UDALITRAZNYESROKI, UDALITSROKISPOLNENIYA, UDALITSROKISPOLNENIYADATOY, UDALITSROKISPOLNENIYACHAS, UZELOBMENA, SHABLON_ID, ETAPOBRABOTKIPREDMETA)
    values (s.LEGACY_REF, s.IS_DELETED, s.DOC_DATE, s.AVTOR_ID, s.VAZHNOST_ID, s.VARIANTSOGLASOVANIYA_ID, s.VARIANTUSTANOVKISROKAOBRABOTKIREZULTATOV_ID, s.GLAVNAYAZADACHA_ID, s.DATAZAVERSHENIYA, s.DATANACHALA, s.KOLICHESTVOITERATSIY, s.NAIMENOVANIE, s.NOMERITERATSII, s.OPISANIE, s.POVTORITSOGLASOVANIE, s.PODPISYVATEP, s.PRICHINAPRERYVANIYA, s.PROEKT_ID, s.PROEKTNAYAZADACHA_ID, s.REZULTATSOGLASOVANIYA_ID, s.SOSTOYANIE_ID, s.SROKISPOLNENIYAPROTSESSA, s.SROKOBRABOTKIREZULTATOV, s.SROKOBRABOTKIREZULTATOVDNI, s.SROKOBRABOTKIREZULTATOVMINUTY, s.SROKOBRABOTKIREZULTATOVCHASY, s.TRUDOZATRATYPLANAVTORA, s.TRUDOZATRATYPLANISPOLNITELYA, s.UDALITRAZNYESROKI, s.UDALITSROKISPOLNENIYA, s.UDALITSROKISPOLNENIYADATOY, s.UDALITSROKISPOLNENIYACHAS, s.UZELOBMENA, s.SHABLON_ID, s.ETAPOBRABOTKIPREDMETA);
commit;

-- ТЧ ДополнительныеРеквизиты → RSD_SOGLASOVANIE_DOPOLNITELNYEREKVIZITY
delete from RSD_SOGLASOVANIE_DOPOLNITELNYEREKVIZITY where owner_id in (select id from RSD_SOGLASOVANIE);
insert into RSD_SOGLASOVANIE_DOPOLNITELNYEREKVIZITY (OWNER_ID, LINE_NO, SVOYSTVO_ID, TEKSTOVAYASTROKA)
select p.id, jt.LINE_NO, cast(null as number), jt.c1
from rsd_odata_raw r
    join RSD_SOGLASOVANIE p on p.legacy_ref = r.ref_key
    cross join json_table(r.doc, '$."ДополнительныеРеквизиты"[*]' columns (
            LINE_NO for ordinality,
            c0 varchar2(4000) path '$."Свойство_Key"',
            c1 varchar2(4000) path '$."ТекстоваяСтрока"'
    )) jt
where r.entity = 'BusinessProcess.Согласование';
commit;

-- ТЧ Исполнители → RSD_SOGLASOVANIE_ISPOLNITELI
delete from RSD_SOGLASOVANIE_ISPOLNITELI where owner_id in (select id from RSD_SOGLASOVANIE);
insert into RSD_SOGLASOVANIE_ISPOLNITELI (OWNER_ID, LINE_NO, VARIANTUSTANOVKISROKAISPOLNENIYA_ID, ZADACHAISPOLNITELYA_ID, PORYADOKSOGLASOVANIYA_ID, PROYDEN, SROKISPOLNENIYA, SROKISPOLNENIYADNI, SROKISPOLNENIYAMINUTY, SROKISPOLNENIYACHASY, TRUDOZATRATYPLANISPOLNITELYA, UDALITSROKISPOLNENIYA, UDALITSROKISPOLNENIYACHAS)
select p.id, jt.LINE_NO, (select id from rsd_enums where enum_type = 'ВариантыУстановкиСрокаИсполнения' and value_key = jt.c0), cast(null as number), (select id from rsd_enums where enum_type = 'ПорядокВыполненияЗадач' and value_key = jt.c2), case when lower(jt.c3) = 'true' then true else false end, to_timestamp(substr(jt.c4, 1, 19), 'YYYY-MM-DD"T"HH24:MI:SS'), to_number(jt.c5 default null on conversion error), to_number(jt.c6 default null on conversion error), to_number(jt.c7 default null on conversion error), to_number(jt.c8 default null on conversion error), to_number(jt.c9 default null on conversion error), to_number(jt.c10 default null on conversion error)
from rsd_odata_raw r
    join RSD_SOGLASOVANIE p on p.legacy_ref = r.ref_key
    cross join json_table(r.doc, '$."Исполнители"[*]' columns (
            LINE_NO for ordinality,
            c0 varchar2(4000) path '$."ВариантУстановкиСрокаИсполнения"',
            c1 varchar2(4000) path '$."ЗадачаИсполнителя_Key"',
            c2 varchar2(4000) path '$."ПорядокСогласования"',
            c3 varchar2(4000) path '$."Пройден"',
            c4 varchar2(4000) path '$."СрокИсполнения"',
            c5 varchar2(4000) path '$."СрокИсполненияДни"',
            c6 varchar2(4000) path '$."СрокИсполненияМинуты"',
            c7 varchar2(4000) path '$."СрокИсполненияЧасы"',
            c8 varchar2(4000) path '$."ТрудозатратыПланИсполнителя"',
            c9 varchar2(4000) path '$."УдалитьСрокИсполнения"',
            c10 varchar2(4000) path '$."УдалитьСрокИсполненияЧас"'
    )) jt
where r.entity = 'BusinessProcess.Согласование';
commit;

-- ТЧ Предметы → RSD_SOGLASOVANIE_PREDMETY
delete from RSD_SOGLASOVANIE_PREDMETY where owner_id in (select id from RSD_SOGLASOVANIE);
insert into RSD_SOGLASOVANIE_PREDMETY (OWNER_ID, LINE_NO, ROLPREDMETA_ID, IMYAPREDMETA_ID, IMYAPREDMETAOSNOVANIE_ID)
select p.id, jt.LINE_NO, (select id from rsd_enums where enum_type = 'РолиПредметов' and value_key = jt.c0), cast(null as number), cast(null as number)
from rsd_odata_raw r
    join RSD_SOGLASOVANIE p on p.legacy_ref = r.ref_key
    cross join json_table(r.doc, '$."Предметы"[*]' columns (
            LINE_NO for ordinality,
            c0 varchar2(4000) path '$."РольПредмета"',
            c1 varchar2(4000) path '$."ИмяПредмета_Key"',
            c2 varchar2(4000) path '$."ИмяПредметаОснование_Key"'
    )) jt
where r.entity = 'BusinessProcess.Согласование';
commit;

-- ТЧ ПредметыЗадач → RSD_SOGLASOVANIE_PREDMETYZADACH
delete from RSD_SOGLASOVANIE_PREDMETYZADACH where owner_id in (select id from RSD_SOGLASOVANIE);
insert into RSD_SOGLASOVANIE_PREDMETYZADACH (OWNER_ID, LINE_NO, TOCHKAMARSHRUTA_ID, IMYAPREDMETA_ID, OBYAZATELNOEZAPOLNENIE, DOSTUPNOUDALENIE)
select p.id, jt.LINE_NO, cast(null as number), cast(null as number), case when lower(jt.c2) = 'true' then true else false end, case when lower(jt.c3) = 'true' then true else false end
from rsd_odata_raw r
    join RSD_SOGLASOVANIE p on p.legacy_ref = r.ref_key
    cross join json_table(r.doc, '$."ПредметыЗадач"[*]' columns (
            LINE_NO for ordinality,
            c0 varchar2(4000) path '$."ТочкаМаршрута_Key"',
            c1 varchar2(4000) path '$."ИмяПредмета_Key"',
            c2 varchar2(4000) path '$."ОбязательноеЗаполнение"',
            c3 varchar2(4000) path '$."ДоступноУдаление"'
    )) jt
where r.entity = 'BusinessProcess.Согласование';
commit;

-- ТЧ РезультатыОзнакомлений → RSD_SOGLASOVANIE_REZULTATYOZNAKOMLENIY
delete from RSD_SOGLASOVANIE_REZULTATYOZNAKOMLENIY where owner_id in (select id from RSD_SOGLASOVANIE);
insert into RSD_SOGLASOVANIE_REZULTATYOZNAKOMLENIY (OWNER_ID, LINE_NO, NOMERITERATSII, ZADACHAISPOLNITELYA_ID, OTPRAVLENONAPOVTORNOESOGLASOVANIE)
select p.id, jt.LINE_NO, to_number(jt.c0 default null on conversion error), cast(null as number), case when lower(jt.c2) = 'true' then true else false end
from rsd_odata_raw r
    join RSD_SOGLASOVANIE p on p.legacy_ref = r.ref_key
    cross join json_table(r.doc, '$."РезультатыОзнакомлений"[*]' columns (
            LINE_NO for ordinality,
            c0 varchar2(4000) path '$."НомерИтерации"',
            c1 varchar2(4000) path '$."ЗадачаИсполнителя_Key"',
            c2 varchar2(4000) path '$."ОтправленоНаПовторноеСогласование"'
    )) jt
where r.entity = 'BusinessProcess.Согласование';
commit;

-- ТЧ РезультатыСогласования → RSD_SOGLASOVANIE_REZULTATYSOGLASOVANIYA
delete from RSD_SOGLASOVANIE_REZULTATYSOGLASOVANIYA where owner_id in (select id from RSD_SOGLASOVANIE);
insert into RSD_SOGLASOVANIE_REZULTATYSOGLASOVANIYA (OWNER_ID, LINE_NO, NOMERITERATSII, ZADACHAISPOLNITELYA_ID, REZULTATSOGLASOVANIYA_ID)
select p.id, jt.LINE_NO, to_number(jt.c0 default null on conversion error), cast(null as number), (select id from rsd_enums where enum_type = 'РезультатыСогласования' and value_key = jt.c2)
from rsd_odata_raw r
    join RSD_SOGLASOVANIE p on p.legacy_ref = r.ref_key
    cross join json_table(r.doc, '$."РезультатыСогласования"[*]' columns (
            LINE_NO for ordinality,
            c0 varchar2(4000) path '$."НомерИтерации"',
            c1 varchar2(4000) path '$."ЗадачаИсполнителя_Key"',
            c2 varchar2(4000) path '$."РезультатСогласования"'
    )) jt
where r.entity = 'BusinessProcess.Согласование';
commit;

-- ТЧ УдалитьДополнительныеИсполнители → RSD_SOGLASOVANIE_UDALITDOPOLNITELNYEISPOLNITELI
delete from RSD_SOGLASOVANIE_UDALITDOPOLNITELNYEISPOLNITELI where owner_id in (select id from RSD_SOGLASOVANIE);
insert into RSD_SOGLASOVANIE_UDALITDOPOLNITELNYEISPOLNITELI (OWNER_ID, LINE_NO)
select p.id, jt.LINE_NO
from rsd_odata_raw r
    join RSD_SOGLASOVANIE p on p.legacy_ref = r.ref_key
    cross join json_table(r.doc, '$."УдалитьДополнительныеИсполнители"[*]' columns (
            LINE_NO for ordinality
    )) jt
where r.entity = 'BusinessProcess.Согласование';
commit;

-- BusinessProcess.КомплексныйПроцесс → RSD_KOMPLEKSNYYPROTSESS
merge into RSD_KOMPLEKSNYYPROTSESS t using (
    select
        json_value(doc, '$.Ref_Key') as LEGACY_REF,
        case when lower(json_value(doc, '$."DeletionMark"')) = 'true' then true else false end as IS_DELETED,
        to_timestamp(substr(json_value(doc, '$."Date"'), 1, 19), 'YYYY-MM-DD"T"HH24:MI:SS') as DOC_DATE,
        case when lower(json_value(doc, '$."RSD_ПисьмоСЧернымСпискомОтправлено"')) = 'true' then true else false end as RSD_PISMOSCHERNYMSPISKOMOTPRAVLENO,
        (select tgt.id from RSD_POLZOVATELI tgt where tgt.legacy_ref = nullif(json_value(doc, '$."Автор_Key"'), '00000000-0000-0000-0000-000000000000')) as AVTOR_ID,
        (select id from rsd_enums where enum_type = 'ВариантыВажностиЗадачи' and value_key = json_value(doc, '$."Важность"')) as VAZHNOST_ID,
        (select id from rsd_enums where enum_type = 'ВариантыМаршрутизацииЗадач' and value_key = json_value(doc, '$."ВариантМаршрутизации"')) as VARIANTMARSHRUTIZATSII_ID,
        cast(null as number) as GLAVNAYAZADACHA_ID,
        to_timestamp(substr(json_value(doc, '$."ДатаЗавершения"'), 1, 19), 'YYYY-MM-DD"T"HH24:MI:SS') as DATAZAVERSHENIYA,
        to_timestamp(substr(json_value(doc, '$."ДатаНачала"'), 1, 19), 'YYYY-MM-DD"T"HH24:MI:SS') as DATANACHALA,
        json_value(doc, '$."ИдентификаторСсылки"') as IDENTIFIKATORSSYLKI,
        json_value(doc, '$."Наименование"') as NAIMENOVANIE,
        json_value(doc, '$."Описание"') as OPISANIE,
        json_value(doc, '$."ПричинаПрерывания"') as PRICHINAPRERYVANIYA,
        cast(null as number) as PROEKT_ID,
        cast(null as number) as PROEKTNAYAZADACHA_ID,
        (select id from rsd_enums where enum_type = 'СостоянияБизнесПроцессов' and value_key = json_value(doc, '$."Состояние"')) as SOSTOYANIE_ID,
        to_timestamp(substr(json_value(doc, '$."СрокИсполненияПроцесса"'), 1, 19), 'YYYY-MM-DD"T"HH24:MI:SS') as SROKISPOLNENIYAPROTSESSA,
        cast(null as number) as SKHEMA_ID,
        to_number(json_value(doc, '$."ТрудозатратыПланКонтролера"') default null on conversion error) as TRUDOZATRATYPLANKONTROLERA,
        to_timestamp(substr(json_value(doc, '$."УдалитьСрокИсполнения"'), 1, 19), 'YYYY-MM-DD"T"HH24:MI:SS') as UDALITSROKISPOLNENIYA,
        json_value(doc, '$."УзелОбмена"') as UZELOBMENA,
        cast(null as number) as SHABLON_ID
    from rsd_odata_raw where entity = 'BusinessProcess.КомплексныйПроцесс'
) s on (t.legacy_ref = s.LEGACY_REF)
when matched then update set
        t.IS_DELETED = s.IS_DELETED,
        t.DOC_DATE = s.DOC_DATE,
        t.RSD_PISMOSCHERNYMSPISKOMOTPRAVLENO = s.RSD_PISMOSCHERNYMSPISKOMOTPRAVLENO,
        t.AVTOR_ID = s.AVTOR_ID,
        t.VAZHNOST_ID = s.VAZHNOST_ID,
        t.VARIANTMARSHRUTIZATSII_ID = s.VARIANTMARSHRUTIZATSII_ID,
        t.GLAVNAYAZADACHA_ID = s.GLAVNAYAZADACHA_ID,
        t.DATAZAVERSHENIYA = s.DATAZAVERSHENIYA,
        t.DATANACHALA = s.DATANACHALA,
        t.IDENTIFIKATORSSYLKI = s.IDENTIFIKATORSSYLKI,
        t.NAIMENOVANIE = s.NAIMENOVANIE,
        t.OPISANIE = s.OPISANIE,
        t.PRICHINAPRERYVANIYA = s.PRICHINAPRERYVANIYA,
        t.PROEKT_ID = s.PROEKT_ID,
        t.PROEKTNAYAZADACHA_ID = s.PROEKTNAYAZADACHA_ID,
        t.SOSTOYANIE_ID = s.SOSTOYANIE_ID,
        t.SROKISPOLNENIYAPROTSESSA = s.SROKISPOLNENIYAPROTSESSA,
        t.SKHEMA_ID = s.SKHEMA_ID,
        t.TRUDOZATRATYPLANKONTROLERA = s.TRUDOZATRATYPLANKONTROLERA,
        t.UDALITSROKISPOLNENIYA = s.UDALITSROKISPOLNENIYA,
        t.UZELOBMENA = s.UZELOBMENA,
        t.SHABLON_ID = s.SHABLON_ID
when not matched then insert (LEGACY_REF, IS_DELETED, DOC_DATE, RSD_PISMOSCHERNYMSPISKOMOTPRAVLENO, AVTOR_ID, VAZHNOST_ID, VARIANTMARSHRUTIZATSII_ID, GLAVNAYAZADACHA_ID, DATAZAVERSHENIYA, DATANACHALA, IDENTIFIKATORSSYLKI, NAIMENOVANIE, OPISANIE, PRICHINAPRERYVANIYA, PROEKT_ID, PROEKTNAYAZADACHA_ID, SOSTOYANIE_ID, SROKISPOLNENIYAPROTSESSA, SKHEMA_ID, TRUDOZATRATYPLANKONTROLERA, UDALITSROKISPOLNENIYA, UZELOBMENA, SHABLON_ID)
    values (s.LEGACY_REF, s.IS_DELETED, s.DOC_DATE, s.RSD_PISMOSCHERNYMSPISKOMOTPRAVLENO, s.AVTOR_ID, s.VAZHNOST_ID, s.VARIANTMARSHRUTIZATSII_ID, s.GLAVNAYAZADACHA_ID, s.DATAZAVERSHENIYA, s.DATANACHALA, s.IDENTIFIKATORSSYLKI, s.NAIMENOVANIE, s.OPISANIE, s.PRICHINAPRERYVANIYA, s.PROEKT_ID, s.PROEKTNAYAZADACHA_ID, s.SOSTOYANIE_ID, s.SROKISPOLNENIYAPROTSESSA, s.SKHEMA_ID, s.TRUDOZATRATYPLANKONTROLERA, s.UDALITSROKISPOLNENIYA, s.UZELOBMENA, s.SHABLON_ID);
commit;

-- ТЧ ДополнительныеРеквизиты → RSD_KOMPLEKSNYYPROTSESS_DOPOLNITELNYEREKVIZITY
delete from RSD_KOMPLEKSNYYPROTSESS_DOPOLNITELNYEREKVIZITY where owner_id in (select id from RSD_KOMPLEKSNYYPROTSESS);
insert into RSD_KOMPLEKSNYYPROTSESS_DOPOLNITELNYEREKVIZITY (OWNER_ID, LINE_NO, SVOYSTVO_ID, TEKSTOVAYASTROKA)
select p.id, jt.LINE_NO, cast(null as number), jt.c1
from rsd_odata_raw r
    join RSD_KOMPLEKSNYYPROTSESS p on p.legacy_ref = r.ref_key
    cross join json_table(r.doc, '$."ДополнительныеРеквизиты"[*]' columns (
            LINE_NO for ordinality,
            c0 varchar2(4000) path '$."Свойство_Key"',
            c1 varchar2(4000) path '$."ТекстоваяСтрока"'
    )) jt
where r.entity = 'BusinessProcess.КомплексныйПроцесс';
commit;

-- ТЧ Предметы → RSD_KOMPLEKSNYYPROTSESS_PREDMETY
delete from RSD_KOMPLEKSNYYPROTSESS_PREDMETY where owner_id in (select id from RSD_KOMPLEKSNYYPROTSESS);
insert into RSD_KOMPLEKSNYYPROTSESS_PREDMETY (OWNER_ID, LINE_NO, ROLPREDMETA_ID, IMYAPREDMETA_ID, IMYAPREDMETAOSNOVANIE_ID)
select p.id, jt.LINE_NO, (select id from rsd_enums where enum_type = 'РолиПредметов' and value_key = jt.c0), cast(null as number), cast(null as number)
from rsd_odata_raw r
    join RSD_KOMPLEKSNYYPROTSESS p on p.legacy_ref = r.ref_key
    cross join json_table(r.doc, '$."Предметы"[*]' columns (
            LINE_NO for ordinality,
            c0 varchar2(4000) path '$."РольПредмета"',
            c1 varchar2(4000) path '$."ИмяПредмета_Key"',
            c2 varchar2(4000) path '$."ИмяПредметаОснование_Key"'
    )) jt
where r.entity = 'BusinessProcess.КомплексныйПроцесс';
commit;

-- ТЧ ПредметыЗадач → RSD_KOMPLEKSNYYPROTSESS_PREDMETYZADACH
delete from RSD_KOMPLEKSNYYPROTSESS_PREDMETYZADACH where owner_id in (select id from RSD_KOMPLEKSNYYPROTSESS);
insert into RSD_KOMPLEKSNYYPROTSESS_PREDMETYZADACH (OWNER_ID, LINE_NO, IDENTIFIKATORETAPA, IMYAPREDMETA_ID, DOSTUPNOUDALENIE, OBYAZATELNOEZAPOLNENIE)
select p.id, jt.LINE_NO, jt.c0, cast(null as number), case when lower(jt.c2) = 'true' then true else false end, case when lower(jt.c3) = 'true' then true else false end
from rsd_odata_raw r
    join RSD_KOMPLEKSNYYPROTSESS p on p.legacy_ref = r.ref_key
    cross join json_table(r.doc, '$."ПредметыЗадач"[*]' columns (
            LINE_NO for ordinality,
            c0 varchar2(4000) path '$."ИдентификаторЭтапа"',
            c1 varchar2(4000) path '$."ИмяПредмета_Key"',
            c2 varchar2(4000) path '$."ДоступноУдаление"',
            c3 varchar2(4000) path '$."ОбязательноеЗаполнение"'
    )) jt
where r.entity = 'BusinessProcess.КомплексныйПроцесс';
commit;

-- ТЧ ПредшественникиЭтапов → RSD_KOMPLEKSNYYPROTSESS_PREDSHESTVENNIKIETAPOV
delete from RSD_KOMPLEKSNYYPROTSESS_PREDSHESTVENNIKIETAPOV where owner_id in (select id from RSD_KOMPLEKSNYYPROTSESS);
insert into RSD_KOMPLEKSNYYPROTSESS_PREDSHESTVENNIKIETAPOV (OWNER_ID, LINE_NO, IDENTIFIKATORPOSLEDOVATELYA, IDENTIFIKATORPREDSHESTVENNIKA, USLOVIEPEREKHODA_ID, USLOVNYYPEREKHODBYLVYPOLNEN, USLOVIERASSMOTRENIYA_ID, IMYAPREDMETAUSLOVIYA_ID)
select p.id, jt.LINE_NO, jt.c0, jt.c1, (select tgt.id from RSD_USLOVIYAMARSHRUTIZATSII tgt where tgt.legacy_ref = nullif(jt.c2, '00000000-0000-0000-0000-000000000000')), case when lower(jt.c3) = 'true' then true else false end, (select id from rsd_enums where enum_type = 'УсловияРассмотренияПредшественниковЭтапа' and value_key = jt.c4), cast(null as number)
from rsd_odata_raw r
    join RSD_KOMPLEKSNYYPROTSESS p on p.legacy_ref = r.ref_key
    cross join json_table(r.doc, '$."ПредшественникиЭтапов"[*]' columns (
            LINE_NO for ordinality,
            c0 varchar2(4000) path '$."ИдентификаторПоследователя"',
            c1 varchar2(4000) path '$."ИдентификаторПредшественника"',
            c2 varchar2(4000) path '$."УсловиеПерехода_Key"',
            c3 varchar2(4000) path '$."УсловныйПереходБылВыполнен"',
            c4 varchar2(4000) path '$."УсловиеРассмотрения"',
            c5 varchar2(4000) path '$."ИмяПредметаУсловия_Key"'
    )) jt
where r.entity = 'BusinessProcess.КомплексныйПроцесс';
commit;

-- ТЧ Этапы → RSD_KOMPLEKSNYYPROTSESS_ETAPY
delete from RSD_KOMPLEKSNYYPROTSESS_ETAPY where owner_id in (select id from RSD_KOMPLEKSNYYPROTSESS);
insert into RSD_KOMPLEKSNYYPROTSESS_ETAPY (OWNER_ID, LINE_NO, BEZUSLOVNYYPEREKHODKSLEDUYUSHCHEMUBYLVYPOLNEN, ZADACHAVYPOLNENA, IDENTIFIKATORETAPA, ISPOLNITELIETAPASTROKOY, PORYADOKSORTIROVKI, PREDSHESTVENNIKIVARIANTISPOLZOVANIYA, PREDSHESTVENNIKIETAPASTROKOY)
select p.id, jt.LINE_NO, case when lower(jt.c0) = 'true' then true else false end, case when lower(jt.c1) = 'true' then true else false end, jt.c2, jt.c3, to_number(jt.c4 default null on conversion error), jt.c5, jt.c6
from rsd_odata_raw r
    join RSD_KOMPLEKSNYYPROTSESS p on p.legacy_ref = r.ref_key
    cross join json_table(r.doc, '$."Этапы"[*]' columns (
            LINE_NO for ordinality,
            c0 varchar2(4000) path '$."БезусловныйПереходКСледующемуБылВыполнен"',
            c1 varchar2(4000) path '$."ЗадачаВыполнена"',
            c2 varchar2(4000) path '$."ИдентификаторЭтапа"',
            c3 varchar2(4000) path '$."ИсполнителиЭтапаСтрокой"',
            c4 varchar2(4000) path '$."ПорядокСортировки"',
            c5 varchar2(4000) path '$."ПредшественникиВариантИспользования"',
            c6 varchar2(4000) path '$."ПредшественникиЭтапаСтрокой"'
    )) jt
where r.entity = 'BusinessProcess.КомплексныйПроцесс';
commit;

-- BusinessProcess.Ознакомление → RSD_OZNAKOMLENIE
merge into RSD_OZNAKOMLENIE t using (
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
        json_value(doc, '$."Описание"') as OPISANIE,
        json_value(doc, '$."ПричинаПрерывания"') as PRICHINAPRERYVANIYA,
        cast(null as number) as PROEKT_ID,
        cast(null as number) as PROEKTNAYAZADACHA_ID,
        (select id from rsd_enums where enum_type = 'СостоянияБизнесПроцессов' and value_key = json_value(doc, '$."Состояние"')) as SOSTOYANIE_ID,
        to_timestamp(substr(json_value(doc, '$."СрокИсполненияПроцесса"'), 1, 19), 'YYYY-MM-DD"T"HH24:MI:SS') as SROKISPOLNENIYAPROTSESSA,
        to_number(json_value(doc, '$."ТрудозатратыПланИсполнителя"') default null on conversion error) as TRUDOZATRATYPLANISPOLNITELYA,
        to_timestamp(substr(json_value(doc, '$."УдалитьСрокИсполнения"'), 1, 19), 'YYYY-MM-DD"T"HH24:MI:SS') as UDALITSROKISPOLNENIYA,
        json_value(doc, '$."УзелОбмена"') as UZELOBMENA,
        cast(null as number) as SHABLON_ID,
        json_value(doc, '$."ЭтапОбработкиПредмета"') as ETAPOBRABOTKIPREDMETA
    from rsd_odata_raw where entity = 'BusinessProcess.Ознакомление'
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
        t.OPISANIE = s.OPISANIE,
        t.PRICHINAPRERYVANIYA = s.PRICHINAPRERYVANIYA,
        t.PROEKT_ID = s.PROEKT_ID,
        t.PROEKTNAYAZADACHA_ID = s.PROEKTNAYAZADACHA_ID,
        t.SOSTOYANIE_ID = s.SOSTOYANIE_ID,
        t.SROKISPOLNENIYAPROTSESSA = s.SROKISPOLNENIYAPROTSESSA,
        t.TRUDOZATRATYPLANISPOLNITELYA = s.TRUDOZATRATYPLANISPOLNITELYA,
        t.UDALITSROKISPOLNENIYA = s.UDALITSROKISPOLNENIYA,
        t.UZELOBMENA = s.UZELOBMENA,
        t.SHABLON_ID = s.SHABLON_ID,
        t.ETAPOBRABOTKIPREDMETA = s.ETAPOBRABOTKIPREDMETA
when not matched then insert (LEGACY_REF, IS_DELETED, DOC_DATE, AVTOR_ID, VAZHNOST_ID, GLAVNAYAZADACHA_ID, DATAZAVERSHENIYA, DATANACHALA, NAIMENOVANIE, OPISANIE, PRICHINAPRERYVANIYA, PROEKT_ID, PROEKTNAYAZADACHA_ID, SOSTOYANIE_ID, SROKISPOLNENIYAPROTSESSA, TRUDOZATRATYPLANISPOLNITELYA, UDALITSROKISPOLNENIYA, UZELOBMENA, SHABLON_ID, ETAPOBRABOTKIPREDMETA)
    values (s.LEGACY_REF, s.IS_DELETED, s.DOC_DATE, s.AVTOR_ID, s.VAZHNOST_ID, s.GLAVNAYAZADACHA_ID, s.DATAZAVERSHENIYA, s.DATANACHALA, s.NAIMENOVANIE, s.OPISANIE, s.PRICHINAPRERYVANIYA, s.PROEKT_ID, s.PROEKTNAYAZADACHA_ID, s.SOSTOYANIE_ID, s.SROKISPOLNENIYAPROTSESSA, s.TRUDOZATRATYPLANISPOLNITELYA, s.UDALITSROKISPOLNENIYA, s.UZELOBMENA, s.SHABLON_ID, s.ETAPOBRABOTKIPREDMETA);
commit;

-- ТЧ ДополнительныеРеквизиты → RSD_OZNAKOMLENIE_DOPOLNITELNYEREKVIZITY
delete from RSD_OZNAKOMLENIE_DOPOLNITELNYEREKVIZITY where owner_id in (select id from RSD_OZNAKOMLENIE);
insert into RSD_OZNAKOMLENIE_DOPOLNITELNYEREKVIZITY (OWNER_ID, LINE_NO, SVOYSTVO_ID, TEKSTOVAYASTROKA)
select p.id, jt.LINE_NO, cast(null as number), jt.c1
from rsd_odata_raw r
    join RSD_OZNAKOMLENIE p on p.legacy_ref = r.ref_key
    cross join json_table(r.doc, '$."ДополнительныеРеквизиты"[*]' columns (
            LINE_NO for ordinality,
            c0 varchar2(4000) path '$."Свойство_Key"',
            c1 varchar2(4000) path '$."ТекстоваяСтрока"'
    )) jt
where r.entity = 'BusinessProcess.Ознакомление';
commit;

-- ТЧ Исполнители → RSD_OZNAKOMLENIE_ISPOLNITELI
delete from RSD_OZNAKOMLENIE_ISPOLNITELI where owner_id in (select id from RSD_OZNAKOMLENIE);
insert into RSD_OZNAKOMLENIE_ISPOLNITELI (OWNER_ID, LINE_NO, VARIANTUSTANOVKISROKAISPOLNENIYA_ID, ZADACHAISPOLNITELYA_ID, PROYDEN, SROKISPOLNENIYA, SROKISPOLNENIYADNI, SROKISPOLNENIYAMINUTY, SROKISPOLNENIYACHASY)
select p.id, jt.LINE_NO, (select id from rsd_enums where enum_type = 'ВариантыУстановкиСрокаИсполнения' and value_key = jt.c0), cast(null as number), case when lower(jt.c2) = 'true' then true else false end, to_timestamp(substr(jt.c3, 1, 19), 'YYYY-MM-DD"T"HH24:MI:SS'), to_number(jt.c4 default null on conversion error), to_number(jt.c5 default null on conversion error), to_number(jt.c6 default null on conversion error)
from rsd_odata_raw r
    join RSD_OZNAKOMLENIE p on p.legacy_ref = r.ref_key
    cross join json_table(r.doc, '$."Исполнители"[*]' columns (
            LINE_NO for ordinality,
            c0 varchar2(4000) path '$."ВариантУстановкиСрокаИсполнения"',
            c1 varchar2(4000) path '$."ЗадачаИсполнителя_Key"',
            c2 varchar2(4000) path '$."Пройден"',
            c3 varchar2(4000) path '$."СрокИсполнения"',
            c4 varchar2(4000) path '$."СрокИсполненияДни"',
            c5 varchar2(4000) path '$."СрокИсполненияМинуты"',
            c6 varchar2(4000) path '$."СрокИсполненияЧасы"'
    )) jt
where r.entity = 'BusinessProcess.Ознакомление';
commit;

-- ТЧ Предметы → RSD_OZNAKOMLENIE_PREDMETY
delete from RSD_OZNAKOMLENIE_PREDMETY where owner_id in (select id from RSD_OZNAKOMLENIE);
insert into RSD_OZNAKOMLENIE_PREDMETY (OWNER_ID, LINE_NO, ROLPREDMETA_ID, IMYAPREDMETA_ID, IMYAPREDMETAOSNOVANIE_ID)
select p.id, jt.LINE_NO, (select id from rsd_enums where enum_type = 'РолиПредметов' and value_key = jt.c0), cast(null as number), cast(null as number)
from rsd_odata_raw r
    join RSD_OZNAKOMLENIE p on p.legacy_ref = r.ref_key
    cross join json_table(r.doc, '$."Предметы"[*]' columns (
            LINE_NO for ordinality,
            c0 varchar2(4000) path '$."РольПредмета"',
            c1 varchar2(4000) path '$."ИмяПредмета_Key"',
            c2 varchar2(4000) path '$."ИмяПредметаОснование_Key"'
    )) jt
where r.entity = 'BusinessProcess.Ознакомление';
commit;

-- ТЧ ПредметыЗадач → RSD_OZNAKOMLENIE_PREDMETYZADACH
delete from RSD_OZNAKOMLENIE_PREDMETYZADACH where owner_id in (select id from RSD_OZNAKOMLENIE);
insert into RSD_OZNAKOMLENIE_PREDMETYZADACH (OWNER_ID, LINE_NO, TOCHKAMARSHRUTA_ID, IMYAPREDMETA_ID, OBYAZATELNOEZAPOLNENIE, DOSTUPNOUDALENIE)
select p.id, jt.LINE_NO, cast(null as number), cast(null as number), case when lower(jt.c2) = 'true' then true else false end, case when lower(jt.c3) = 'true' then true else false end
from rsd_odata_raw r
    join RSD_OZNAKOMLENIE p on p.legacy_ref = r.ref_key
    cross join json_table(r.doc, '$."ПредметыЗадач"[*]' columns (
            LINE_NO for ordinality,
            c0 varchar2(4000) path '$."ТочкаМаршрута_Key"',
            c1 varchar2(4000) path '$."ИмяПредмета_Key"',
            c2 varchar2(4000) path '$."ОбязательноеЗаполнение"',
            c3 varchar2(4000) path '$."ДоступноУдаление"'
    )) jt
where r.entity = 'BusinessProcess.Ознакомление';
commit;

-- ТЧ УдалитьДополнительныеИсполнители → RSD_OZNAKOMLENIE_UDALITDOPOLNITELNYEISPOLNITELI
delete from RSD_OZNAKOMLENIE_UDALITDOPOLNITELNYEISPOLNITELI where owner_id in (select id from RSD_OZNAKOMLENIE);
insert into RSD_OZNAKOMLENIE_UDALITDOPOLNITELNYEISPOLNITELI (OWNER_ID, LINE_NO)
select p.id, jt.LINE_NO
from rsd_odata_raw r
    join RSD_OZNAKOMLENIE p on p.legacy_ref = r.ref_key
    cross join json_table(r.doc, '$."УдалитьДополнительныеИсполнители"[*]' columns (
            LINE_NO for ordinality
    )) jt
where r.entity = 'BusinessProcess.Ознакомление';
commit;

-- BusinessProcess.Исполнение → RSD_ISPOLNENIE
merge into RSD_ISPOLNENIE t using (
    select
        json_value(doc, '$.Ref_Key') as LEGACY_REF,
        case when lower(json_value(doc, '$."DeletionMark"')) = 'true' then true else false end as IS_DELETED,
        to_timestamp(substr(json_value(doc, '$."Date"'), 1, 19), 'YYYY-MM-DD"T"HH24:MI:SS') as DOC_DATE,
        (select tgt.id from RSD_POLZOVATELI tgt where tgt.legacy_ref = nullif(json_value(doc, '$."Автор_Key"'), '00000000-0000-0000-0000-000000000000')) as AVTOR_ID,
        (select id from rsd_enums where enum_type = 'ВариантыВажностиЗадачи' and value_key = json_value(doc, '$."Важность"')) as VAZHNOST_ID,
        (select id from rsd_enums where enum_type = 'ВариантыМаршрутизацииЗадач' and value_key = json_value(doc, '$."ВариантИсполнения"')) as VARIANTISPOLNENIYA_ID,
        (select id from rsd_enums where enum_type = 'ВариантыУстановкиСрокаИсполнения' and value_key = json_value(doc, '$."ВариантУстановкиСрокаОбработкиРезультатов"')) as VARIANTUSTANOVKISROKAOBRABOTKIREZULTATOV_ID,
        cast(null as number) as GLAVNAYAZADACHA_ID,
        to_timestamp(substr(json_value(doc, '$."ДатаЗавершения"'), 1, 19), 'YYYY-MM-DD"T"HH24:MI:SS') as DATAZAVERSHENIYA,
        to_timestamp(substr(json_value(doc, '$."ДатаНачала"'), 1, 19), 'YYYY-MM-DD"T"HH24:MI:SS') as DATANACHALA,
        to_number(json_value(doc, '$."КоличествоИтераций"') default null on conversion error) as KOLICHESTVOITERATSIY,
        json_value(doc, '$."Наименование"') as NAIMENOVANIE,
        to_number(json_value(doc, '$."НомерИтерации"') default null on conversion error) as NOMERITERATSII,
        json_value(doc, '$."Описание"') as OPISANIE,
        json_value(doc, '$."ПричинаПрерывания"') as PRICHINAPRERYVANIYA,
        cast(null as number) as PROEKT_ID,
        cast(null as number) as PROEKTNAYAZADACHA_ID,
        (select id from rsd_enums where enum_type = 'СостоянияБизнесПроцессов' and value_key = json_value(doc, '$."Состояние"')) as SOSTOYANIE_ID,
        to_timestamp(substr(json_value(doc, '$."СрокИсполненияПроцесса"'), 1, 19), 'YYYY-MM-DD"T"HH24:MI:SS') as SROKISPOLNENIYAPROTSESSA,
        to_timestamp(substr(json_value(doc, '$."СрокОбработкиРезультатов"'), 1, 19), 'YYYY-MM-DD"T"HH24:MI:SS') as SROKOBRABOTKIREZULTATOV,
        to_number(json_value(doc, '$."СрокОбработкиРезультатовДни"') default null on conversion error) as SROKOBRABOTKIREZULTATOVDNI,
        to_number(json_value(doc, '$."СрокОбработкиРезультатовМинуты"') default null on conversion error) as SROKOBRABOTKIREZULTATOVMINUTY,
        to_number(json_value(doc, '$."СрокОбработкиРезультатовЧасы"') default null on conversion error) as SROKOBRABOTKIREZULTATOVCHASY,
        to_number(json_value(doc, '$."ТрудозатратыПланКонтролера"') default null on conversion error) as TRUDOZATRATYPLANKONTROLERA,
        to_number(json_value(doc, '$."ТрудозатратыПланПроверяющего"') default null on conversion error) as TRUDOZATRATYPLANPROVERYAYUSHCHEGO,
        to_timestamp(substr(json_value(doc, '$."УдалитьСрокИсполнения"'), 1, 19), 'YYYY-MM-DD"T"HH24:MI:SS') as UDALITSROKISPOLNENIYA,
        json_value(doc, '$."УзелОбмена"') as UZELOBMENA,
        cast(null as number) as SHABLON_ID,
        json_value(doc, '$."ЭтапОбработкиПредмета"') as ETAPOBRABOTKIPREDMETA
    from rsd_odata_raw where entity = 'BusinessProcess.Исполнение'
) s on (t.legacy_ref = s.LEGACY_REF)
when matched then update set
        t.IS_DELETED = s.IS_DELETED,
        t.DOC_DATE = s.DOC_DATE,
        t.AVTOR_ID = s.AVTOR_ID,
        t.VAZHNOST_ID = s.VAZHNOST_ID,
        t.VARIANTISPOLNENIYA_ID = s.VARIANTISPOLNENIYA_ID,
        t.VARIANTUSTANOVKISROKAOBRABOTKIREZULTATOV_ID = s.VARIANTUSTANOVKISROKAOBRABOTKIREZULTATOV_ID,
        t.GLAVNAYAZADACHA_ID = s.GLAVNAYAZADACHA_ID,
        t.DATAZAVERSHENIYA = s.DATAZAVERSHENIYA,
        t.DATANACHALA = s.DATANACHALA,
        t.KOLICHESTVOITERATSIY = s.KOLICHESTVOITERATSIY,
        t.NAIMENOVANIE = s.NAIMENOVANIE,
        t.NOMERITERATSII = s.NOMERITERATSII,
        t.OPISANIE = s.OPISANIE,
        t.PRICHINAPRERYVANIYA = s.PRICHINAPRERYVANIYA,
        t.PROEKT_ID = s.PROEKT_ID,
        t.PROEKTNAYAZADACHA_ID = s.PROEKTNAYAZADACHA_ID,
        t.SOSTOYANIE_ID = s.SOSTOYANIE_ID,
        t.SROKISPOLNENIYAPROTSESSA = s.SROKISPOLNENIYAPROTSESSA,
        t.SROKOBRABOTKIREZULTATOV = s.SROKOBRABOTKIREZULTATOV,
        t.SROKOBRABOTKIREZULTATOVDNI = s.SROKOBRABOTKIREZULTATOVDNI,
        t.SROKOBRABOTKIREZULTATOVMINUTY = s.SROKOBRABOTKIREZULTATOVMINUTY,
        t.SROKOBRABOTKIREZULTATOVCHASY = s.SROKOBRABOTKIREZULTATOVCHASY,
        t.TRUDOZATRATYPLANKONTROLERA = s.TRUDOZATRATYPLANKONTROLERA,
        t.TRUDOZATRATYPLANPROVERYAYUSHCHEGO = s.TRUDOZATRATYPLANPROVERYAYUSHCHEGO,
        t.UDALITSROKISPOLNENIYA = s.UDALITSROKISPOLNENIYA,
        t.UZELOBMENA = s.UZELOBMENA,
        t.SHABLON_ID = s.SHABLON_ID,
        t.ETAPOBRABOTKIPREDMETA = s.ETAPOBRABOTKIPREDMETA
when not matched then insert (LEGACY_REF, IS_DELETED, DOC_DATE, AVTOR_ID, VAZHNOST_ID, VARIANTISPOLNENIYA_ID, VARIANTUSTANOVKISROKAOBRABOTKIREZULTATOV_ID, GLAVNAYAZADACHA_ID, DATAZAVERSHENIYA, DATANACHALA, KOLICHESTVOITERATSIY, NAIMENOVANIE, NOMERITERATSII, OPISANIE, PRICHINAPRERYVANIYA, PROEKT_ID, PROEKTNAYAZADACHA_ID, SOSTOYANIE_ID, SROKISPOLNENIYAPROTSESSA, SROKOBRABOTKIREZULTATOV, SROKOBRABOTKIREZULTATOVDNI, SROKOBRABOTKIREZULTATOVMINUTY, SROKOBRABOTKIREZULTATOVCHASY, TRUDOZATRATYPLANKONTROLERA, TRUDOZATRATYPLANPROVERYAYUSHCHEGO, UDALITSROKISPOLNENIYA, UZELOBMENA, SHABLON_ID, ETAPOBRABOTKIPREDMETA)
    values (s.LEGACY_REF, s.IS_DELETED, s.DOC_DATE, s.AVTOR_ID, s.VAZHNOST_ID, s.VARIANTISPOLNENIYA_ID, s.VARIANTUSTANOVKISROKAOBRABOTKIREZULTATOV_ID, s.GLAVNAYAZADACHA_ID, s.DATAZAVERSHENIYA, s.DATANACHALA, s.KOLICHESTVOITERATSIY, s.NAIMENOVANIE, s.NOMERITERATSII, s.OPISANIE, s.PRICHINAPRERYVANIYA, s.PROEKT_ID, s.PROEKTNAYAZADACHA_ID, s.SOSTOYANIE_ID, s.SROKISPOLNENIYAPROTSESSA, s.SROKOBRABOTKIREZULTATOV, s.SROKOBRABOTKIREZULTATOVDNI, s.SROKOBRABOTKIREZULTATOVMINUTY, s.SROKOBRABOTKIREZULTATOVCHASY, s.TRUDOZATRATYPLANKONTROLERA, s.TRUDOZATRATYPLANPROVERYAYUSHCHEGO, s.UDALITSROKISPOLNENIYA, s.UZELOBMENA, s.SHABLON_ID, s.ETAPOBRABOTKIPREDMETA);
commit;

-- ТЧ ДополнительныеРеквизиты → RSD_ISPOLNENIE_DOPOLNITELNYEREKVIZITY
delete from RSD_ISPOLNENIE_DOPOLNITELNYEREKVIZITY where owner_id in (select id from RSD_ISPOLNENIE);
insert into RSD_ISPOLNENIE_DOPOLNITELNYEREKVIZITY (OWNER_ID, LINE_NO, SVOYSTVO_ID, TEKSTOVAYASTROKA)
select p.id, jt.LINE_NO, cast(null as number), jt.c1
from rsd_odata_raw r
    join RSD_ISPOLNENIE p on p.legacy_ref = r.ref_key
    cross join json_table(r.doc, '$."ДополнительныеРеквизиты"[*]' columns (
            LINE_NO for ordinality,
            c0 varchar2(4000) path '$."Свойство_Key"',
            c1 varchar2(4000) path '$."ТекстоваяСтрока"'
    )) jt
where r.entity = 'BusinessProcess.Исполнение';
commit;

-- ТЧ Исполнители → RSD_ISPOLNENIE_ISPOLNITELI
delete from RSD_ISPOLNENIE_ISPOLNITELI where owner_id in (select id from RSD_ISPOLNENIE);
insert into RSD_ISPOLNENIE_ISPOLNITELI (OWNER_ID, LINE_NO, VARIANTUSTANOVKISROKAISPOLNENIYA_ID, ZADACHAISPOLNITELYA_ID, IDENTIFIKATORISPOLNITELYA, NAIMENOVANIEZADACHI, OPISANIE, OTVETSTVENNYY, PORYADOKISPOLNENIYA_ID, PROYDEN, SROKISPOLNENIYA, SROKISPOLNENIYADNI, SROKISPOLNENIYAMINUTY, SROKISPOLNENIYACHASY, TRUDOZATRATYPLANISPOLNITELYA, UDALITDLITELNOSTISPOLNENIYADNI, UDALITDLITELNOSTISPOLNENIYACHASY, UDALITSROKISPOLNENIYA)
select p.id, jt.LINE_NO, (select id from rsd_enums where enum_type = 'ВариантыУстановкиСрокаИсполнения' and value_key = jt.c0), cast(null as number), jt.c2, jt.c3, jt.c4, case when lower(jt.c5) = 'true' then true else false end, (select id from rsd_enums where enum_type = 'ПорядокВыполненияЗадач' and value_key = jt.c6), case when lower(jt.c7) = 'true' then true else false end, to_timestamp(substr(jt.c8, 1, 19), 'YYYY-MM-DD"T"HH24:MI:SS'), to_number(jt.c9 default null on conversion error), to_number(jt.c10 default null on conversion error), to_number(jt.c11 default null on conversion error), to_number(jt.c12 default null on conversion error), to_number(jt.c13 default null on conversion error), to_number(jt.c14 default null on conversion error), to_timestamp(substr(jt.c15, 1, 19), 'YYYY-MM-DD"T"HH24:MI:SS')
from rsd_odata_raw r
    join RSD_ISPOLNENIE p on p.legacy_ref = r.ref_key
    cross join json_table(r.doc, '$."Исполнители"[*]' columns (
            LINE_NO for ordinality,
            c0 varchar2(4000) path '$."ВариантУстановкиСрокаИсполнения"',
            c1 varchar2(4000) path '$."ЗадачаИсполнителя_Key"',
            c2 varchar2(4000) path '$."ИдентификаторИсполнителя"',
            c3 varchar2(4000) path '$."НаименованиеЗадачи"',
            c4 varchar2(4000) path '$."Описание"',
            c5 varchar2(4000) path '$."Ответственный"',
            c6 varchar2(4000) path '$."ПорядокИсполнения"',
            c7 varchar2(4000) path '$."Пройден"',
            c8 varchar2(4000) path '$."СрокИсполнения"',
            c9 varchar2(4000) path '$."СрокИсполненияДни"',
            c10 varchar2(4000) path '$."СрокИсполненияМинуты"',
            c11 varchar2(4000) path '$."СрокИсполненияЧасы"',
            c12 varchar2(4000) path '$."ТрудозатратыПланИсполнителя"',
            c13 varchar2(4000) path '$."УдалитьДлительностьИсполненияДни"',
            c14 varchar2(4000) path '$."УдалитьДлительностьИсполненияЧасы"',
            c15 varchar2(4000) path '$."УдалитьСрокИсполнения"'
    )) jt
where r.entity = 'BusinessProcess.Исполнение';
commit;

-- ТЧ Предметы → RSD_ISPOLNENIE_PREDMETY
delete from RSD_ISPOLNENIE_PREDMETY where owner_id in (select id from RSD_ISPOLNENIE);
insert into RSD_ISPOLNENIE_PREDMETY (OWNER_ID, LINE_NO, ROLPREDMETA_ID, IMYAPREDMETA_ID, IMYAPREDMETAOSNOVANIE_ID)
select p.id, jt.LINE_NO, (select id from rsd_enums where enum_type = 'РолиПредметов' and value_key = jt.c0), cast(null as number), cast(null as number)
from rsd_odata_raw r
    join RSD_ISPOLNENIE p on p.legacy_ref = r.ref_key
    cross join json_table(r.doc, '$."Предметы"[*]' columns (
            LINE_NO for ordinality,
            c0 varchar2(4000) path '$."РольПредмета"',
            c1 varchar2(4000) path '$."ИмяПредмета_Key"',
            c2 varchar2(4000) path '$."ИмяПредметаОснование_Key"'
    )) jt
where r.entity = 'BusinessProcess.Исполнение';
commit;

-- ТЧ ПредметыЗадач → RSD_ISPOLNENIE_PREDMETYZADACH
delete from RSD_ISPOLNENIE_PREDMETYZADACH where owner_id in (select id from RSD_ISPOLNENIE);
insert into RSD_ISPOLNENIE_PREDMETYZADACH (OWNER_ID, LINE_NO, TOCHKAMARSHRUTA_ID, IMYAPREDMETA_ID, OBYAZATELNOEZAPOLNENIE, DOSTUPNOUDALENIE)
select p.id, jt.LINE_NO, cast(null as number), cast(null as number), case when lower(jt.c2) = 'true' then true else false end, case when lower(jt.c3) = 'true' then true else false end
from rsd_odata_raw r
    join RSD_ISPOLNENIE p on p.legacy_ref = r.ref_key
    cross join json_table(r.doc, '$."ПредметыЗадач"[*]' columns (
            LINE_NO for ordinality,
            c0 varchar2(4000) path '$."ТочкаМаршрута_Key"',
            c1 varchar2(4000) path '$."ИмяПредмета_Key"',
            c2 varchar2(4000) path '$."ОбязательноеЗаполнение"',
            c3 varchar2(4000) path '$."ДоступноУдаление"'
    )) jt
where r.entity = 'BusinessProcess.Исполнение';
commit;

-- ТЧ РезультатыИсполнения → RSD_ISPOLNENIE_REZULTATYISPOLNENIYA
delete from RSD_ISPOLNENIE_REZULTATYISPOLNENIYA where owner_id in (select id from RSD_ISPOLNENIE);
insert into RSD_ISPOLNENIE_REZULTATYISPOLNENIYA (OWNER_ID, LINE_NO, NOMERITERATSII, ZADACHAISPOLNITELYA_ID, IDENTIFIKATORISPOLNITELYA)
select p.id, jt.LINE_NO, to_number(jt.c0 default null on conversion error), cast(null as number), jt.c2
from rsd_odata_raw r
    join RSD_ISPOLNENIE p on p.legacy_ref = r.ref_key
    cross join json_table(r.doc, '$."РезультатыИсполнения"[*]' columns (
            LINE_NO for ordinality,
            c0 varchar2(4000) path '$."НомерИтерации"',
            c1 varchar2(4000) path '$."ЗадачаИсполнителя_Key"',
            c2 varchar2(4000) path '$."ИдентификаторИсполнителя"'
    )) jt
where r.entity = 'BusinessProcess.Исполнение';
commit;

-- ТЧ РезультатыПроверки → RSD_ISPOLNENIE_REZULTATYPROVERKI
delete from RSD_ISPOLNENIE_REZULTATYPROVERKI where owner_id in (select id from RSD_ISPOLNENIE);
insert into RSD_ISPOLNENIE_REZULTATYPROVERKI (OWNER_ID, LINE_NO, NOMERITERATSII, ZADACHAPROVERYAYUSHCHEGO_ID, ZADACHAISPOLNITELYA_ID, OTPRAVLENONADORABOTKU, KOMMENTARIYPROVERYAYUSHCHEGO, IDENTIFIKATORISPOLNITELYA)
select p.id, jt.LINE_NO, to_number(jt.c0 default null on conversion error), cast(null as number), cast(null as number), case when lower(jt.c3) = 'true' then true else false end, jt.c4, jt.c5
from rsd_odata_raw r
    join RSD_ISPOLNENIE p on p.legacy_ref = r.ref_key
    cross join json_table(r.doc, '$."РезультатыПроверки"[*]' columns (
            LINE_NO for ordinality,
            c0 varchar2(4000) path '$."НомерИтерации"',
            c1 varchar2(4000) path '$."ЗадачаПроверяющего_Key"',
            c2 varchar2(4000) path '$."ЗадачаИсполнителя_Key"',
            c3 varchar2(4000) path '$."ОтправленоНаДоработку"',
            c4 varchar2(4000) path '$."КомментарийПроверяющего"',
            c5 varchar2(4000) path '$."ИдентификаторИсполнителя"'
    )) jt
where r.entity = 'BusinessProcess.Исполнение';
commit;

-- ТЧ УдалитьДополнительныеИсполнители → RSD_ISPOLNENIE_UDALITDOPOLNITELNYEISPOLNITELI
delete from RSD_ISPOLNENIE_UDALITDOPOLNITELNYEISPOLNITELI where owner_id in (select id from RSD_ISPOLNENIE);
insert into RSD_ISPOLNENIE_UDALITDOPOLNITELNYEISPOLNITELI (OWNER_ID, LINE_NO)
select p.id, jt.LINE_NO
from rsd_odata_raw r
    join RSD_ISPOLNENIE p on p.legacy_ref = r.ref_key
    cross join json_table(r.doc, '$."УдалитьДополнительныеИсполнители"[*]' columns (
            LINE_NO for ordinality
    )) jt
where r.entity = 'BusinessProcess.Исполнение';
commit;

-- BusinessProcess.Утверждение → RSD_UTVERZHDENIE
merge into RSD_UTVERZHDENIE t using (
    select
        json_value(doc, '$.Ref_Key') as LEGACY_REF,
        case when lower(json_value(doc, '$."DeletionMark"')) = 'true' then true else false end as IS_DELETED,
        to_timestamp(substr(json_value(doc, '$."Date"'), 1, 19), 'YYYY-MM-DD"T"HH24:MI:SS') as DOC_DATE,
        (select tgt.id from RSD_POLZOVATELI tgt where tgt.legacy_ref = nullif(json_value(doc, '$."Автор_Key"'), '00000000-0000-0000-0000-000000000000')) as AVTOR_ID,
        (select id from rsd_enums where enum_type = 'ВариантыВажностиЗадачи' and value_key = json_value(doc, '$."Важность"')) as VAZHNOST_ID,
        (select id from rsd_enums where enum_type = 'ВариантыУстановкиСрокаИсполнения' and value_key = json_value(doc, '$."ВариантУстановкиСрокаИсполнения"')) as VARIANTUSTANOVKISROKAISPOLNENIYA_ID,
        (select id from rsd_enums where enum_type = 'ВариантыУстановкиСрокаИсполнения' and value_key = json_value(doc, '$."ВариантУстановкиСрокаОбработкиРезультатов"')) as VARIANTUSTANOVKISROKAOBRABOTKIREZULTATOV_ID,
        (select id from rsd_enums where enum_type = 'ВидыБизнесПроцессаУтверждение' and value_key = json_value(doc, '$."ВидПроцесса"')) as VIDPROTSESSA_ID,
        cast(null as number) as GLAVNAYAZADACHA_ID,
        to_timestamp(substr(json_value(doc, '$."ДатаЗавершения"'), 1, 19), 'YYYY-MM-DD"T"HH24:MI:SS') as DATAZAVERSHENIYA,
        to_timestamp(substr(json_value(doc, '$."ДатаНачала"'), 1, 19), 'YYYY-MM-DD"T"HH24:MI:SS') as DATANACHALA,
        to_number(json_value(doc, '$."КоличествоИтераций"') default null on conversion error) as KOLICHESTVOITERATSIY,
        json_value(doc, '$."Наименование"') as NAIMENOVANIE,
        to_number(json_value(doc, '$."НомерИтерации"') default null on conversion error) as NOMERITERATSII,
        json_value(doc, '$."Описание"') as OPISANIE,
        case when lower(json_value(doc, '$."ПовторитьУтверждение"')) = 'true' then true else false end as POVTORITUTVERZHDENIE,
        case when lower(json_value(doc, '$."ПодписыватьЭП"')) = 'true' then true else false end as PODPISYVATEP,
        json_value(doc, '$."ПричинаПрерывания"') as PRICHINAPRERYVANIYA,
        cast(null as number) as PROEKT_ID,
        cast(null as number) as PROEKTNAYAZADACHA_ID,
        (select id from rsd_enums where enum_type = 'РезультатыУтверждения' and value_key = json_value(doc, '$."РезультатУтверждения"')) as REZULTATUTVERZHDENIYA_ID,
        (select id from rsd_enums where enum_type = 'СостоянияБизнесПроцессов' and value_key = json_value(doc, '$."Состояние"')) as SOSTOYANIE_ID,
        to_timestamp(substr(json_value(doc, '$."СрокИсполнения"'), 1, 19), 'YYYY-MM-DD"T"HH24:MI:SS') as SROKISPOLNENIYA,
        to_number(json_value(doc, '$."СрокИсполненияДни"') default null on conversion error) as SROKISPOLNENIYADNI,
        to_number(json_value(doc, '$."СрокИсполненияМинуты"') default null on conversion error) as SROKISPOLNENIYAMINUTY,
        to_timestamp(substr(json_value(doc, '$."СрокИсполненияПроцесса"'), 1, 19), 'YYYY-MM-DD"T"HH24:MI:SS') as SROKISPOLNENIYAPROTSESSA,
        to_number(json_value(doc, '$."СрокИсполненияЧасы"') default null on conversion error) as SROKISPOLNENIYACHASY,
        to_timestamp(substr(json_value(doc, '$."СрокОбработкиРезультатов"'), 1, 19), 'YYYY-MM-DD"T"HH24:MI:SS') as SROKOBRABOTKIREZULTATOV,
        to_number(json_value(doc, '$."СрокОбработкиРезультатовДни"') default null on conversion error) as SROKOBRABOTKIREZULTATOVDNI,
        to_number(json_value(doc, '$."СрокОбработкиРезультатовМинуты"') default null on conversion error) as SROKOBRABOTKIREZULTATOVMINUTY,
        to_number(json_value(doc, '$."СрокОбработкиРезультатовЧасы"') default null on conversion error) as SROKOBRABOTKIREZULTATOVCHASY,
        to_number(json_value(doc, '$."ТрудозатратыПланАвтора"') default null on conversion error) as TRUDOZATRATYPLANAVTORA,
        to_number(json_value(doc, '$."ТрудозатратыПланИсполнителя"') default null on conversion error) as TRUDOZATRATYPLANISPOLNITELYA,
        json_value(doc, '$."УдалитьРезультатВыполнения"') as UDALITREZULTATVYPOLNENIYA,
        to_timestamp(substr(json_value(doc, '$."УдалитьСрокИсполнения"'), 1, 19), 'YYYY-MM-DD"T"HH24:MI:SS') as UDALITSROKISPOLNENIYA,
        json_value(doc, '$."УзелОбмена"') as UZELOBMENA,
        cast(null as number) as SHABLON_ID,
        json_value(doc, '$."ЭтапОбработкиПредмета"') as ETAPOBRABOTKIPREDMETA
    from rsd_odata_raw where entity = 'BusinessProcess.Утверждение'
) s on (t.legacy_ref = s.LEGACY_REF)
when matched then update set
        t.IS_DELETED = s.IS_DELETED,
        t.DOC_DATE = s.DOC_DATE,
        t.AVTOR_ID = s.AVTOR_ID,
        t.VAZHNOST_ID = s.VAZHNOST_ID,
        t.VARIANTUSTANOVKISROKAISPOLNENIYA_ID = s.VARIANTUSTANOVKISROKAISPOLNENIYA_ID,
        t.VARIANTUSTANOVKISROKAOBRABOTKIREZULTATOV_ID = s.VARIANTUSTANOVKISROKAOBRABOTKIREZULTATOV_ID,
        t.VIDPROTSESSA_ID = s.VIDPROTSESSA_ID,
        t.GLAVNAYAZADACHA_ID = s.GLAVNAYAZADACHA_ID,
        t.DATAZAVERSHENIYA = s.DATAZAVERSHENIYA,
        t.DATANACHALA = s.DATANACHALA,
        t.KOLICHESTVOITERATSIY = s.KOLICHESTVOITERATSIY,
        t.NAIMENOVANIE = s.NAIMENOVANIE,
        t.NOMERITERATSII = s.NOMERITERATSII,
        t.OPISANIE = s.OPISANIE,
        t.POVTORITUTVERZHDENIE = s.POVTORITUTVERZHDENIE,
        t.PODPISYVATEP = s.PODPISYVATEP,
        t.PRICHINAPRERYVANIYA = s.PRICHINAPRERYVANIYA,
        t.PROEKT_ID = s.PROEKT_ID,
        t.PROEKTNAYAZADACHA_ID = s.PROEKTNAYAZADACHA_ID,
        t.REZULTATUTVERZHDENIYA_ID = s.REZULTATUTVERZHDENIYA_ID,
        t.SOSTOYANIE_ID = s.SOSTOYANIE_ID,
        t.SROKISPOLNENIYA = s.SROKISPOLNENIYA,
        t.SROKISPOLNENIYADNI = s.SROKISPOLNENIYADNI,
        t.SROKISPOLNENIYAMINUTY = s.SROKISPOLNENIYAMINUTY,
        t.SROKISPOLNENIYAPROTSESSA = s.SROKISPOLNENIYAPROTSESSA,
        t.SROKISPOLNENIYACHASY = s.SROKISPOLNENIYACHASY,
        t.SROKOBRABOTKIREZULTATOV = s.SROKOBRABOTKIREZULTATOV,
        t.SROKOBRABOTKIREZULTATOVDNI = s.SROKOBRABOTKIREZULTATOVDNI,
        t.SROKOBRABOTKIREZULTATOVMINUTY = s.SROKOBRABOTKIREZULTATOVMINUTY,
        t.SROKOBRABOTKIREZULTATOVCHASY = s.SROKOBRABOTKIREZULTATOVCHASY,
        t.TRUDOZATRATYPLANAVTORA = s.TRUDOZATRATYPLANAVTORA,
        t.TRUDOZATRATYPLANISPOLNITELYA = s.TRUDOZATRATYPLANISPOLNITELYA,
        t.UDALITREZULTATVYPOLNENIYA = s.UDALITREZULTATVYPOLNENIYA,
        t.UDALITSROKISPOLNENIYA = s.UDALITSROKISPOLNENIYA,
        t.UZELOBMENA = s.UZELOBMENA,
        t.SHABLON_ID = s.SHABLON_ID,
        t.ETAPOBRABOTKIPREDMETA = s.ETAPOBRABOTKIPREDMETA
when not matched then insert (LEGACY_REF, IS_DELETED, DOC_DATE, AVTOR_ID, VAZHNOST_ID, VARIANTUSTANOVKISROKAISPOLNENIYA_ID, VARIANTUSTANOVKISROKAOBRABOTKIREZULTATOV_ID, VIDPROTSESSA_ID, GLAVNAYAZADACHA_ID, DATAZAVERSHENIYA, DATANACHALA, KOLICHESTVOITERATSIY, NAIMENOVANIE, NOMERITERATSII, OPISANIE, POVTORITUTVERZHDENIE, PODPISYVATEP, PRICHINAPRERYVANIYA, PROEKT_ID, PROEKTNAYAZADACHA_ID, REZULTATUTVERZHDENIYA_ID, SOSTOYANIE_ID, SROKISPOLNENIYA, SROKISPOLNENIYADNI, SROKISPOLNENIYAMINUTY, SROKISPOLNENIYAPROTSESSA, SROKISPOLNENIYACHASY, SROKOBRABOTKIREZULTATOV, SROKOBRABOTKIREZULTATOVDNI, SROKOBRABOTKIREZULTATOVMINUTY, SROKOBRABOTKIREZULTATOVCHASY, TRUDOZATRATYPLANAVTORA, TRUDOZATRATYPLANISPOLNITELYA, UDALITREZULTATVYPOLNENIYA, UDALITSROKISPOLNENIYA, UZELOBMENA, SHABLON_ID, ETAPOBRABOTKIPREDMETA)
    values (s.LEGACY_REF, s.IS_DELETED, s.DOC_DATE, s.AVTOR_ID, s.VAZHNOST_ID, s.VARIANTUSTANOVKISROKAISPOLNENIYA_ID, s.VARIANTUSTANOVKISROKAOBRABOTKIREZULTATOV_ID, s.VIDPROTSESSA_ID, s.GLAVNAYAZADACHA_ID, s.DATAZAVERSHENIYA, s.DATANACHALA, s.KOLICHESTVOITERATSIY, s.NAIMENOVANIE, s.NOMERITERATSII, s.OPISANIE, s.POVTORITUTVERZHDENIE, s.PODPISYVATEP, s.PRICHINAPRERYVANIYA, s.PROEKT_ID, s.PROEKTNAYAZADACHA_ID, s.REZULTATUTVERZHDENIYA_ID, s.SOSTOYANIE_ID, s.SROKISPOLNENIYA, s.SROKISPOLNENIYADNI, s.SROKISPOLNENIYAMINUTY, s.SROKISPOLNENIYAPROTSESSA, s.SROKISPOLNENIYACHASY, s.SROKOBRABOTKIREZULTATOV, s.SROKOBRABOTKIREZULTATOVDNI, s.SROKOBRABOTKIREZULTATOVMINUTY, s.SROKOBRABOTKIREZULTATOVCHASY, s.TRUDOZATRATYPLANAVTORA, s.TRUDOZATRATYPLANISPOLNITELYA, s.UDALITREZULTATVYPOLNENIYA, s.UDALITSROKISPOLNENIYA, s.UZELOBMENA, s.SHABLON_ID, s.ETAPOBRABOTKIPREDMETA);
commit;

-- ТЧ ДополнительныеРеквизиты → RSD_UTVERZHDENIE_DOPOLNITELNYEREKVIZITY
delete from RSD_UTVERZHDENIE_DOPOLNITELNYEREKVIZITY where owner_id in (select id from RSD_UTVERZHDENIE);
insert into RSD_UTVERZHDENIE_DOPOLNITELNYEREKVIZITY (OWNER_ID, LINE_NO, SVOYSTVO_ID, TEKSTOVAYASTROKA)
select p.id, jt.LINE_NO, cast(null as number), jt.c1
from rsd_odata_raw r
    join RSD_UTVERZHDENIE p on p.legacy_ref = r.ref_key
    cross join json_table(r.doc, '$."ДополнительныеРеквизиты"[*]' columns (
            LINE_NO for ordinality,
            c0 varchar2(4000) path '$."Свойство_Key"',
            c1 varchar2(4000) path '$."ТекстоваяСтрока"'
    )) jt
where r.entity = 'BusinessProcess.Утверждение';
commit;

-- ТЧ Предметы → RSD_UTVERZHDENIE_PREDMETY
delete from RSD_UTVERZHDENIE_PREDMETY where owner_id in (select id from RSD_UTVERZHDENIE);
insert into RSD_UTVERZHDENIE_PREDMETY (OWNER_ID, LINE_NO, ROLPREDMETA_ID, IMYAPREDMETA_ID, IMYAPREDMETAOSNOVANIE_ID)
select p.id, jt.LINE_NO, (select id from rsd_enums where enum_type = 'РолиПредметов' and value_key = jt.c0), cast(null as number), cast(null as number)
from rsd_odata_raw r
    join RSD_UTVERZHDENIE p on p.legacy_ref = r.ref_key
    cross join json_table(r.doc, '$."Предметы"[*]' columns (
            LINE_NO for ordinality,
            c0 varchar2(4000) path '$."РольПредмета"',
            c1 varchar2(4000) path '$."ИмяПредмета_Key"',
            c2 varchar2(4000) path '$."ИмяПредметаОснование_Key"'
    )) jt
where r.entity = 'BusinessProcess.Утверждение';
commit;

-- ТЧ ПредметыЗадач → RSD_UTVERZHDENIE_PREDMETYZADACH
delete from RSD_UTVERZHDENIE_PREDMETYZADACH where owner_id in (select id from RSD_UTVERZHDENIE);
insert into RSD_UTVERZHDENIE_PREDMETYZADACH (OWNER_ID, LINE_NO, TOCHKAMARSHRUTA_ID, IMYAPREDMETA_ID, OBYAZATELNOEZAPOLNENIE, DOSTUPNOUDALENIE)
select p.id, jt.LINE_NO, cast(null as number), cast(null as number), case when lower(jt.c2) = 'true' then true else false end, case when lower(jt.c3) = 'true' then true else false end
from rsd_odata_raw r
    join RSD_UTVERZHDENIE p on p.legacy_ref = r.ref_key
    cross join json_table(r.doc, '$."ПредметыЗадач"[*]' columns (
            LINE_NO for ordinality,
            c0 varchar2(4000) path '$."ТочкаМаршрута_Key"',
            c1 varchar2(4000) path '$."ИмяПредмета_Key"',
            c2 varchar2(4000) path '$."ОбязательноеЗаполнение"',
            c3 varchar2(4000) path '$."ДоступноУдаление"'
    )) jt
where r.entity = 'BusinessProcess.Утверждение';
commit;

-- ТЧ РезультатыОзнакомлений → RSD_UTVERZHDENIE_REZULTATYOZNAKOMLENIY
delete from RSD_UTVERZHDENIE_REZULTATYOZNAKOMLENIY where owner_id in (select id from RSD_UTVERZHDENIE);
insert into RSD_UTVERZHDENIE_REZULTATYOZNAKOMLENIY (OWNER_ID, LINE_NO, NOMERITERATSII, ZADACHAISPOLNITELYA_ID, OTPRAVLENONAPOVTORNOEUTVERZHDENIE)
select p.id, jt.LINE_NO, to_number(jt.c0 default null on conversion error), cast(null as number), case when lower(jt.c2) = 'true' then true else false end
from rsd_odata_raw r
    join RSD_UTVERZHDENIE p on p.legacy_ref = r.ref_key
    cross join json_table(r.doc, '$."РезультатыОзнакомлений"[*]' columns (
            LINE_NO for ordinality,
            c0 varchar2(4000) path '$."НомерИтерации"',
            c1 varchar2(4000) path '$."ЗадачаИсполнителя_Key"',
            c2 varchar2(4000) path '$."ОтправленоНаПовторноеУтверждение"'
    )) jt
where r.entity = 'BusinessProcess.Утверждение';
commit;

-- ТЧ РезультатыУтверждения → RSD_UTVERZHDENIE_REZULTATYUTVERZHDENIYA
delete from RSD_UTVERZHDENIE_REZULTATYUTVERZHDENIYA where owner_id in (select id from RSD_UTVERZHDENIE);
insert into RSD_UTVERZHDENIE_REZULTATYUTVERZHDENIYA (OWNER_ID, LINE_NO, NOMERITERATSII, ZADACHAISPOLNITELYA_ID, REZULTATUTVERZHDENIYA_ID)
select p.id, jt.LINE_NO, to_number(jt.c0 default null on conversion error), cast(null as number), (select id from rsd_enums where enum_type = 'РезультатыУтверждения' and value_key = jt.c2)
from rsd_odata_raw r
    join RSD_UTVERZHDENIE p on p.legacy_ref = r.ref_key
    cross join json_table(r.doc, '$."РезультатыУтверждения"[*]' columns (
            LINE_NO for ordinality,
            c0 varchar2(4000) path '$."НомерИтерации"',
            c1 varchar2(4000) path '$."ЗадачаИсполнителя_Key"',
            c2 varchar2(4000) path '$."РезультатУтверждения"'
    )) jt
where r.entity = 'BusinessProcess.Утверждение';
commit;

-- ТЧ УдалитьДополнительныеИсполнители → RSD_UTVERZHDENIE_UDALITDOPOLNITELNYEISPOLNITELI
delete from RSD_UTVERZHDENIE_UDALITDOPOLNITELNYEISPOLNITELI where owner_id in (select id from RSD_UTVERZHDENIE);
insert into RSD_UTVERZHDENIE_UDALITDOPOLNITELNYEISPOLNITELI (OWNER_ID, LINE_NO)
select p.id, jt.LINE_NO
from rsd_odata_raw r
    join RSD_UTVERZHDENIE p on p.legacy_ref = r.ref_key
    cross join json_table(r.doc, '$."УдалитьДополнительныеИсполнители"[*]' columns (
            LINE_NO for ordinality
    )) jt
where r.entity = 'BusinessProcess.Утверждение';
commit;
