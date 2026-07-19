# Батч регістрів відомостей — хвилі 2,3,4

Механічно згенеровано `bas2apex/tools/gen_register_batch.py` — не редагувати руками.
Імена таблиць/колонок транслітеровані (латиниця), підписи (uk) — у COMMENT.

Виключені: —.

## Підсумок
- Регістрів (таблиць): **99**; колонок: 552
- Періодичних (VALID_FROM): 7; зрізів останніх (VIEW): 7
- Підпорядкованих регістратору: 0; без вимірів: 0
- FK встановлено: 109; відкладено (EXTERNAL/немає на стенді): 58
- Композитних ознак: 24; нетипізованих вимірів (поліморфний ключ): 28; нетипізованих ресурсів (drop): 5

## §9 — на ревю архітектора
- RSD_OSHIBKIRASSYLKISOOBSHCHENII_UCHASNIKAMTENDERBOTA.SOBYTIE (Событие) — композитний resource: SOBYTIE_REF_TYPE/SOBYTIE_REF_ID, без FK
- RSD_OSHIBKIRASSYLKISOOBSHCHENII_UCHASNIKAMTENDERBOTA: періодичний (Second) → VIEW RSD_OSHIBKIRASSYLKISOOBSHCHENII_UCHASNIKAMTENDERBOTA_SREZ_V (зріз останніх, срез последних: PARTITION BY CHAT_ID ORDER BY VALID_FROM DESC). «Питання підсумків»: view (дефолт) / матеріалізована таблиця / без зрізу → архітектор
- RSD_PODPISKANAOBNOVLENIYAPOVIDURABOT: періодичний (Second) → VIEW RSD_PODPISKANAOBNOVLENIYAPOVIDURABOT_SREZ_V (зріз останніх, срез последних: PARTITION BY CHAT_ID,STATYADDS_ID ORDER BY VALID_FROM DESC). «Питання підсумків»: view (дефолт) / матеріалізована таблиця / без зрізу → архітектор
- RSD_PROTOKOLISPOLZOVANIYADOKUMENTATSII.PREDMET (Предмет) — нетипізований ВИМІР (поліморфний, у ключі): PREDMET_REF_TYPE/PREDMET_REF_ID, без FK → рішення архітектора
- RSD_REGISTROTPRAVKIRASSYLOKTELEGRAM: періодичний (Second) → VIEW RSD_REGISTROTPRAVKIRASSYLOKTELEGRAM_SREZ_V (зріз останніх, срез последних: PARTITION BY TIPRASSYLKI_ID,CHAT_ID,GUID ORDER BY VALID_FROM DESC). «Питання підсумків»: view (дефолт) / матеріалізована таблиця / без зрізу → архітектор
- RSD_VERSIIOBEKTOV.OBEKT (Объект) — нетипізований ВИМІР (поліморфний, у ключі): OBEKT_REF_TYPE/OBEKT_REF_ID, без FK → рішення архітектора
- RSD_VERSIIOBEKTOV.AVTORVERSII (АвторВерсии) — композитний attribute: AVTORVERSII_REF_TYPE/AVTORVERSII_REF_ID, без FK
- RSD_DANNYEOBRABOTANNYEVTSENTRALNOMUZLERIB.UZELPLANAOBMENA (УзелПланаОбмена) — нетипізований ВИМІР (поліморфний, у ключі): UZELPLANAOBMENA_REF_TYPE/UZELPLANAOBMENA_REF_ID, без FK → рішення архітектора
- RSD_DANNYEOBRABOTANNYEVTSENTRALNOMUZLERIB.DANNYE (Данные) — нетипізований ВИМІР (поліморфний, у ключі): DANNYE_REF_TYPE/DANNYE_REF_ID, без FK → рішення архітектора
- RSD_DOKUMENTYFIZICHESKIKHLITS: періодичний (Day) → VIEW RSD_DOKUMENTYFIZICHESKIKHLITS_SREZ_V (зріз останніх, срез последних: PARTITION BY FIZLITSO_ID,VIDDOKUMENTA_ID ORDER BY VALID_FROM DESC). «Питання підсумків»: view (дефолт) / матеріалізована таблиця / без зрізу → архітектор
- RSD_DOPOLNITELNYESVEDENIYA.OBEKT (Объект) — нетипізований ВИМІР (поліморфний, у ключі): OBEKT_REF_TYPE/OBEKT_REF_ID, без FK → рішення архітектора
- RSD_DOPOLNITELNYESVEDENIYA.ZNACHENIE (Значение) — нетипізований resource, колонку не створено
- RSD_ZAMERYVREMENI.DATAOKONCHANIYA (ДатаОкончания) — композитний attribute: DATAOKONCHANIYA_REF_TYPE/DATAOKONCHANIYA_REF_ID, без FK
- RSD_ZAMERYVREMENITEKHNOLOGICHESKIE.DATAOKONCHANIYA (ДатаОкончания) — композитний attribute: DATAOKONCHANIYA_REF_TYPE/DATAOKONCHANIYA_REF_ID, без FK
- RSD_ZAPROSYRAZRESHENII_NAISPOLZOVANIEVNESHNIKHRESURSOV.BEZOPASNYYREZHIM (БезопасныйРежим) — нетипізований resource, колонку не створено
- RSD_ZNACHENIYAPOKAZATELEI_RABOTYPOLZOVATELYA.TIPPOKAZATELYARABOTY (ТипПоказателяРаботы) — композитний dimension: TIPPOKAZATELYARABOTY_REF_TYPE/TIPPOKAZATELYARABOTY_REF_ID, без FK
- RSD_ZNACHENIYAPOKAZATELEI_RABOTYPOLZOVATELYA: періодичний (Second) → VIEW RSD_ZNACHENIYAPOKAZATELEI_RABOTYPOLZOVATELYA_SREZ_V (зріз останніх, срез последних: PARTITION BY POLZOVATEL_ID,TIPPOKAZATELYARABOTY_REF_TYPE,TIPPOKAZATELYARABOTY_REF_ID ORDER BY VALID_FROM DESC). «Питання підсумків»: view (дефолт) / матеріалізована таблиця / без зрізу → архітектор
- RSD_ISPOLNITELIZADACH.UDALITOSNOVNOYOBEKTADRESATSII (УдалитьОсновнойОбъектАдресации) — нетипізований ВИМІР (поліморфний, у ключі): UDALITOSNOVNOYOBEKTADRESATSII_REF_TYPE/UDALITOSNOVNOYOBEKTADRESATSII_REF_ID, без FK → рішення архітектора
- RSD_ISPOLNITELIZADACH.UDALITDOPOLNITELNYYOBEKTADRESATSII (УдалитьДополнительныйОбъектАдресации) — нетипізований ВИМІР (поліморфний, у ключі): UDALITDOPOLNITELNYYOBEKTADRESATSII_REF_TYPE/UDALITDOPOLNITELNYYOBEKTADRESATSII_REF_ID, без FK → рішення архітектора
- RSD_ISPOLNITELIROLEI_IDELEGATY.ROLPOLZOVATEL (РольПользователь) — композитний dimension: ROLPOLZOVATEL_REF_TYPE/ROLPOLZOVATEL_REF_ID, без FK
- RSD_ISPOLNITELIROLEI_IDELEGATY.UDALITROLPOLZOVATEL (УдалитьРольПользователь) — композитний dimension: UDALITROLPOLZOVATEL_REF_TYPE/UDALITROLPOLZOVATEL_REF_ID, без FK
- RSD_ISPOLNITELIROLEI_IDELEGATY.UDALITOSNOVNOYOBEKTADRESATSII (УдалитьОсновнойОбъектАдресации) — нетипізований ВИМІР (поліморфний, у ключі): UDALITOSNOVNOYOBEKTADRESATSII_REF_TYPE/UDALITOSNOVNOYOBEKTADRESATSII_REF_ID, без FK → рішення архітектора
- RSD_ISPOLNITELIROLEI_IDELEGATY.UDALITDOPOLNITELNYYOBEKTADRESATSII (УдалитьДополнительныйОбъектАдресации) — нетипізований ВИМІР (поліморфний, у ключі): UDALITDOPOLNITELNYYOBEKTADRESATSII_REF_TYPE/UDALITDOPOLNITELNYYOBEKTADRESATSII_REF_ID, без FK → рішення архітектора
- RSD_KURSYVALYUT: періодичний (Day) → VIEW RSD_KURSYVALYUT_SREZ_V (зріз останніх, срез последних: PARTITION BY VALYUTA_ID ORDER BY VALID_FROM DESC). «Питання підсумків»: view (дефолт) / матеріалізована таблиця / без зрізу → архітектор
- RSD_NASLEDOVANIENASTROEKPRAVOBEKTOV.OBEKT (Объект) — композитний dimension: OBEKT_REF_TYPE/OBEKT_REF_ID, без FK
- RSD_NASLEDOVANIENASTROEKPRAVOBEKTOV.RODITEL (Родитель) — композитний dimension: RODITEL_REF_TYPE/RODITEL_REF_ID, без FK
- RSD_NASTROI_KAPOVTORENIYABIZNESPROTSESSOV.BIZNESPROTSESS (БизнесПроцесс) — нетипізований ВИМІР (поліморфний, у ключі): BIZNESPROTSESS_REF_TYPE/BIZNESPROTSESS_REF_ID, без FK → рішення архітектора
- RSD_NASTROI_KIDOSTUPNOSTIDLYAVIDOVDOKUMENTOV.VIDDOKUMENTA (ВидДокумента) — композитний dimension: VIDDOKUMENTA_REF_TYPE/VIDDOKUMENTA_REF_ID, без FK
- RSD_NASTROI_KIPRAVOBEKTOV.OBEKT (Объект) — композитний dimension: OBEKT_REF_TYPE/OBEKT_REF_ID, без FK
- RSD_NASTROI_KIPRAVOBEKTOV.POLZOVATEL (Пользователь) — нетипізований ВИМІР (поліморфний, у ключі): POLZOVATEL_REF_TYPE/POLZOVATEL_REF_ID, без FK → рішення архітектора
- RSD_NASTROI_KIUVEDOMLENII.VIDSOBYTIYA (ВидСобытия) — композитний dimension: VIDSOBYTIYA_REF_TYPE/VIDSOBYTIYA_REF_ID, без FK
- RSD_NASTROI_KIUVEDOMLENII.OBEKT (Объект) — нетипізований ВИМІР (поліморфний, у ключі): OBEKT_REF_TYPE/OBEKT_REF_ID, без FK → рішення архітектора
- RSD_NASTROI_KIUVEDOMLENII.ZNACHENIE (Значение) — композитний resource: ZNACHENIE_REF_TYPE/ZNACHENIE_REF_ID, без FK
- RSD_NASTROI_KIETAPOVOBRABOTKIDOKUMENTOV.VIDDOKUMENTA (ВидДокумента) — композитний dimension: VIDDOKUMENTA_REF_TYPE/VIDDOKUMENTA_REF_ID, без FK
- RSD_OBMENSMOBILNYMINASTROI_KIPOLZOVATELEI.ZNACHENIE (Значение) — композитний resource: ZNACHENIE_REF_TYPE/ZNACHENIE_REF_ID, без FK
- RSD_OBRABOTANNYEUVEDOMLENIYA.VIDSOBYTIYA (ВидСобытия) — композитний dimension: VIDSOBYTIYA_REF_TYPE/VIDSOBYTIYA_REF_ID, без FK
- RSD_OBRABOTANNYEUVEDOMLENIYA.OBEKTUVEDOMLENIYA (ОбъектУведомления) — нетипізований ВИМІР (поліморфний, у ключі): OBEKTUVEDOMLENIYA_REF_TYPE/OBEKTUVEDOMLENIYA_REF_ID, без FK → рішення архітектора
- RSD_OBSHCHIENASTROI_KIUZLOVINFORMATSIONNYKHBAZ.UZELINFORMATSIONNOYBAZY (УзелИнформационнойБазы) — нетипізований ВИМІР (поліморфний, у ключі): UZELINFORMATSIONNOYBAZY_REF_TYPE/UZELINFORMATSIONNOYBAZY_REF_ID, без FK → рішення архітектора
- RSD_OCHEREDUVEDOMLENII.OBEKT (Объект) — нетипізований ВИМІР (поліморфний, у ключі): OBEKT_REF_TYPE/OBEKT_REF_ID, без FK → рішення архітектора
- RSD_OCHEREDUVEDOMLENII.VIDSOBYTIYA (ВидСобытия) — композитний dimension: VIDSOBYTIYA_REF_TYPE/VIDSOBYTIYA_REF_ID, без FK
- RSD_OCHEREDUVEDOMLENII.OBEKTPODPISKI (ОбъектПодписки) — нетипізований ВИМІР (поліморфний, у ключі): OBEKTPODPISKI_REF_TYPE/OBEKTPODPISKI_REF_ID, без FK → рішення архітектора
- RSD_POLNOMOCHIYAPOLZOVATELEI.VLADELETS (Владелец) — нетипізований ВИМІР (поліморфний, у ключі): VLADELETS_REF_TYPE/VLADELETS_REF_ID, без FK → рішення архітектора
- RSD_POLZOVATELIVKONTEI_NERAKH.KONTEYNER (Контейнер) — нетипізований ВИМІР (поліморфний, у ключі): KONTEYNER_REF_TYPE/KONTEYNER_REF_ID, без FK → рішення архітектора
- RSD_POLZOVATELSKIENASTROI_KIDOSTUPAKOBRABOTKAM.POLZOVATEL (Пользователь) — композитний dimension: POLZOVATEL_REF_TYPE/POLZOVATEL_REF_ID, без FK
- RSD_PROIZOSHEDSHIEBIZNESSOBYTIYA.ISTOCHNIK (Источник) — нетипізований resource, колонку не створено
- RSD_PROIZOSHEDSHIEBIZNESSOBYTIYA: періодичний (Second) → VIEW RSD_PROIZOSHEDSHIEBIZNESSOBYTIYA_SREZ_V (зріз останніх, срез последних: PARTITION BY OBRABOTANO,IDENTIFIKATOR ORDER BY VALID_FROM DESC). «Питання підсумків»: view (дефолт) / матеріалізована таблиця / без зрізу → архітектор
- RSD_PROTOKOLRABOTYPOLZOVATELEI.OBEKTDANNYKH (ОбъектДанных) — нетипізований ВИМІР (поліморфний, у ключі): OBEKTDANNYKH_REF_TYPE/OBEKTDANNYKH_REF_ID, без FK → рішення архітектора
- RSD_PROTSESSYDLYAZAPUSKA.BIZNESPROTSESS (БизнесПроцесс) — нетипізований ВИМІР (поліморфний, у ключі): BIZNESPROTSESS_REF_TYPE/BIZNESPROTSESS_REF_ID, без FK → рішення архітектора
- RSD_RAZRESHENIYADLYALOKALNYKHADMINISTRATOROV.POLZOVATEL (Пользователь) — нетипізований ВИМІР (поліморфний, у ключі): POLZOVATEL_REF_TYPE/POLZOVATEL_REF_ID, без FK → рішення архітектора
- RSD_RAZRESHENIYADOSTUPAISKLYUCHITELNYE.POLZOVATEL (Пользователь) — нетипізований ВИМІР (поліморфний, у ключі): POLZOVATEL_REF_TYPE/POLZOVATEL_REF_ID, без FK → рішення архітектора
- RSD_RAZRESHENIYADOSTUPAOBSHCHIE.ZNACHENIEDOSTUPA (ЗначениеДоступа) — нетипізований ВИМІР (поліморфний, у ключі): ZNACHENIEDOSTUPA_REF_TYPE/ZNACHENIEDOSTUPA_REF_ID, без FK → рішення архітектора
- RSD_RAZRESHENIYADOSTUPAOBSHCHIE.POLZOVATEL (Пользователь) — нетипізований ВИМІР (поліморфний, у ключі): POLZOVATEL_REF_TYPE/POLZOVATEL_REF_ID, без FK → рішення архітектора
- RSD_REZHIMYPODKLYUCHENIYAVNESHNIKHMODULEI.TIPPROGRAMMNOGOMODULYA (ТипПрограммногоМодуля) — композитний dimension: TIPPROGRAMMNOGOMODULYA_REF_TYPE/TIPPROGRAMMNOGOMODULYA_REF_ID, без FK
- RSD_REZHIMYPODKLYUCHENIYAVNESHNIKHMODULEI.BEZOPASNYYREZHIM (БезопасныйРежим) — нетипізований resource, колонку не створено
- RSD_REZULTATYOBMENADANNYMI.PROBLEMNYYOBEKT (ПроблемныйОбъект) — нетипізований ВИМІР (поліморфний, у ключі): PROBLEMNYYOBEKT_REF_TYPE/PROBLEMNYYOBEKT_REF_ID, без FK → рішення архітектора
- RSD_REZULTATYOBMENADANNYMI.UZELINFORMATSIONNOYBAZY (УзелИнформационнойБазы) — нетипізований resource, колонку не створено
- RSD_SVEDENIYAOPOLZOVATELYAKH.POLZOVATEL (Пользователь) — композитний dimension: POLZOVATEL_REF_TYPE/POLZOVATEL_REF_ID, без FK
- RSD_SVEDENIYAOTOCHKAKHMARSHRUTA.TOCHKAMARSHRUTA (ТочкаМаршрута) — нетипізований ВИМІР (поліморфний, у ключі): TOCHKAMARSHRUTA_REF_TYPE/TOCHKAMARSHRUTA_REF_ID, без FK → рішення архітектора
- RSD_SVYAZIZNACHENII_SVOI_STVIOBEKTOVINTEGRIROVANNYKHSISTEM.ZNACHENIESVOYSTVA (ЗначениеСвойства) — композитний resource: ZNACHENIESVOYSTVA_REF_TYPE/ZNACHENIESVOYSTVA_REF_ID, без FK
- RSD_SVYAZIOBEKTOVISOOBSHCHENII_INTEGRIROVANNYKHSISTEM.OBEKT (Объект) — нетипізований ВИМІР (поліморфний, у ключі): OBEKT_REF_TYPE/OBEKT_REF_ID, без FK → рішення архітектора
- RSD_SOSTAVYGRUPPPOLZOVATELEI.GRUPPAPOLZOVATELEY (ГруппаПользователей) — композитний dimension: GRUPPAPOLZOVATELEY_REF_TYPE/GRUPPAPOLZOVATELEY_REF_ID, без FK
- RSD_SOSTAVYGRUPPPOLZOVATELEI.POLZOVATEL (Пользователь) — композитний dimension: POLZOVATEL_REF_TYPE/POLZOVATEL_REF_ID, без FK
- RSD_SOSTOYANIYAOBMENOVDANNYMI.UZELINFORMATSIONNOYBAZY (УзелИнформационнойБазы) — нетипізований ВИМІР (поліморфний, у ключі): UZELINFORMATSIONNOYBAZY_REF_TYPE/UZELINFORMATSIONNOYBAZY_REF_ID, без FK → рішення архітектора
- RSD_SPOSOBYUVEDOMLENIYAPOLZOVATELEI.POLZOVATEL (Пользователь) — композитний dimension: POLZOVATEL_REF_TYPE/POLZOVATEL_REF_ID, без FK

## Встановлення
`ddl.sql` → стенд (NLS_LANG=.AL32UTF8). EnumRef→RSD_ENUMS. FK лише на наявні таблиці;
відкладені ставляться після міграції відповідних довідників/документів.
