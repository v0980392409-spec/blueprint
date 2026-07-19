-- Батч 004: типізована проекція RAW → RSD_*. Запускати ДВІЧІ (цикли).
-- NLS_LANG=.AL32UTF8.
set define off

-- Catalog.УсловияМаршрутизации → RSD_USLOVIYAMARSHRUTIZATSII
merge into RSD_USLOVIYAMARSHRUTIZATSII t using (
    select
        json_value(doc, '$.Ref_Key') as LEGACY_REF,
        case when lower(json_value(doc, '$."DeletionMark"')) = 'true' then true else false end as IS_DELETED,
        json_value(doc, '$."Code"') as CODE,
        json_value(doc, '$."Description"') as NAME,
        json_value(doc, '$."ВыражениеУсловия"') as VYRAZHENIEUSLOVIYA,
        json_value(doc, '$."Комментарий"') as KOMMENTARIY,
        json_value(doc, '$."НастройкаКомбинацииУсловий"') as NASTROYKAKOMBINATSIIUSLOVIY,
        json_value(doc, '$."НастройкаУсловия"') as NASTROYKAUSLOVIYA,
        (select tgt.id from RSD_POLZOVATELI tgt where tgt.legacy_ref = nullif(json_value(doc, '$."Ответственный_Key"'), '00000000-0000-0000-0000-000000000000')) as OTVETSTVENNYY_ID,
        json_value(doc, '$."ПредставлениеОтбора"') as PREDSTAVLENIEOTBORA,
        (select id from rsd_enums where enum_type = 'СпособыЗаданияУсловия' and value_key = json_value(doc, '$."СпособЗаданияУсловия"')) as SPOSOBZADANIYAUSLOVIYA_ID,
        (select id from rsd_enums where enum_type = 'ТипыОбъектов' and value_key = json_value(doc, '$."ТипОбъекта"')) as TIPOBEKTA_ID
    from rsd_odata_raw where entity = 'Catalog.УсловияМаршрутизации'
) s on (t.legacy_ref = s.LEGACY_REF)
when matched then update set
        t.IS_DELETED = s.IS_DELETED,
        t.CODE = s.CODE,
        t.NAME = s.NAME,
        t.VYRAZHENIEUSLOVIYA = s.VYRAZHENIEUSLOVIYA,
        t.KOMMENTARIY = s.KOMMENTARIY,
        t.NASTROYKAKOMBINATSIIUSLOVIY = s.NASTROYKAKOMBINATSIIUSLOVIY,
        t.NASTROYKAUSLOVIYA = s.NASTROYKAUSLOVIYA,
        t.OTVETSTVENNYY_ID = s.OTVETSTVENNYY_ID,
        t.PREDSTAVLENIEOTBORA = s.PREDSTAVLENIEOTBORA,
        t.SPOSOBZADANIYAUSLOVIYA_ID = s.SPOSOBZADANIYAUSLOVIYA_ID,
        t.TIPOBEKTA_ID = s.TIPOBEKTA_ID
when not matched then insert (LEGACY_REF, IS_DELETED, CODE, NAME, VYRAZHENIEUSLOVIYA, KOMMENTARIY, NASTROYKAKOMBINATSIIUSLOVIY, NASTROYKAUSLOVIYA, OTVETSTVENNYY_ID, PREDSTAVLENIEOTBORA, SPOSOBZADANIYAUSLOVIYA_ID, TIPOBEKTA_ID)
    values (s.LEGACY_REF, s.IS_DELETED, s.CODE, s.NAME, s.VYRAZHENIEUSLOVIYA, s.KOMMENTARIY, s.NASTROYKAKOMBINATSIIUSLOVIY, s.NASTROYKAUSLOVIYA, s.OTVETSTVENNYY_ID, s.PREDSTAVLENIEOTBORA, s.SPOSOBZADANIYAUSLOVIYA_ID, s.TIPOBEKTA_ID);
commit;

-- Catalog.ВидыВходящихДокументов → RSD_VIDYVKHODYASHCHIKHDOKUMENTOV
merge into RSD_VIDYVKHODYASHCHIKHDOKUMENTOV t using (
    select
        json_value(doc, '$.Ref_Key') as LEGACY_REF,
        case when lower(json_value(doc, '$."DeletionMark"')) = 'true' then true else false end as IS_DELETED,
        json_value(doc, '$."Description"') as NAME,
        case when lower(json_value(doc, '$."АвтоматическиВестиСоставУчастниковРабочейГруппы"')) = 'true' then true else false end as AVTOMATICHESKIVESTISOSTAVUCHASTNIKOVRABOCHEYGRUPPY,
        case when lower(json_value(doc, '$."ВестиУчетПоНоменклатуреДел"')) = 'true' then true else false end as VESTIUCHETPONOMENKLATUREDEL,
        case when lower(json_value(doc, '$."ВключенУчетПоНоменклатуреДел"')) = 'true' then true else false end as VKLYUCHENUCHETPONOMENKLATUREDEL,
        case when lower(json_value(doc, '$."ЗапретитьСозданиеДокументовНеПоШаблону"')) = 'true' then true else false end as ZAPRETITSOZDANIEDOKUMENTOVNEPOSHABLONU,
        case when lower(json_value(doc, '$."ИспользоватьСрокИсполнения"')) = 'true' then true else false end as ISPOLZOVATSROKISPOLNENIYA,
        case when lower(json_value(doc, '$."ИспользоватьЭтапыОбработкиДокумента"')) = 'true' then true else false end as ISPOLZOVATETAPYOBRABOTKIDOKUMENTA,
        json_value(doc, '$."Комментарий"') as KOMMENTARIY,
        cast(null as number) as NABORSVOYSTV_ID,
        case when lower(json_value(doc, '$."НеобходимаПечатьШтрихкода"')) = 'true' then true else false end as NEOBKHODIMAPECHATSHTRIKHKODA,
        (select tgt.id from RSD_NUMERATORY tgt where tgt.legacy_ref = nullif(json_value(doc, '$."УдалитьНумератор_Key"'), '00000000-0000-0000-0000-000000000000')) as UDALITNUMERATOR_ID,
        case when lower(json_value(doc, '$."ОбязательноеЗаполнениеРабочихГруппДокументов"')) = 'true' then true else false end as OBYAZATELNOEZAPOLNENIERABOCHIKHGRUPPDOKUMENTOV,
        case when lower(json_value(doc, '$."ОбязателенФайлОригинала"')) = 'true' then true else false end as OBYAZATELENFAYLORIGINALA,
        case when lower(json_value(doc, '$."ОбязательноеУказаниеОтветственного"')) = 'true' then true else false end as OBYAZATELNOEUKAZANIEOTVETSTVENNOGO,
        case when lower(json_value(doc, '$."ПодписыватьРезолюцииЭП"')) = 'true' then true else false end as PODPISYVATREZOLYUTSIIEP,
        (select id from rsd_enums where enum_type = 'СпособыНумерации' and value_key = json_value(doc, '$."УдалитьСпособНумерации"')) as UDALITSPOSOBNUMERATSII_ID,
        to_number(json_value(doc, '$."СрокИсполнения"') default null on conversion error) as SROKISPOLNENIYA,
        case when lower(json_value(doc, '$."УчитыватьКакОбращениеГраждан"')) = 'true' then true else false end as UCHITYVATKAKOBRASHCHENIEGRAZHDAN,
        case when lower(json_value(doc, '$."УчитыватьСуммуДокумента"')) = 'true' then true else false end as UCHITYVATSUMMUDOKUMENTA,
        case when lower(json_value(doc, '$."ЯвляетсяОбращениемОтГраждан"')) = 'true' then true else false end as YAVLYAETSYAOBRASHCHENIEMOTGRAZHDAN,
        case when lower(json_value(doc, '$."RSD_СтатусERP"')) = 'true' then true else false end as RSD_STATUSERP,
        case when lower(json_value(doc, '$."RSD_ВестиУчетПоНомеруИДатеСозданияДокумента"')) = 'true' then true else false end as RSD_VESTIUCHETPONOMERUIDATESOZDANIYADOKUMENTA,
        (select id from rsd_enums where enum_type = 'RSD_ТипДокумента' and value_key = json_value(doc, '$."RSD_ТипДокумента"')) as RSD_TIPDOKUMENTA_ID,
        case when lower(json_value(doc, '$."RSD_ИспользоватьУчетОтветаНаВходящийДокумент"')) = 'true' then true else false end as RSD_ISPOLZOVATUCHETOTVETANAVKHODYASHCHIYDOKUMENT,
        case when lower(json_value(doc, '$."RSD_ВестиУчетПоЮридическомуЛицу"')) = 'true' then true else false end as RSD_VESTIUCHETPOYURIDICHESKOMULITSU,
        case when lower(json_value(doc, '$."RSD_ПрикреплениеФайловСШаблона"')) = 'true' then true else false end as RSD_PRIKREPLENIEFAYLOVSSHABLONA
    from rsd_odata_raw where entity = 'Catalog.ВидыВходящихДокументов'
) s on (t.legacy_ref = s.LEGACY_REF)
when matched then update set
        t.IS_DELETED = s.IS_DELETED,
        t.NAME = s.NAME,
        t.AVTOMATICHESKIVESTISOSTAVUCHASTNIKOVRABOCHEYGRUPPY = s.AVTOMATICHESKIVESTISOSTAVUCHASTNIKOVRABOCHEYGRUPPY,
        t.VESTIUCHETPONOMENKLATUREDEL = s.VESTIUCHETPONOMENKLATUREDEL,
        t.VKLYUCHENUCHETPONOMENKLATUREDEL = s.VKLYUCHENUCHETPONOMENKLATUREDEL,
        t.ZAPRETITSOZDANIEDOKUMENTOVNEPOSHABLONU = s.ZAPRETITSOZDANIEDOKUMENTOVNEPOSHABLONU,
        t.ISPOLZOVATSROKISPOLNENIYA = s.ISPOLZOVATSROKISPOLNENIYA,
        t.ISPOLZOVATETAPYOBRABOTKIDOKUMENTA = s.ISPOLZOVATETAPYOBRABOTKIDOKUMENTA,
        t.KOMMENTARIY = s.KOMMENTARIY,
        t.NABORSVOYSTV_ID = s.NABORSVOYSTV_ID,
        t.NEOBKHODIMAPECHATSHTRIKHKODA = s.NEOBKHODIMAPECHATSHTRIKHKODA,
        t.UDALITNUMERATOR_ID = s.UDALITNUMERATOR_ID,
        t.OBYAZATELNOEZAPOLNENIERABOCHIKHGRUPPDOKUMENTOV = s.OBYAZATELNOEZAPOLNENIERABOCHIKHGRUPPDOKUMENTOV,
        t.OBYAZATELENFAYLORIGINALA = s.OBYAZATELENFAYLORIGINALA,
        t.OBYAZATELNOEUKAZANIEOTVETSTVENNOGO = s.OBYAZATELNOEUKAZANIEOTVETSTVENNOGO,
        t.PODPISYVATREZOLYUTSIIEP = s.PODPISYVATREZOLYUTSIIEP,
        t.UDALITSPOSOBNUMERATSII_ID = s.UDALITSPOSOBNUMERATSII_ID,
        t.SROKISPOLNENIYA = s.SROKISPOLNENIYA,
        t.UCHITYVATKAKOBRASHCHENIEGRAZHDAN = s.UCHITYVATKAKOBRASHCHENIEGRAZHDAN,
        t.UCHITYVATSUMMUDOKUMENTA = s.UCHITYVATSUMMUDOKUMENTA,
        t.YAVLYAETSYAOBRASHCHENIEMOTGRAZHDAN = s.YAVLYAETSYAOBRASHCHENIEMOTGRAZHDAN,
        t.RSD_STATUSERP = s.RSD_STATUSERP,
        t.RSD_VESTIUCHETPONOMERUIDATESOZDANIYADOKUMENTA = s.RSD_VESTIUCHETPONOMERUIDATESOZDANIYADOKUMENTA,
        t.RSD_TIPDOKUMENTA_ID = s.RSD_TIPDOKUMENTA_ID,
        t.RSD_ISPOLZOVATUCHETOTVETANAVKHODYASHCHIYDOKUMENT = s.RSD_ISPOLZOVATUCHETOTVETANAVKHODYASHCHIYDOKUMENT,
        t.RSD_VESTIUCHETPOYURIDICHESKOMULITSU = s.RSD_VESTIUCHETPOYURIDICHESKOMULITSU,
        t.RSD_PRIKREPLENIEFAYLOVSSHABLONA = s.RSD_PRIKREPLENIEFAYLOVSSHABLONA
when not matched then insert (LEGACY_REF, IS_DELETED, NAME, AVTOMATICHESKIVESTISOSTAVUCHASTNIKOVRABOCHEYGRUPPY, VESTIUCHETPONOMENKLATUREDEL, VKLYUCHENUCHETPONOMENKLATUREDEL, ZAPRETITSOZDANIEDOKUMENTOVNEPOSHABLONU, ISPOLZOVATSROKISPOLNENIYA, ISPOLZOVATETAPYOBRABOTKIDOKUMENTA, KOMMENTARIY, NABORSVOYSTV_ID, NEOBKHODIMAPECHATSHTRIKHKODA, UDALITNUMERATOR_ID, OBYAZATELNOEZAPOLNENIERABOCHIKHGRUPPDOKUMENTOV, OBYAZATELENFAYLORIGINALA, OBYAZATELNOEUKAZANIEOTVETSTVENNOGO, PODPISYVATREZOLYUTSIIEP, UDALITSPOSOBNUMERATSII_ID, SROKISPOLNENIYA, UCHITYVATKAKOBRASHCHENIEGRAZHDAN, UCHITYVATSUMMUDOKUMENTA, YAVLYAETSYAOBRASHCHENIEMOTGRAZHDAN, RSD_STATUSERP, RSD_VESTIUCHETPONOMERUIDATESOZDANIYADOKUMENTA, RSD_TIPDOKUMENTA_ID, RSD_ISPOLZOVATUCHETOTVETANAVKHODYASHCHIYDOKUMENT, RSD_VESTIUCHETPOYURIDICHESKOMULITSU, RSD_PRIKREPLENIEFAYLOVSSHABLONA)
    values (s.LEGACY_REF, s.IS_DELETED, s.NAME, s.AVTOMATICHESKIVESTISOSTAVUCHASTNIKOVRABOCHEYGRUPPY, s.VESTIUCHETPONOMENKLATUREDEL, s.VKLYUCHENUCHETPONOMENKLATUREDEL, s.ZAPRETITSOZDANIEDOKUMENTOVNEPOSHABLONU, s.ISPOLZOVATSROKISPOLNENIYA, s.ISPOLZOVATETAPYOBRABOTKIDOKUMENTA, s.KOMMENTARIY, s.NABORSVOYSTV_ID, s.NEOBKHODIMAPECHATSHTRIKHKODA, s.UDALITNUMERATOR_ID, s.OBYAZATELNOEZAPOLNENIERABOCHIKHGRUPPDOKUMENTOV, s.OBYAZATELENFAYLORIGINALA, s.OBYAZATELNOEUKAZANIEOTVETSTVENNOGO, s.PODPISYVATREZOLYUTSIIEP, s.UDALITSPOSOBNUMERATSII_ID, s.SROKISPOLNENIYA, s.UCHITYVATKAKOBRASHCHENIEGRAZHDAN, s.UCHITYVATSUMMUDOKUMENTA, s.YAVLYAETSYAOBRASHCHENIEMOTGRAZHDAN, s.RSD_STATUSERP, s.RSD_VESTIUCHETPONOMERUIDATESOZDANIYADOKUMENTA, s.RSD_TIPDOKUMENTA_ID, s.RSD_ISPOLZOVATUCHETOTVETANAVKHODYASHCHIYDOKUMENT, s.RSD_VESTIUCHETPOYURIDICHESKOMULITSU, s.RSD_PRIKREPLENIEFAYLOVSSHABLONA);
commit;

-- Catalog.СтруктураПредприятия → RSD_STRUKTURAPREDPRIYATIYA
merge into RSD_STRUKTURAPREDPRIYATIYA t using (
    select
        json_value(doc, '$.Ref_Key') as LEGACY_REF,
        case when lower(json_value(doc, '$."DeletionMark"')) = 'true' then true else false end as IS_DELETED,
        json_value(doc, '$."Code"') as CODE,
        json_value(doc, '$."Description"') as NAME,
        (select tgt.id from RSD_POLZOVATELI tgt where tgt.legacy_ref = nullif(json_value(doc, '$."Руководитель_Key"'), '00000000-0000-0000-0000-000000000000')) as RUKOVODITEL_ID,
        (select tgt.id from RSD_GRAFIKIRABOTY tgt where tgt.legacy_ref = nullif(json_value(doc, '$."ГрафикРаботы_Key"'), '00000000-0000-0000-0000-000000000000')) as GRAFIKRABOTY_ID,
        json_value(doc, '$."Комментарий"') as KOMMENTARIY
    from rsd_odata_raw where entity = 'Catalog.СтруктураПредприятия'
) s on (t.legacy_ref = s.LEGACY_REF)
when matched then update set
        t.IS_DELETED = s.IS_DELETED,
        t.CODE = s.CODE,
        t.NAME = s.NAME,
        t.RUKOVODITEL_ID = s.RUKOVODITEL_ID,
        t.GRAFIKRABOTY_ID = s.GRAFIKRABOTY_ID,
        t.KOMMENTARIY = s.KOMMENTARIY
when not matched then insert (LEGACY_REF, IS_DELETED, CODE, NAME, RUKOVODITEL_ID, GRAFIKRABOTY_ID, KOMMENTARIY)
    values (s.LEGACY_REF, s.IS_DELETED, s.CODE, s.NAME, s.RUKOVODITEL_ID, s.GRAFIKRABOTY_ID, s.KOMMENTARIY);
commit;

-- Catalog.ВидыВнутреннихДокументов → RSD_VIDYVNUTRENNIKHDOKUMENTOV
merge into RSD_VIDYVNUTRENNIKHDOKUMENTOV t using (
    select
        json_value(doc, '$.Ref_Key') as LEGACY_REF,
        case when lower(json_value(doc, '$."DeletionMark"')) = 'true' then true else false end as IS_DELETED,
        json_value(doc, '$."Description"') as NAME,
        case when lower(json_value(doc, '$."RSD_ВестиУчетПоНомеруИДатеСозданияДокумента"')) = 'true' then true else false end as RSD_VESTIUCHETPONOMERUIDATESOZDANIYADOKUMENTA,
        case when lower(json_value(doc, '$."RSD_ВестиУчетУчасниковТендера"')) = 'true' then true else false end as RSD_VESTIUCHETUCHASNIKOVTENDERA,
        case when lower(json_value(doc, '$."RSD_ВывестиДомИСекцию"')) = 'true' then true else false end as RSD_VYVESTIDOMISEKTSIYU,
        case when lower(json_value(doc, '$."RSD_ИспользоватьДанныеСтруктурыОбъектаСтроительства"')) = 'true' then true else false end as RSD_ISPOLZOVATDANNYESTRUKTURYOBEKTASTROITELSTVA,
        case when lower(json_value(doc, '$."RSD_ИспользоватьКлассификаторРазделов"')) = 'true' then true else false end as RSD_ISPOLZOVATKLASSIFIKATORRAZDELOV,
        case when lower(json_value(doc, '$."RSD_ОграничениеПоБюджетуИспользовать"')) = 'true' then true else false end as RSD_OGRANICHENIEPOBYUDZHETUISPOLZOVAT,
        case when lower(json_value(doc, '$."RSD_СтатусERP"')) = 'true' then true else false end as RSD_STATUSERP,
        (select id from rsd_enums where enum_type = 'RSD_ТипДокумента' and value_key = json_value(doc, '$."RSD_ТипДокумента"')) as RSD_TIPDOKUMENTA_ID,
        case when lower(json_value(doc, '$."RSD_УчетПодрядчиковВЧерномСписке"')) = 'true' then true else false end as RSD_UCHETPODRYADCHIKOVVCHERNOMSPISKE,
        case when lower(json_value(doc, '$."АвтоматическиВестиСоставУчастниковРабочейГруппы"')) = 'true' then true else false end as AVTOMATICHESKIVESTISOSTAVUCHASTNIKOVRABOCHEYGRUPPY,
        (select id from rsd_enums where enum_type = 'ВариантыПодписания' and value_key = json_value(doc, '$."ВариантПодписания"')) as VARIANTPODPISANIYA_ID,
        case when lower(json_value(doc, '$."ВестиУчетВыдачиИзАрхива"')) = 'true' then true else false end as VESTIUCHETVYDACHIIZARKHIVA,
        case when lower(json_value(doc, '$."ВестиУчетЗапросовКурьера"')) = 'true' then true else false end as VESTIUCHETZAPROSOVKURERA,
        case when lower(json_value(doc, '$."ВестиУчетПоАдресатам"')) = 'true' then true else false end as VESTIUCHETPOADRESATAM,
        case when lower(json_value(doc, '$."ВестиУчетПоКонтрагентам"')) = 'true' then true else false end as VESTIUCHETPOKONTRAGENTAM,
        case when lower(json_value(doc, '$."ВестиУчетПоНоменклатуреДел"')) = 'true' then true else false end as VESTIUCHETPONOMENKLATUREDEL,
        case when lower(json_value(doc, '$."ВестиУчетПоОрганизациям"')) = 'true' then true else false end as VESTIUCHETPOORGANIZATSIYAM,
        case when lower(json_value(doc, '$."ВестиУчетПоСтатьямДДС"')) = 'true' then true else false end as VESTIUCHETPOSTATYAMDDS,
        case when lower(json_value(doc, '$."ВестиУчетСторон"')) = 'true' then true else false end as VESTIUCHETSTORON,
        case when lower(json_value(doc, '$."ВестиУчетТоваровИУслуг"')) = 'true' then true else false end as VESTIUCHETTOVAROVIUSLUG,
        case when lower(json_value(doc, '$."ВключенУчетПоНоменклатуреДел"')) = 'true' then true else false end as VKLYUCHENUCHETPONOMENKLATUREDEL,
        case when lower(json_value(doc, '$."ЗапретитьСозданиеДокументовНеПоШаблону"')) = 'true' then true else false end as ZAPRETITSOZDANIEDOKUMENTOVNEPOSHABLONU,
        case when lower(json_value(doc, '$."ИспользоватьПодписание"')) = 'true' then true else false end as ISPOLZOVATPODPISANIE,
        case when lower(json_value(doc, '$."ИспользоватьСрокИсполнения"')) = 'true' then true else false end as ISPOLZOVATSROKISPOLNENIYA,
        case when lower(json_value(doc, '$."ИспользоватьУтверждение"')) = 'true' then true else false end as ISPOLZOVATUTVERZHDENIE,
        case when lower(json_value(doc, '$."ИспользоватьЭтапыОбработкиДокумента"')) = 'true' then true else false end as ISPOLZOVATETAPYOBRABOTKIDOKUMENTA,
        json_value(doc, '$."Комментарий"') as KOMMENTARIY,
        cast(null as number) as NABORSVOYSTV_ID,
        case when lower(json_value(doc, '$."НеобходимаПечатьШтрихкода"')) = 'true' then true else false end as NEOBKHODIMAPECHATSHTRIKHKODA,
        case when lower(json_value(doc, '$."ОбязателенФайлОригинала"')) = 'true' then true else false end as OBYAZATELENFAYLORIGINALA,
        case when lower(json_value(doc, '$."ОбязательноеЗаполнениеРабочихГруппДокументов"')) = 'true' then true else false end as OBYAZATELNOEZAPOLNENIERABOCHIKHGRUPPDOKUMENTOV,
        case when lower(json_value(doc, '$."ОбязательноеУказаниеОтветственного"')) = 'true' then true else false end as OBYAZATELNOEUKAZANIEOTVETSTVENNOGO,
        case when lower(json_value(doc, '$."ПодписыватьРезолюцииЭП"')) = 'true' then true else false end as PODPISYVATREZOLYUTSIIEP,
        to_number(json_value(doc, '$."СрокИсполнения"') default null on conversion error) as SROKISPOLNENIYA,
        (select tgt.id from RSD_NUMERATORY tgt where tgt.legacy_ref = nullif(json_value(doc, '$."УдалитьНумератор_Key"'), '00000000-0000-0000-0000-000000000000')) as UDALITNUMERATOR_ID,
        (select id from rsd_enums where enum_type = 'СпособыНумерации' and value_key = json_value(doc, '$."УдалитьСпособНумерации"')) as UDALITSPOSOBNUMERATSII_ID,
        case when lower(json_value(doc, '$."УчитыватьНедействующиеДокументы"')) = 'true' then true else false end as UCHITYVATNEDEYSTVUYUSHCHIEDOKUMENTY,
        case when lower(json_value(doc, '$."УчитыватьСрокДействия"')) = 'true' then true else false end as UCHITYVATSROKDEYSTVIYA,
        case when lower(json_value(doc, '$."УчитыватьСуммуДокумента"')) = 'true' then true else false end as UCHITYVATSUMMUDOKUMENTA,
        case when lower(json_value(doc, '$."ЯвляетсяДоговором"')) = 'true' then true else false end as YAVLYAETSYADOGOVOROM,
        case when lower(json_value(doc, '$."ЯвляетсяКомплектомДокументов"')) = 'true' then true else false end as YAVLYAETSYAKOMPLEKTOMDOKUMENTOV,
        case when lower(json_value(doc, '$."RSD_ПрикреплениеФайловСШаблона"')) = 'true' then true else false end as RSD_PRIKREPLENIEFAYLOVSSHABLONA,
        case when lower(json_value(doc, '$."RSD_УчитыватьСтруктуруДокументов"')) = 'true' then true else false end as RSD_UCHITYVATSTRUKTURUDOKUMENTOV,
        (select id from rsd_enums where enum_type = 'RSD_СтруктураДокумента' and value_key = json_value(doc, '$."RSD_СтруктураДокумента"')) as RSD_STRUKTURADOKUMENTA_ID,
        case when lower(json_value(doc, '$."RSD_ВестиУчетПоГруппамДомов"')) = 'true' then true else false end as RSD_VESTIUCHETPOGRUPPAMDOMOV,
        case when lower(json_value(doc, '$."RSD_ВестиУчетКомментариевКЗадачамБП"')) = 'true' then true else false end as RSD_VESTIUCHETKOMMENTARIEVKZADACHAMBP,
        case when lower(json_value(doc, '$."RSD_ВыводитьРабочуюГруппуВДокументе"')) = 'true' then true else false end as RSD_VYVODITRABOCHUYUGRUPPUVDOKUMENTE
    from rsd_odata_raw where entity = 'Catalog.ВидыВнутреннихДокументов'
) s on (t.legacy_ref = s.LEGACY_REF)
when matched then update set
        t.IS_DELETED = s.IS_DELETED,
        t.NAME = s.NAME,
        t.RSD_VESTIUCHETPONOMERUIDATESOZDANIYADOKUMENTA = s.RSD_VESTIUCHETPONOMERUIDATESOZDANIYADOKUMENTA,
        t.RSD_VESTIUCHETUCHASNIKOVTENDERA = s.RSD_VESTIUCHETUCHASNIKOVTENDERA,
        t.RSD_VYVESTIDOMISEKTSIYU = s.RSD_VYVESTIDOMISEKTSIYU,
        t.RSD_ISPOLZOVATDANNYESTRUKTURYOBEKTASTROITELSTVA = s.RSD_ISPOLZOVATDANNYESTRUKTURYOBEKTASTROITELSTVA,
        t.RSD_ISPOLZOVATKLASSIFIKATORRAZDELOV = s.RSD_ISPOLZOVATKLASSIFIKATORRAZDELOV,
        t.RSD_OGRANICHENIEPOBYUDZHETUISPOLZOVAT = s.RSD_OGRANICHENIEPOBYUDZHETUISPOLZOVAT,
        t.RSD_STATUSERP = s.RSD_STATUSERP,
        t.RSD_TIPDOKUMENTA_ID = s.RSD_TIPDOKUMENTA_ID,
        t.RSD_UCHETPODRYADCHIKOVVCHERNOMSPISKE = s.RSD_UCHETPODRYADCHIKOVVCHERNOMSPISKE,
        t.AVTOMATICHESKIVESTISOSTAVUCHASTNIKOVRABOCHEYGRUPPY = s.AVTOMATICHESKIVESTISOSTAVUCHASTNIKOVRABOCHEYGRUPPY,
        t.VARIANTPODPISANIYA_ID = s.VARIANTPODPISANIYA_ID,
        t.VESTIUCHETVYDACHIIZARKHIVA = s.VESTIUCHETVYDACHIIZARKHIVA,
        t.VESTIUCHETZAPROSOVKURERA = s.VESTIUCHETZAPROSOVKURERA,
        t.VESTIUCHETPOADRESATAM = s.VESTIUCHETPOADRESATAM,
        t.VESTIUCHETPOKONTRAGENTAM = s.VESTIUCHETPOKONTRAGENTAM,
        t.VESTIUCHETPONOMENKLATUREDEL = s.VESTIUCHETPONOMENKLATUREDEL,
        t.VESTIUCHETPOORGANIZATSIYAM = s.VESTIUCHETPOORGANIZATSIYAM,
        t.VESTIUCHETPOSTATYAMDDS = s.VESTIUCHETPOSTATYAMDDS,
        t.VESTIUCHETSTORON = s.VESTIUCHETSTORON,
        t.VESTIUCHETTOVAROVIUSLUG = s.VESTIUCHETTOVAROVIUSLUG,
        t.VKLYUCHENUCHETPONOMENKLATUREDEL = s.VKLYUCHENUCHETPONOMENKLATUREDEL,
        t.ZAPRETITSOZDANIEDOKUMENTOVNEPOSHABLONU = s.ZAPRETITSOZDANIEDOKUMENTOVNEPOSHABLONU,
        t.ISPOLZOVATPODPISANIE = s.ISPOLZOVATPODPISANIE,
        t.ISPOLZOVATSROKISPOLNENIYA = s.ISPOLZOVATSROKISPOLNENIYA,
        t.ISPOLZOVATUTVERZHDENIE = s.ISPOLZOVATUTVERZHDENIE,
        t.ISPOLZOVATETAPYOBRABOTKIDOKUMENTA = s.ISPOLZOVATETAPYOBRABOTKIDOKUMENTA,
        t.KOMMENTARIY = s.KOMMENTARIY,
        t.NABORSVOYSTV_ID = s.NABORSVOYSTV_ID,
        t.NEOBKHODIMAPECHATSHTRIKHKODA = s.NEOBKHODIMAPECHATSHTRIKHKODA,
        t.OBYAZATELENFAYLORIGINALA = s.OBYAZATELENFAYLORIGINALA,
        t.OBYAZATELNOEZAPOLNENIERABOCHIKHGRUPPDOKUMENTOV = s.OBYAZATELNOEZAPOLNENIERABOCHIKHGRUPPDOKUMENTOV,
        t.OBYAZATELNOEUKAZANIEOTVETSTVENNOGO = s.OBYAZATELNOEUKAZANIEOTVETSTVENNOGO,
        t.PODPISYVATREZOLYUTSIIEP = s.PODPISYVATREZOLYUTSIIEP,
        t.SROKISPOLNENIYA = s.SROKISPOLNENIYA,
        t.UDALITNUMERATOR_ID = s.UDALITNUMERATOR_ID,
        t.UDALITSPOSOBNUMERATSII_ID = s.UDALITSPOSOBNUMERATSII_ID,
        t.UCHITYVATNEDEYSTVUYUSHCHIEDOKUMENTY = s.UCHITYVATNEDEYSTVUYUSHCHIEDOKUMENTY,
        t.UCHITYVATSROKDEYSTVIYA = s.UCHITYVATSROKDEYSTVIYA,
        t.UCHITYVATSUMMUDOKUMENTA = s.UCHITYVATSUMMUDOKUMENTA,
        t.YAVLYAETSYADOGOVOROM = s.YAVLYAETSYADOGOVOROM,
        t.YAVLYAETSYAKOMPLEKTOMDOKUMENTOV = s.YAVLYAETSYAKOMPLEKTOMDOKUMENTOV,
        t.RSD_PRIKREPLENIEFAYLOVSSHABLONA = s.RSD_PRIKREPLENIEFAYLOVSSHABLONA,
        t.RSD_UCHITYVATSTRUKTURUDOKUMENTOV = s.RSD_UCHITYVATSTRUKTURUDOKUMENTOV,
        t.RSD_STRUKTURADOKUMENTA_ID = s.RSD_STRUKTURADOKUMENTA_ID,
        t.RSD_VESTIUCHETPOGRUPPAMDOMOV = s.RSD_VESTIUCHETPOGRUPPAMDOMOV,
        t.RSD_VESTIUCHETKOMMENTARIEVKZADACHAMBP = s.RSD_VESTIUCHETKOMMENTARIEVKZADACHAMBP,
        t.RSD_VYVODITRABOCHUYUGRUPPUVDOKUMENTE = s.RSD_VYVODITRABOCHUYUGRUPPUVDOKUMENTE
when not matched then insert (LEGACY_REF, IS_DELETED, NAME, RSD_VESTIUCHETPONOMERUIDATESOZDANIYADOKUMENTA, RSD_VESTIUCHETUCHASNIKOVTENDERA, RSD_VYVESTIDOMISEKTSIYU, RSD_ISPOLZOVATDANNYESTRUKTURYOBEKTASTROITELSTVA, RSD_ISPOLZOVATKLASSIFIKATORRAZDELOV, RSD_OGRANICHENIEPOBYUDZHETUISPOLZOVAT, RSD_STATUSERP, RSD_TIPDOKUMENTA_ID, RSD_UCHETPODRYADCHIKOVVCHERNOMSPISKE, AVTOMATICHESKIVESTISOSTAVUCHASTNIKOVRABOCHEYGRUPPY, VARIANTPODPISANIYA_ID, VESTIUCHETVYDACHIIZARKHIVA, VESTIUCHETZAPROSOVKURERA, VESTIUCHETPOADRESATAM, VESTIUCHETPOKONTRAGENTAM, VESTIUCHETPONOMENKLATUREDEL, VESTIUCHETPOORGANIZATSIYAM, VESTIUCHETPOSTATYAMDDS, VESTIUCHETSTORON, VESTIUCHETTOVAROVIUSLUG, VKLYUCHENUCHETPONOMENKLATUREDEL, ZAPRETITSOZDANIEDOKUMENTOVNEPOSHABLONU, ISPOLZOVATPODPISANIE, ISPOLZOVATSROKISPOLNENIYA, ISPOLZOVATUTVERZHDENIE, ISPOLZOVATETAPYOBRABOTKIDOKUMENTA, KOMMENTARIY, NABORSVOYSTV_ID, NEOBKHODIMAPECHATSHTRIKHKODA, OBYAZATELENFAYLORIGINALA, OBYAZATELNOEZAPOLNENIERABOCHIKHGRUPPDOKUMENTOV, OBYAZATELNOEUKAZANIEOTVETSTVENNOGO, PODPISYVATREZOLYUTSIIEP, SROKISPOLNENIYA, UDALITNUMERATOR_ID, UDALITSPOSOBNUMERATSII_ID, UCHITYVATNEDEYSTVUYUSHCHIEDOKUMENTY, UCHITYVATSROKDEYSTVIYA, UCHITYVATSUMMUDOKUMENTA, YAVLYAETSYADOGOVOROM, YAVLYAETSYAKOMPLEKTOMDOKUMENTOV, RSD_PRIKREPLENIEFAYLOVSSHABLONA, RSD_UCHITYVATSTRUKTURUDOKUMENTOV, RSD_STRUKTURADOKUMENTA_ID, RSD_VESTIUCHETPOGRUPPAMDOMOV, RSD_VESTIUCHETKOMMENTARIEVKZADACHAMBP, RSD_VYVODITRABOCHUYUGRUPPUVDOKUMENTE)
    values (s.LEGACY_REF, s.IS_DELETED, s.NAME, s.RSD_VESTIUCHETPONOMERUIDATESOZDANIYADOKUMENTA, s.RSD_VESTIUCHETUCHASNIKOVTENDERA, s.RSD_VYVESTIDOMISEKTSIYU, s.RSD_ISPOLZOVATDANNYESTRUKTURYOBEKTASTROITELSTVA, s.RSD_ISPOLZOVATKLASSIFIKATORRAZDELOV, s.RSD_OGRANICHENIEPOBYUDZHETUISPOLZOVAT, s.RSD_STATUSERP, s.RSD_TIPDOKUMENTA_ID, s.RSD_UCHETPODRYADCHIKOVVCHERNOMSPISKE, s.AVTOMATICHESKIVESTISOSTAVUCHASTNIKOVRABOCHEYGRUPPY, s.VARIANTPODPISANIYA_ID, s.VESTIUCHETVYDACHIIZARKHIVA, s.VESTIUCHETZAPROSOVKURERA, s.VESTIUCHETPOADRESATAM, s.VESTIUCHETPOKONTRAGENTAM, s.VESTIUCHETPONOMENKLATUREDEL, s.VESTIUCHETPOORGANIZATSIYAM, s.VESTIUCHETPOSTATYAMDDS, s.VESTIUCHETSTORON, s.VESTIUCHETTOVAROVIUSLUG, s.VKLYUCHENUCHETPONOMENKLATUREDEL, s.ZAPRETITSOZDANIEDOKUMENTOVNEPOSHABLONU, s.ISPOLZOVATPODPISANIE, s.ISPOLZOVATSROKISPOLNENIYA, s.ISPOLZOVATUTVERZHDENIE, s.ISPOLZOVATETAPYOBRABOTKIDOKUMENTA, s.KOMMENTARIY, s.NABORSVOYSTV_ID, s.NEOBKHODIMAPECHATSHTRIKHKODA, s.OBYAZATELENFAYLORIGINALA, s.OBYAZATELNOEZAPOLNENIERABOCHIKHGRUPPDOKUMENTOV, s.OBYAZATELNOEUKAZANIEOTVETSTVENNOGO, s.PODPISYVATREZOLYUTSIIEP, s.SROKISPOLNENIYA, s.UDALITNUMERATOR_ID, s.UDALITSPOSOBNUMERATSII_ID, s.UCHITYVATNEDEYSTVUYUSHCHIEDOKUMENTY, s.UCHITYVATSROKDEYSTVIYA, s.UCHITYVATSUMMUDOKUMENTA, s.YAVLYAETSYADOGOVOROM, s.YAVLYAETSYAKOMPLEKTOMDOKUMENTOV, s.RSD_PRIKREPLENIEFAYLOVSSHABLONA, s.RSD_UCHITYVATSTRUKTURUDOKUMENTOV, s.RSD_STRUKTURADOKUMENTA_ID, s.RSD_VESTIUCHETPOGRUPPAMDOMOV, s.RSD_VESTIUCHETKOMMENTARIEVKZADACHAMBP, s.RSD_VYVODITRABOCHUYUGRUPPUVDOKUMENTE);
commit;

-- Catalog.ПрофилиГруппДоступа → RSD_PROFILIGRUPPDOSTUPA
merge into RSD_PROFILIGRUPPDOSTUPA t using (
    select
        json_value(doc, '$.Ref_Key') as LEGACY_REF,
        case when lower(json_value(doc, '$."DeletionMark"')) = 'true' then true else false end as IS_DELETED,
        json_value(doc, '$."Description"') as NAME,
        json_value(doc, '$."ИдентификаторПоставляемыхДанных"') as IDENTIFIKATORPOSTAVLYAEMYKHDANNYKH,
        case when lower(json_value(doc, '$."ПоставляемыйПрофильИзменен"')) = 'true' then true else false end as POSTAVLYAEMYYPROFILIZMENEN,
        json_value(doc, '$."Комментарий"') as KOMMENTARIY
    from rsd_odata_raw where entity = 'Catalog.ПрофилиГруппДоступа'
) s on (t.legacy_ref = s.LEGACY_REF)
when matched then update set
        t.IS_DELETED = s.IS_DELETED,
        t.NAME = s.NAME,
        t.IDENTIFIKATORPOSTAVLYAEMYKHDANNYKH = s.IDENTIFIKATORPOSTAVLYAEMYKHDANNYKH,
        t.POSTAVLYAEMYYPROFILIZMENEN = s.POSTAVLYAEMYYPROFILIZMENEN,
        t.KOMMENTARIY = s.KOMMENTARIY
when not matched then insert (LEGACY_REF, IS_DELETED, NAME, IDENTIFIKATORPOSTAVLYAEMYKHDANNYKH, POSTAVLYAEMYYPROFILIZMENEN, KOMMENTARIY)
    values (s.LEGACY_REF, s.IS_DELETED, s.NAME, s.IDENTIFIKATORPOSTAVLYAEMYKHDANNYKH, s.POSTAVLYAEMYYPROFILIZMENEN, s.KOMMENTARIY);
commit;

-- Catalog.РабочиеГруппы → RSD_RABOCHIEGRUPPY
merge into RSD_RABOCHIEGRUPPY t using (
    select
        json_value(doc, '$.Ref_Key') as LEGACY_REF,
        case when lower(json_value(doc, '$."DeletionMark"')) = 'true' then true else false end as IS_DELETED,
        json_value(doc, '$."Description"') as NAME,
        json_value(doc, '$."Комментарий"') as KOMMENTARIY,
        (select tgt.id from RSD_POLZOVATELI tgt where tgt.legacy_ref = nullif(json_value(doc, '$."Ответственный_Key"'), '00000000-0000-0000-0000-000000000000')) as OTVETSTVENNYY_ID,
        case when lower(json_value(doc, '$."Недействительна"')) = 'true' then true else false end as NEDEYSTVITELNA
    from rsd_odata_raw where entity = 'Catalog.РабочиеГруппы'
) s on (t.legacy_ref = s.LEGACY_REF)
when matched then update set
        t.IS_DELETED = s.IS_DELETED,
        t.NAME = s.NAME,
        t.KOMMENTARIY = s.KOMMENTARIY,
        t.OTVETSTVENNYY_ID = s.OTVETSTVENNYY_ID,
        t.NEDEYSTVITELNA = s.NEDEYSTVITELNA
when not matched then insert (LEGACY_REF, IS_DELETED, NAME, KOMMENTARIY, OTVETSTVENNYY_ID, NEDEYSTVITELNA)
    values (s.LEGACY_REF, s.IS_DELETED, s.NAME, s.KOMMENTARIY, s.OTVETSTVENNYY_ID, s.NEDEYSTVITELNA);
commit;

-- Catalog.ТерриторииИПомещения → RSD_TERRITORIIIPOMESHCHENIYA
merge into RSD_TERRITORIIIPOMESHCHENIYA t using (
    select
        json_value(doc, '$.Ref_Key') as LEGACY_REF,
        case when lower(json_value(doc, '$."DeletionMark"')) = 'true' then true else false end as IS_DELETED,
        json_value(doc, '$."Code"') as CODE,
        json_value(doc, '$."Description"') as NAME,
        case when lower(json_value(doc, '$."БрониВводитОтветственный"')) = 'true' then true else false end as BRONIVVODITOTVETSTVENNYY,
        to_number(json_value(doc, '$."Вместимость"') default null on conversion error) as VMESTIMOST,
        case when lower(json_value(doc, '$."ДоступнаСхема"')) = 'true' then true else false end as DOSTUPNASKHEMA,
        case when lower(json_value(doc, '$."ДоступноБронирование"')) = 'true' then true else false end as DOSTUPNOBRONIROVANIE,
        json_value(doc, '$."Описание"') as OPISANIE,
        (select tgt.id from RSD_POLZOVATELI tgt where tgt.legacy_ref = nullif(json_value(doc, '$."Ответственный_Key"'), '00000000-0000-0000-0000-000000000000')) as OTVETSTVENNYY_ID,
        (select tgt.id from RSD_POLZOVATELI tgt where tgt.legacy_ref = nullif(json_value(doc, '$."ОтветственныйТехническоеОбеспечение_Key"'), '00000000-0000-0000-0000-000000000000')) as OTVETSTVENNYYTEKHNICHESKOEOBESPECHENIE_ID,
        (select tgt.id from RSD_POLZOVATELI tgt where tgt.legacy_ref = nullif(json_value(doc, '$."ОтветственныйХозяйственноеОбеспечение_Key"'), '00000000-0000-0000-0000-000000000000')) as OTVETSTVENNYYKHOZYAYSTVENNOEOBESPECHENIE_ID,
        json_value(doc, '$."ФайлФотографии"') as FAYLFOTOGRAFII
    from rsd_odata_raw where entity = 'Catalog.ТерриторииИПомещения'
) s on (t.legacy_ref = s.LEGACY_REF)
when matched then update set
        t.IS_DELETED = s.IS_DELETED,
        t.CODE = s.CODE,
        t.NAME = s.NAME,
        t.BRONIVVODITOTVETSTVENNYY = s.BRONIVVODITOTVETSTVENNYY,
        t.VMESTIMOST = s.VMESTIMOST,
        t.DOSTUPNASKHEMA = s.DOSTUPNASKHEMA,
        t.DOSTUPNOBRONIROVANIE = s.DOSTUPNOBRONIROVANIE,
        t.OPISANIE = s.OPISANIE,
        t.OTVETSTVENNYY_ID = s.OTVETSTVENNYY_ID,
        t.OTVETSTVENNYYTEKHNICHESKOEOBESPECHENIE_ID = s.OTVETSTVENNYYTEKHNICHESKOEOBESPECHENIE_ID,
        t.OTVETSTVENNYYKHOZYAYSTVENNOEOBESPECHENIE_ID = s.OTVETSTVENNYYKHOZYAYSTVENNOEOBESPECHENIE_ID,
        t.FAYLFOTOGRAFII = s.FAYLFOTOGRAFII
when not matched then insert (LEGACY_REF, IS_DELETED, CODE, NAME, BRONIVVODITOTVETSTVENNYY, VMESTIMOST, DOSTUPNASKHEMA, DOSTUPNOBRONIROVANIE, OPISANIE, OTVETSTVENNYY_ID, OTVETSTVENNYYTEKHNICHESKOEOBESPECHENIE_ID, OTVETSTVENNYYKHOZYAYSTVENNOEOBESPECHENIE_ID, FAYLFOTOGRAFII)
    values (s.LEGACY_REF, s.IS_DELETED, s.CODE, s.NAME, s.BRONIVVODITOTVETSTVENNYY, s.VMESTIMOST, s.DOSTUPNASKHEMA, s.DOSTUPNOBRONIROVANIE, s.OPISANIE, s.OTVETSTVENNYY_ID, s.OTVETSTVENNYYTEKHNICHESKOEOBESPECHENIE_ID, s.OTVETSTVENNYYKHOZYAYSTVENNOEOBESPECHENIE_ID, s.FAYLFOTOGRAFII);
commit;

-- Catalog.ПапкиВнутреннихДокументов → RSD_PAPKIVNUTRENNIKHDOKUMENTOV
merge into RSD_PAPKIVNUTRENNIKHDOKUMENTOV t using (
    select
        json_value(doc, '$.Ref_Key') as LEGACY_REF,
        case when lower(json_value(doc, '$."DeletionMark"')) = 'true' then true else false end as IS_DELETED,
        json_value(doc, '$."Code"') as CODE,
        json_value(doc, '$."Description"') as NAME,
        json_value(doc, '$."Описание"') as OPISANIE,
        (select tgt.id from RSD_POLZOVATELI tgt where tgt.legacy_ref = nullif(json_value(doc, '$."Ответственный_Key"'), '00000000-0000-0000-0000-000000000000')) as OTVETSTVENNYY_ID,
        to_timestamp(substr(json_value(doc, '$."ДатаСоздания"'), 1, 19), 'YYYY-MM-DD"T"HH24:MI:SS') as DATASOZDANIYA
    from rsd_odata_raw where entity = 'Catalog.ПапкиВнутреннихДокументов'
) s on (t.legacy_ref = s.LEGACY_REF)
when matched then update set
        t.IS_DELETED = s.IS_DELETED,
        t.CODE = s.CODE,
        t.NAME = s.NAME,
        t.OPISANIE = s.OPISANIE,
        t.OTVETSTVENNYY_ID = s.OTVETSTVENNYY_ID,
        t.DATASOZDANIYA = s.DATASOZDANIYA
when not matched then insert (LEGACY_REF, IS_DELETED, CODE, NAME, OPISANIE, OTVETSTVENNYY_ID, DATASOZDANIYA)
    values (s.LEGACY_REF, s.IS_DELETED, s.CODE, s.NAME, s.OPISANIE, s.OTVETSTVENNYY_ID, s.DATASOZDANIYA);
commit;

-- Catalog.УсловияЗадач → RSD_USLOVIYAZADACH
merge into RSD_USLOVIYAZADACH t using (
    select
        json_value(doc, '$.Ref_Key') as LEGACY_REF,
        case when lower(json_value(doc, '$."DeletionMark"')) = 'true' then true else false end as IS_DELETED,
        json_value(doc, '$."Code"') as CODE,
        json_value(doc, '$."Description"') as NAME,
        json_value(doc, '$."ВыражениеУсловия"') as VYRAZHENIEUSLOVIYA,
        json_value(doc, '$."НастройкаКомбинацииУсловий"') as NASTROYKAKOMBINATSIIUSLOVIY,
        json_value(doc, '$."НастройкаУсловия"') as NASTROYKAUSLOVIYA,
        (select id from rsd_enums where enum_type = 'СпособыЗаданияУсловия' and value_key = json_value(doc, '$."СпособЗаданияУсловия"')) as SPOSOBZADANIYAUSLOVIYA_ID
    from rsd_odata_raw where entity = 'Catalog.УсловияЗадач'
) s on (t.legacy_ref = s.LEGACY_REF)
when matched then update set
        t.IS_DELETED = s.IS_DELETED,
        t.CODE = s.CODE,
        t.NAME = s.NAME,
        t.VYRAZHENIEUSLOVIYA = s.VYRAZHENIEUSLOVIYA,
        t.NASTROYKAKOMBINATSIIUSLOVIY = s.NASTROYKAKOMBINATSIIUSLOVIY,
        t.NASTROYKAUSLOVIYA = s.NASTROYKAUSLOVIYA,
        t.SPOSOBZADANIYAUSLOVIYA_ID = s.SPOSOBZADANIYAUSLOVIYA_ID
when not matched then insert (LEGACY_REF, IS_DELETED, CODE, NAME, VYRAZHENIEUSLOVIYA, NASTROYKAKOMBINATSIIUSLOVIY, NASTROYKAUSLOVIYA, SPOSOBZADANIYAUSLOVIYA_ID)
    values (s.LEGACY_REF, s.IS_DELETED, s.CODE, s.NAME, s.VYRAZHENIEUSLOVIYA, s.NASTROYKAKOMBINATSIIUSLOVIY, s.NASTROYKAUSLOVIYA, s.SPOSOBZADANIYAUSLOVIYA_ID);
commit;

-- Catalog.ВидыИсходящихДокументов → RSD_VIDYISKHODYASHCHIKHDOKUMENTOV
merge into RSD_VIDYISKHODYASHCHIKHDOKUMENTOV t using (
    select
        json_value(doc, '$.Ref_Key') as LEGACY_REF,
        case when lower(json_value(doc, '$."DeletionMark"')) = 'true' then true else false end as IS_DELETED,
        json_value(doc, '$."Description"') as NAME,
        case when lower(json_value(doc, '$."АвтоматическиВестиСоставУчастниковРабочейГруппы"')) = 'true' then true else false end as AVTOMATICHESKIVESTISOSTAVUCHASTNIKOVRABOCHEYGRUPPY,
        case when lower(json_value(doc, '$."ВестиУчетПоНоменклатуреДел"')) = 'true' then true else false end as VESTIUCHETPONOMENKLATUREDEL,
        case when lower(json_value(doc, '$."ВключенУчетПоНоменклатуреДел"')) = 'true' then true else false end as VKLYUCHENUCHETPONOMENKLATUREDEL,
        case when lower(json_value(doc, '$."ЗапретитьСозданиеДокументовНеПоШаблону"')) = 'true' then true else false end as ZAPRETITSOZDANIEDOKUMENTOVNEPOSHABLONU,
        case when lower(json_value(doc, '$."ИспользоватьСрокИсполнения"')) = 'true' then true else false end as ISPOLZOVATSROKISPOLNENIYA,
        case when lower(json_value(doc, '$."ИспользоватьЭтапыОбработкиДокумента"')) = 'true' then true else false end as ISPOLZOVATETAPYOBRABOTKIDOKUMENTA,
        json_value(doc, '$."Комментарий"') as KOMMENTARIY,
        cast(null as number) as NABORSVOYSTV_ID,
        case when lower(json_value(doc, '$."НеобходимаПечатьШтрихкода"')) = 'true' then true else false end as NEOBKHODIMAPECHATSHTRIKHKODA,
        (select tgt.id from RSD_NUMERATORY tgt where tgt.legacy_ref = nullif(json_value(doc, '$."УдалитьНумератор_Key"'), '00000000-0000-0000-0000-000000000000')) as UDALITNUMERATOR_ID,
        case when lower(json_value(doc, '$."ОбязательноеЗаполнениеРабочихГруппДокументов"')) = 'true' then true else false end as OBYAZATELNOEZAPOLNENIERABOCHIKHGRUPPDOKUMENTOV,
        case when lower(json_value(doc, '$."ОбязателенФайлОригинала"')) = 'true' then true else false end as OBYAZATELENFAYLORIGINALA,
        case when lower(json_value(doc, '$."ОбязательноеУказаниеОтветственного"')) = 'true' then true else false end as OBYAZATELNOEUKAZANIEOTVETSTVENNOGO,
        (select id from rsd_enums where enum_type = 'СпособыНумерации' and value_key = json_value(doc, '$."УдалитьСпособНумерации"')) as UDALITSPOSOBNUMERATSII_ID,
        to_number(json_value(doc, '$."СрокИсполнения"') default null on conversion error) as SROKISPOLNENIYA,
        case when lower(json_value(doc, '$."УчитыватьВходящийНомерИДатуПолучателя"')) = 'true' then true else false end as UCHITYVATVKHODYASHCHIYNOMERIDATUPOLUCHATELYA,
        case when lower(json_value(doc, '$."УчитыватьСуммуДокумента"')) = 'true' then true else false end as UCHITYVATSUMMUDOKUMENTA,
        case when lower(json_value(doc, '$."RSD_СтатусERP"')) = 'true' then true else false end as RSD_STATUSERP,
        case when lower(json_value(doc, '$."RSD_ВестиУчетПоНомеруИДатеСозданияДокумента"')) = 'true' then true else false end as RSD_VESTIUCHETPONOMERUIDATESOZDANIYADOKUMENTA,
        (select id from rsd_enums where enum_type = 'RSD_ТипДокумента' and value_key = json_value(doc, '$."RSD_ТипДокумента"')) as RSD_TIPDOKUMENTA_ID,
        case when lower(json_value(doc, '$."RSD_ВестиУчетПоЮридическомуЛицу"')) = 'true' then true else false end as RSD_VESTIUCHETPOYURIDICHESKOMULITSU,
        case when lower(json_value(doc, '$."RSD_ПрикреплениеФайловСШаблона"')) = 'true' then true else false end as RSD_PRIKREPLENIEFAYLOVSSHABLONA
    from rsd_odata_raw where entity = 'Catalog.ВидыИсходящихДокументов'
) s on (t.legacy_ref = s.LEGACY_REF)
when matched then update set
        t.IS_DELETED = s.IS_DELETED,
        t.NAME = s.NAME,
        t.AVTOMATICHESKIVESTISOSTAVUCHASTNIKOVRABOCHEYGRUPPY = s.AVTOMATICHESKIVESTISOSTAVUCHASTNIKOVRABOCHEYGRUPPY,
        t.VESTIUCHETPONOMENKLATUREDEL = s.VESTIUCHETPONOMENKLATUREDEL,
        t.VKLYUCHENUCHETPONOMENKLATUREDEL = s.VKLYUCHENUCHETPONOMENKLATUREDEL,
        t.ZAPRETITSOZDANIEDOKUMENTOVNEPOSHABLONU = s.ZAPRETITSOZDANIEDOKUMENTOVNEPOSHABLONU,
        t.ISPOLZOVATSROKISPOLNENIYA = s.ISPOLZOVATSROKISPOLNENIYA,
        t.ISPOLZOVATETAPYOBRABOTKIDOKUMENTA = s.ISPOLZOVATETAPYOBRABOTKIDOKUMENTA,
        t.KOMMENTARIY = s.KOMMENTARIY,
        t.NABORSVOYSTV_ID = s.NABORSVOYSTV_ID,
        t.NEOBKHODIMAPECHATSHTRIKHKODA = s.NEOBKHODIMAPECHATSHTRIKHKODA,
        t.UDALITNUMERATOR_ID = s.UDALITNUMERATOR_ID,
        t.OBYAZATELNOEZAPOLNENIERABOCHIKHGRUPPDOKUMENTOV = s.OBYAZATELNOEZAPOLNENIERABOCHIKHGRUPPDOKUMENTOV,
        t.OBYAZATELENFAYLORIGINALA = s.OBYAZATELENFAYLORIGINALA,
        t.OBYAZATELNOEUKAZANIEOTVETSTVENNOGO = s.OBYAZATELNOEUKAZANIEOTVETSTVENNOGO,
        t.UDALITSPOSOBNUMERATSII_ID = s.UDALITSPOSOBNUMERATSII_ID,
        t.SROKISPOLNENIYA = s.SROKISPOLNENIYA,
        t.UCHITYVATVKHODYASHCHIYNOMERIDATUPOLUCHATELYA = s.UCHITYVATVKHODYASHCHIYNOMERIDATUPOLUCHATELYA,
        t.UCHITYVATSUMMUDOKUMENTA = s.UCHITYVATSUMMUDOKUMENTA,
        t.RSD_STATUSERP = s.RSD_STATUSERP,
        t.RSD_VESTIUCHETPONOMERUIDATESOZDANIYADOKUMENTA = s.RSD_VESTIUCHETPONOMERUIDATESOZDANIYADOKUMENTA,
        t.RSD_TIPDOKUMENTA_ID = s.RSD_TIPDOKUMENTA_ID,
        t.RSD_VESTIUCHETPOYURIDICHESKOMULITSU = s.RSD_VESTIUCHETPOYURIDICHESKOMULITSU,
        t.RSD_PRIKREPLENIEFAYLOVSSHABLONA = s.RSD_PRIKREPLENIEFAYLOVSSHABLONA
when not matched then insert (LEGACY_REF, IS_DELETED, NAME, AVTOMATICHESKIVESTISOSTAVUCHASTNIKOVRABOCHEYGRUPPY, VESTIUCHETPONOMENKLATUREDEL, VKLYUCHENUCHETPONOMENKLATUREDEL, ZAPRETITSOZDANIEDOKUMENTOVNEPOSHABLONU, ISPOLZOVATSROKISPOLNENIYA, ISPOLZOVATETAPYOBRABOTKIDOKUMENTA, KOMMENTARIY, NABORSVOYSTV_ID, NEOBKHODIMAPECHATSHTRIKHKODA, UDALITNUMERATOR_ID, OBYAZATELNOEZAPOLNENIERABOCHIKHGRUPPDOKUMENTOV, OBYAZATELENFAYLORIGINALA, OBYAZATELNOEUKAZANIEOTVETSTVENNOGO, UDALITSPOSOBNUMERATSII_ID, SROKISPOLNENIYA, UCHITYVATVKHODYASHCHIYNOMERIDATUPOLUCHATELYA, UCHITYVATSUMMUDOKUMENTA, RSD_STATUSERP, RSD_VESTIUCHETPONOMERUIDATESOZDANIYADOKUMENTA, RSD_TIPDOKUMENTA_ID, RSD_VESTIUCHETPOYURIDICHESKOMULITSU, RSD_PRIKREPLENIEFAYLOVSSHABLONA)
    values (s.LEGACY_REF, s.IS_DELETED, s.NAME, s.AVTOMATICHESKIVESTISOSTAVUCHASTNIKOVRABOCHEYGRUPPY, s.VESTIUCHETPONOMENKLATUREDEL, s.VKLYUCHENUCHETPONOMENKLATUREDEL, s.ZAPRETITSOZDANIEDOKUMENTOVNEPOSHABLONU, s.ISPOLZOVATSROKISPOLNENIYA, s.ISPOLZOVATETAPYOBRABOTKIDOKUMENTA, s.KOMMENTARIY, s.NABORSVOYSTV_ID, s.NEOBKHODIMAPECHATSHTRIKHKODA, s.UDALITNUMERATOR_ID, s.OBYAZATELNOEZAPOLNENIERABOCHIKHGRUPPDOKUMENTOV, s.OBYAZATELENFAYLORIGINALA, s.OBYAZATELNOEUKAZANIEOTVETSTVENNOGO, s.UDALITSPOSOBNUMERATSII_ID, s.SROKISPOLNENIYA, s.UCHITYVATVKHODYASHCHIYNOMERIDATUPOLUCHATELYA, s.UCHITYVATSUMMUDOKUMENTA, s.RSD_STATUSERP, s.RSD_VESTIUCHETPONOMERUIDATESOZDANIYADOKUMENTA, s.RSD_TIPDOKUMENTA_ID, s.RSD_VESTIUCHETPOYURIDICHESKOMULITSU, s.RSD_PRIKREPLENIEFAYLOVSSHABLONA);
commit;

-- Catalog.Нумераторы → RSD_NUMERATORY
merge into RSD_NUMERATORY t using (
    select
        json_value(doc, '$.Ref_Key') as LEGACY_REF,
        case when lower(json_value(doc, '$."DeletionMark"')) = 'true' then true else false end as IS_DELETED,
        json_value(doc, '$."Description"') as NAME,
        (select id from rsd_enums where enum_type = 'ПериодичностьНумераторов' and value_key = json_value(doc, '$."Периодичность"')) as PERIODICHNOST_ID,
        json_value(doc, '$."ФорматНомера"') as FORMATNOMERA,
        case when lower(json_value(doc, '$."НезависимаяНумерацияПоОрганизациям"')) = 'true' then true else false end as NEZAVISIMAYANUMERATSIYAPOORGANIZATSIYAM,
        case when lower(json_value(doc, '$."НезависимаяНумерацияПоСвязанномуДокументу"')) = 'true' then true else false end as NEZAVISIMAYANUMERATSIYAPOSVYAZANNOMUDOKUMENTU,
        case when lower(json_value(doc, '$."НезависимаяНумерацияПоПодразделению"')) = 'true' then true else false end as NEZAVISIMAYANUMERATSIYAPOPODRAZDELENIYU,
        case when lower(json_value(doc, '$."НезависимаяНумерацияПоПроекту"')) = 'true' then true else false end as NEZAVISIMAYANUMERATSIYAPOPROEKTU,
        case when lower(json_value(doc, '$."НезависимаяНумерацияПоВопросуДеятельности"')) = 'true' then true else false end as NEZAVISIMAYANUMERATSIYAPOVOPROSUDEYATELNOSTI,
        case when lower(json_value(doc, '$."НезависимаяНумерацияПоВидуДокумента"')) = 'true' then true else false end as NEZAVISIMAYANUMERATSIYAPOVIDUDOKUMENTA,
        cast(null as number) as TIPSVYAZI_ID,
        json_value(doc, '$."Пример"') as PRIMER
    from rsd_odata_raw where entity = 'Catalog.Нумераторы'
) s on (t.legacy_ref = s.LEGACY_REF)
when matched then update set
        t.IS_DELETED = s.IS_DELETED,
        t.NAME = s.NAME,
        t.PERIODICHNOST_ID = s.PERIODICHNOST_ID,
        t.FORMATNOMERA = s.FORMATNOMERA,
        t.NEZAVISIMAYANUMERATSIYAPOORGANIZATSIYAM = s.NEZAVISIMAYANUMERATSIYAPOORGANIZATSIYAM,
        t.NEZAVISIMAYANUMERATSIYAPOSVYAZANNOMUDOKUMENTU = s.NEZAVISIMAYANUMERATSIYAPOSVYAZANNOMUDOKUMENTU,
        t.NEZAVISIMAYANUMERATSIYAPOPODRAZDELENIYU = s.NEZAVISIMAYANUMERATSIYAPOPODRAZDELENIYU,
        t.NEZAVISIMAYANUMERATSIYAPOPROEKTU = s.NEZAVISIMAYANUMERATSIYAPOPROEKTU,
        t.NEZAVISIMAYANUMERATSIYAPOVOPROSUDEYATELNOSTI = s.NEZAVISIMAYANUMERATSIYAPOVOPROSUDEYATELNOSTI,
        t.NEZAVISIMAYANUMERATSIYAPOVIDUDOKUMENTA = s.NEZAVISIMAYANUMERATSIYAPOVIDUDOKUMENTA,
        t.TIPSVYAZI_ID = s.TIPSVYAZI_ID,
        t.PRIMER = s.PRIMER
when not matched then insert (LEGACY_REF, IS_DELETED, NAME, PERIODICHNOST_ID, FORMATNOMERA, NEZAVISIMAYANUMERATSIYAPOORGANIZATSIYAM, NEZAVISIMAYANUMERATSIYAPOSVYAZANNOMUDOKUMENTU, NEZAVISIMAYANUMERATSIYAPOPODRAZDELENIYU, NEZAVISIMAYANUMERATSIYAPOPROEKTU, NEZAVISIMAYANUMERATSIYAPOVOPROSUDEYATELNOSTI, NEZAVISIMAYANUMERATSIYAPOVIDUDOKUMENTA, TIPSVYAZI_ID, PRIMER)
    values (s.LEGACY_REF, s.IS_DELETED, s.NAME, s.PERIODICHNOST_ID, s.FORMATNOMERA, s.NEZAVISIMAYANUMERATSIYAPOORGANIZATSIYAM, s.NEZAVISIMAYANUMERATSIYAPOSVYAZANNOMUDOKUMENTU, s.NEZAVISIMAYANUMERATSIYAPOPODRAZDELENIYU, s.NEZAVISIMAYANUMERATSIYAPOPROEKTU, s.NEZAVISIMAYANUMERATSIYAPOVOPROSUDEYATELNOSTI, s.NEZAVISIMAYANUMERATSIYAPOVIDUDOKUMENTA, s.TIPSVYAZI_ID, s.PRIMER);
commit;

-- Catalog.ПапкиФорума → RSD_PAPKIFORUMA
merge into RSD_PAPKIFORUMA t using (
    select
        json_value(doc, '$.Ref_Key') as LEGACY_REF,
        case when lower(json_value(doc, '$."DeletionMark"')) = 'true' then true else false end as IS_DELETED,
        json_value(doc, '$."Code"') as CODE,
        json_value(doc, '$."Description"') as NAME,
        json_value(doc, '$."Описание"') as OPISANIE,
        (select tgt.id from RSD_POLZOVATELI tgt where tgt.legacy_ref = nullif(json_value(doc, '$."Ответственный_Key"'), '00000000-0000-0000-0000-000000000000')) as OTVETSTVENNYY_ID,
        to_timestamp(substr(json_value(doc, '$."ДатаСоздания"'), 1, 19), 'YYYY-MM-DD"T"HH24:MI:SS') as DATASOZDANIYA
    from rsd_odata_raw where entity = 'Catalog.ПапкиФорума'
) s on (t.legacy_ref = s.LEGACY_REF)
when matched then update set
        t.IS_DELETED = s.IS_DELETED,
        t.CODE = s.CODE,
        t.NAME = s.NAME,
        t.OPISANIE = s.OPISANIE,
        t.OTVETSTVENNYY_ID = s.OTVETSTVENNYY_ID,
        t.DATASOZDANIYA = s.DATASOZDANIYA
when not matched then insert (LEGACY_REF, IS_DELETED, CODE, NAME, OPISANIE, OTVETSTVENNYY_ID, DATASOZDANIYA)
    values (s.LEGACY_REF, s.IS_DELETED, s.CODE, s.NAME, s.OPISANIE, s.OTVETSTVENNYY_ID, s.DATASOZDANIYA);
commit;

-- Catalog.КатегорииДанных → RSD_KATEGORIIDANNYKH
merge into RSD_KATEGORIIDANNYKH t using (
    select
        json_value(doc, '$.Ref_Key') as LEGACY_REF,
        case when lower(json_value(doc, '$."DeletionMark"')) = 'true' then true else false end as IS_DELETED,
        json_value(doc, '$."Code"') as CODE,
        json_value(doc, '$."Description"') as NAME,
        json_value(doc, '$."Описание"') as OPISANIE,
        (select tgt.id from RSD_POLZOVATELI tgt where tgt.legacy_ref = nullif(json_value(doc, '$."Автор_Key"'), '00000000-0000-0000-0000-000000000000')) as AVTOR_ID,
        case when lower(json_value(doc, '$."Персональная"')) = 'true' then true else false end as PERSONALNAYA,
        to_timestamp(substr(json_value(doc, '$."ДатаСоздания"'), 1, 19), 'YYYY-MM-DD"T"HH24:MI:SS') as DATASOZDANIYA
    from rsd_odata_raw where entity = 'Catalog.КатегорииДанных'
) s on (t.legacy_ref = s.LEGACY_REF)
when matched then update set
        t.IS_DELETED = s.IS_DELETED,
        t.CODE = s.CODE,
        t.NAME = s.NAME,
        t.OPISANIE = s.OPISANIE,
        t.AVTOR_ID = s.AVTOR_ID,
        t.PERSONALNAYA = s.PERSONALNAYA,
        t.DATASOZDANIYA = s.DATASOZDANIYA
when not matched then insert (LEGACY_REF, IS_DELETED, CODE, NAME, OPISANIE, AVTOR_ID, PERSONALNAYA, DATASOZDANIYA)
    values (s.LEGACY_REF, s.IS_DELETED, s.CODE, s.NAME, s.OPISANIE, s.AVTOR_ID, s.PERSONALNAYA, s.DATASOZDANIYA);
commit;

-- Catalog.Должности → RSD_DOLZHNOSTI
merge into RSD_DOLZHNOSTI t using (
    select
        json_value(doc, '$.Ref_Key') as LEGACY_REF,
        case when lower(json_value(doc, '$."DeletionMark"')) = 'true' then true else false end as IS_DELETED,
        json_value(doc, '$."Description"') as NAME
    from rsd_odata_raw where entity = 'Catalog.Должности'
) s on (t.legacy_ref = s.LEGACY_REF)
when matched then update set
        t.IS_DELETED = s.IS_DELETED,
        t.NAME = s.NAME
when not matched then insert (LEGACY_REF, IS_DELETED, NAME)
    values (s.LEGACY_REF, s.IS_DELETED, s.NAME);
commit;

-- Catalog.ШаблоныТекстов → RSD_SHABLONYTEKSTOV
merge into RSD_SHABLONYTEKSTOV t using (
    select
        json_value(doc, '$.Ref_Key') as LEGACY_REF,
        case when lower(json_value(doc, '$."DeletionMark"')) = 'true' then true else false end as IS_DELETED,
        json_value(doc, '$."Code"') as CODE,
        json_value(doc, '$."Description"') as NAME,
        json_value(doc, '$."Шаблон"') as SHABLON,
        (select tgt.id from RSD_POLZOVATELI tgt where tgt.legacy_ref = nullif(json_value(doc, '$."Автор_Key"'), '00000000-0000-0000-0000-000000000000')) as AVTOR_ID,
        case when lower(json_value(doc, '$."ОбщийШаблон"')) = 'true' then true else false end as OBSHCHIYSHABLON,
        (select id from rsd_enums where enum_type = 'ОбластиПримененияШаблоновТекстов' and value_key = json_value(doc, '$."ОбластьПрименения"')) as OBLASTPRIMENENIYA_ID,
        (select id from rsd_enums where enum_type = 'ТипыТекстовПочтовыхСообщений' and value_key = json_value(doc, '$."ТипТекста"')) as TIPTEKSTA_ID
    from rsd_odata_raw where entity = 'Catalog.ШаблоныТекстов'
) s on (t.legacy_ref = s.LEGACY_REF)
when matched then update set
        t.IS_DELETED = s.IS_DELETED,
        t.CODE = s.CODE,
        t.NAME = s.NAME,
        t.SHABLON = s.SHABLON,
        t.AVTOR_ID = s.AVTOR_ID,
        t.OBSHCHIYSHABLON = s.OBSHCHIYSHABLON,
        t.OBLASTPRIMENENIYA_ID = s.OBLASTPRIMENENIYA_ID,
        t.TIPTEKSTA_ID = s.TIPTEKSTA_ID
when not matched then insert (LEGACY_REF, IS_DELETED, CODE, NAME, SHABLON, AVTOR_ID, OBSHCHIYSHABLON, OBLASTPRIMENENIYA_ID, TIPTEKSTA_ID)
    values (s.LEGACY_REF, s.IS_DELETED, s.CODE, s.NAME, s.SHABLON, s.AVTOR_ID, s.OBSHCHIYSHABLON, s.OBLASTPRIMENENIYA_ID, s.TIPTEKSTA_ID);
commit;

-- Catalog.ГруппыДоступаКонтрагентов → RSD_GRUPPYDOSTUPAKONTRAGENTOV
merge into RSD_GRUPPYDOSTUPAKONTRAGENTOV t using (
    select
        json_value(doc, '$.Ref_Key') as LEGACY_REF,
        case when lower(json_value(doc, '$."DeletionMark"')) = 'true' then true else false end as IS_DELETED,
        json_value(doc, '$."Code"') as CODE,
        json_value(doc, '$."Description"') as NAME,
        json_value(doc, '$."Комментарий"') as KOMMENTARIY,
        (select tgt.id from RSD_POLZOVATELI tgt where tgt.legacy_ref = nullif(json_value(doc, '$."Ответственный_Key"'), '00000000-0000-0000-0000-000000000000')) as OTVETSTVENNYY_ID
    from rsd_odata_raw where entity = 'Catalog.ГруппыДоступаКонтрагентов'
) s on (t.legacy_ref = s.LEGACY_REF)
when matched then update set
        t.IS_DELETED = s.IS_DELETED,
        t.CODE = s.CODE,
        t.NAME = s.NAME,
        t.KOMMENTARIY = s.KOMMENTARIY,
        t.OTVETSTVENNYY_ID = s.OTVETSTVENNYY_ID
when not matched then insert (LEGACY_REF, IS_DELETED, CODE, NAME, KOMMENTARIY, OTVETSTVENNYY_ID)
    values (s.LEGACY_REF, s.IS_DELETED, s.CODE, s.NAME, s.KOMMENTARIY, s.OTVETSTVENNYY_ID);
commit;

-- Catalog.ГрафикиРаботы → RSD_GRAFIKIRABOTY
merge into RSD_GRAFIKIRABOTY t using (
    select
        json_value(doc, '$.Ref_Key') as LEGACY_REF,
        case when lower(json_value(doc, '$."DeletionMark"')) = 'true' then true else false end as IS_DELETED,
        json_value(doc, '$."Code"') as CODE,
        json_value(doc, '$."Description"') as NAME,
        cast(null as number) as KALENDAR_ID,
        to_number(json_value(doc, '$."КоличествоРабочихЧасовВДне"') default null on conversion error) as KOLICHESTVORABOCHIKHCHASOVVDNE,
        to_number(json_value(doc, '$."КоличествоРабочихЧасовВНеделе"') default null on conversion error) as KOLICHESTVORABOCHIKHCHASOVVNEDELE,
        to_number(json_value(doc, '$."КоличествоРабочихДнейВМесяце"') default null on conversion error) as KOLICHESTVORABOCHIKHDNEYVMESYATSE
    from rsd_odata_raw where entity = 'Catalog.ГрафикиРаботы'
) s on (t.legacy_ref = s.LEGACY_REF)
when matched then update set
        t.IS_DELETED = s.IS_DELETED,
        t.CODE = s.CODE,
        t.NAME = s.NAME,
        t.KALENDAR_ID = s.KALENDAR_ID,
        t.KOLICHESTVORABOCHIKHCHASOVVDNE = s.KOLICHESTVORABOCHIKHCHASOVVDNE,
        t.KOLICHESTVORABOCHIKHCHASOVVNEDELE = s.KOLICHESTVORABOCHIKHCHASOVVNEDELE,
        t.KOLICHESTVORABOCHIKHDNEYVMESYATSE = s.KOLICHESTVORABOCHIKHDNEYVMESYATSE
when not matched then insert (LEGACY_REF, IS_DELETED, CODE, NAME, KALENDAR_ID, KOLICHESTVORABOCHIKHCHASOVVDNE, KOLICHESTVORABOCHIKHCHASOVVNEDELE, KOLICHESTVORABOCHIKHDNEYVMESYATSE)
    values (s.LEGACY_REF, s.IS_DELETED, s.CODE, s.NAME, s.KALENDAR_ID, s.KOLICHESTVORABOCHIKHCHASOVVDNE, s.KOLICHESTVORABOCHIKHCHASOVVNEDELE, s.KOLICHESTVORABOCHIKHDNEYVMESYATSE);
commit;
