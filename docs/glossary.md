# Глосарій імен міграції BAS → APEX (накопичувальний)

Єдине джерело відповідності імен 1С → ідентифікаторів Oracle між усіма
батчами. Поповнюється після затвердження кожної специфікації (етап 3
конвеєра bas2apex). Однакове джерельне імʼя завжди дає однаковий
ідентифікатор — рядки звідси не переглядаються, лише доповнюються.

| Source name (ru) | Identifier (en) | Label (uk) | Kind |
|---|---|---|---|
| RSD_Дома | RSD_HOUSES | Будинки | Catalog |
| RSD_Секции | RSD_HOUSE_SECTIONS | Секції | Catalog (subordinate) |
| Организации | RSD_ORGANIZATIONS | Організації | Catalog |
| Код | CODE | Код | std attr |
| Наименование | NAME | Найменування | std attr |
| ПометкаУдаления | IS_DELETED | Позначка видалення | std attr |
| Владелец | OWNER_ID | Власник | std attr |
| НомерСтроки | LINE_NO | Номер рядка | std attr |
| Организация | ORGANIZATION_ID | Організація* | attr |
| АдресДома | HOUSE_ADDRESS | Адреса будинку* | attr |
| Активность | IS_ACTIVE | Активність* | attr |
| Номер | ITEM_NO | Номер* | attr |
| Дом0 | IS_HOUSE_ZERO | Будинок 0 (LOT 100) | attr |
| ИНН | TAX_ID | ІПН | attr |
| КодПоЕДРПОУ | EDRPOU_CODE | Код за ЄДРПОУ | attr |
| Комментарий | COMMENT_TEXT | Коментар | attr |
| НаименованиеПолное | FULL_NAME | Повне найменування | attr |
| ОсновнойБанковскийСчет | MAIN_BANK_ACCOUNT_ID | Основний банківський рахунок | attr |
| Префикс | DOC_PREFIX | Префікс | attr |
| ЮрФизЛицо | ENTITY_KIND_ID | Вид організації | attr |
| ПлательщикНДС | IS_VAT_PAYER | Платник ПДВ | attr |
| Застройщик | DEVELOPER_ID | Забудовник | attr |
| ДополнительныеРеквизиты | ADD_ATTRS | Додаткові реквізити | tab section |
| Свойство | PROPERTY_ID | Властивість | attr |
| Значение | — (§9) | Значення | attr |
| ТекстоваяСтрока | TEXT_VALUE | Текстовий рядок | attr |
| КонтактнаяИнформация | CONTACT_INFO | Контактна інформація | tab section |
| Тип | TYPE_ID | Тип | attr |
| Вид | KIND_ID | Вид | attr |
| Представление | PRESENTATION | Представлення | attr |
| ЗначенияПолей | FIELD_VALUES | Значення полів | attr |
| Страна | COUNTRY | Країна | attr |
| Регион | REGION | Регіон | attr |
| Город | CITY | Місто | attr |
| АдресЭП | EMAIL_ADDRESS | Адреса ЕП | attr |
| ДоменноеИмяСервера | SERVER_DOMAIN | Доменне ім'я сервера | attr |
| НомерТелефона | PHONE_NUMBER | Номер телефону | attr |
| НомерТелефонаБезКодов | PHONE_NUMBER_LOCAL | Номер телефону без кодів | attr |
| ВидДляСписка | LIST_KIND_ID | Вид для списку | attr |
| ДействуетС | VALID_FROM | Діє З | attr |
| БанковскиеСчета | BANK_ACCOUNTS | Банківські рахунки* | EXTERNAL |
| Контрагенты | COUNTERPARTIES | Контрагенти* | EXTERNAL |
| ВидыКонтактнойИнформации | CONTACT_INFO_KINDS | Види контактної інформації* | EXTERNAL |
| ДополнительныеРеквизитыИСведения | ADD_ATTR_PROPERTIES | Додаткові реквізити й відомості* | EXTERNAL |
| ТипыКонтактнойИнформации | CONTACT_INFO_TYPES | Типи контактної інформації* | EXTERNAL |
| ЮрФизЛицо (enum) | ENTITY_KINDS | Види організацій* | EXTERNAL |
| _(будь-яке перечислення)_ | RSD_ENUMS (ENUM_TYPE=<імʼя>) | — | Enum→lookup (батч 002) |

<!-- батч 003: довідники НСІ хвиль 2–4 (транслітерація детермінована генератором) -->
| RSD_НаправленияДеятельности | RSD_NAPRAVLENIYADEYATELNOSTI | Напрями діяльності | Catalog |
| RSD_НастройкаУведомленийОНачисленииБаллов | RSD_NASTROI_KAUVEDOMLENII_ONACHISLENIIBALLOV | Налаштування повідомлень про нарахування балів | Catalog |
| RSD_НастройкиРабочихМестПользователей | RSD_NASTROI_KIRABOCHIKHMESTPOLZOVATELEI | Налаштування робочих місць користувачів | Catalog |
| RSD_ПодписиШтампы | RSD_PODPISISHTAMPY | Підписи і штампи | Catalog |
| RSD_ПолучателиОтчетовСтатистикиЗапросовНаДокументацию | RSD_POLUCHATELIOTCHETOVSTATISTIKIZAPROSOVNADOKUMENTATSIYU | Отримувачі звітів про статистику запитів документації | Catalog |
| RSD_ПолучателиРеестраПодписанныхСделок | RSD_POLUCHATELIREESTRAPODPISANNYKHSDELOK | Отримувачі плану підписання договорів | Catalog |
| RSD_РаспределениеОтветственныхЗаБюджетыПоСтатьямРГК | RSD_RASPREDELENIEOTVETSTVENNYKHZABYUDZHETYPOSTATYAMRGK | Розподіл відповідальних за бюджети по статтям РГК | Catalog |
| АдресатыПочтовыхСообщений | RSD_ADRESATYPOCHTOVYKHSOOBSHCHENII | Адресати поштових повідомлень | Catalog |
| БанковскиеСчета | RSD_BANKOVSKIESCHETA | Банківські рахунки | Catalog |
| Валюты | RSD_VALYUTY | Валюти | Catalog |
| ВариантыОтчетов | RSD_VARIANTYOTCHETOV | Звіти | Catalog |
| ВерсииФайлов | RSD_VERSIIFAI_LOV | Версії файлів | Catalog |
| ВидыБизнесСобытий | RSD_VIDYBIZNESSOBYTII | Види бізнес-подій | Catalog |
| ВидыВнутреннихДокументов | RSD_VIDYVNUTRENNIKHDOKUMENTOV | Види внутрішніх документів | Catalog |
| ВидыВходящихДокументов | RSD_VIDYVKHODYASHCHIKHDOKUMENTOV | Види вхідних документів | Catalog |
| ВидыИсходящихДокументов | RSD_VIDYISKHODYASHCHIKHDOKUMENTOV | Види вихідних документів | Catalog |
| ВидыМероприятий | RSD_VIDYMEROPRIYATII | Види заходів | Catalog |
| ВидыРабот | RSD_VIDYRABOT | Види робіт | Catalog |
| ВнешниеПользователи | RSD_VNESHNIEPOLZOVATELI | Зовнішні користувачі | Catalog |
| ВопросыДеятельности | RSD_VOPROSYDEYATELNOSTI | Питання діяльності | Catalog |
| ГрафикиРаботы | RSD_GRAFIKIRABOTY | Графіки роботи | Catalog |
| ГрифыДоступа | RSD_GRIFYDOSTUPA | Грифи доступу | Catalog |
| ГруппыВнешнихПользователей | RSD_GRUPPYVNESHNIKHPOLZOVATELEI | Групи зовнішніх користувачів | Catalog |
| ГруппыДоступа | RSD_GRUPPYDOSTUPA | (не використовується) Групи доступу | Catalog |
| ГруппыДоступаКонтрагентов | RSD_GRUPPYDOSTUPAKONTRAGENTOV | Групи доступу контрагентів | Catalog |
| ГруппыДоступаФизическихЛиц | RSD_GRUPPYDOSTUPAFIZICHESKIKHLITS | Групи доступу фізичних осіб | Catalog |
| ГруппыКонтрольныхТочек | RSD_GRUPPYKONTROLNYKHTOCHEK | Групи контрольних точок | Catalog |
| ГруппыЛичныхАдресатов | RSD_GRUPPYLICHNYKHADRESATOV | Групи особистих адресатів | Catalog |
| ДелегированиеПрав | RSD_DELEGIROVANIEPRAV | Делегування прав | Catalog |
| ДетекторыБизнесСобытий | RSD_DETEKTORYBIZNESSOBYTII | Детектори бізнес-подій | Catalog |
| Должности | RSD_DOLZHNOSTI | Посади | Catalog |
| ДополнительныеОтчетыИОбработки | RSD_DOPOLNITELNYEOTCHETYIOBRABOTKI | Додаткові звіти й обробки | Catalog |
| ЗаметкиДокументооборота | RSD_ZAMETKIDOKUMENTOOBOROTA | Замітки документообігу | Catalog |
| ЗначенияСвойствОбъектов | RSD_ZNACHENIYASVOI_STVOBEKTOV | Додаткові значення | Catalog |
| ЗначенияСвойствОбъектовИерархия | RSD_ZNACHENIYASVOI_STVOBEKTOVIERARKHIYA | Додаткові значення (ієрархія) | Catalog |
| КатегорииДанных | RSD_KATEGORIIDANNYKH | Категорії | Catalog |
| КлючевыеОперации | RSD_KLYUCHEVYEOPERATSII | Ключові операції | Catalog |
| Контрагенты | RSD_KONTRAGENTY | Контрагенти | Catalog |
| КонтрольныеТочки | RSD_KONTROLNYETOCHKI | Контрольні точки | Catalog |
| ЛичныеАдресаты | RSD_LICHNYEADRESATY | Особисті адресати | Catalog |
| НаборыДополнительныхРеквизитовИСведений | RSD_NABORYDOPOLNITELNYKHREKVIZITOVISVEDENII | Набори додаткових реквізитів і відомостей | Catalog |
| НастройкиВариантовОтчетовДокументооборот | RSD_NASTROI_KIVARIANTOVOTCHETOVDOKUMENTOOBOROT | Настройки варіантів звітів Документообіг | Catalog |
| Номенклатура | RSD_NOMENKLATURA | Товари і послуги | Catalog |
| Нумераторы | RSD_NUMERATORY | Нумератори | Catalog |
| ОбластиДелегированияПрав | RSD_OBLASTIDELEGIROVANIYAPRAV | Області делегування прав | Catalog |
| ПапкиВнутреннихДокументов | RSD_PAPKIVNUTRENNIKHDOKUMENTOV | Папки внутрішніх документів | Catalog |
| ПапкиМероприятий | RSD_PAPKIMEROPRIYATII | Папки заходів | Catalog |
| ПапкиПисем | RSD_PAPKIPISEM | Папки листів | Catalog |
| ПапкиПоиска | RSD_PAPKIPOISKA | Папки пошуку | Catalog |
| ПапкиПроектов | RSD_PAPKIPROEKTOV | Папки проектів | Catalog |
| ПапкиФайлов | RSD_PAPKIFAI_LOV | Папки файлів | Catalog |
| ПапкиФорума | RSD_PAPKIFORUMA | Розділи форуму | Catalog |
| ПоказателиВиджетов | RSD_POKAZATELIVIDZHETOV | Показники віджетів | Catalog |
| Пользователи | RSD_POLZOVATELI | Користувачі | Catalog |
| ПользовательскиеОбработчикиБизнесСобытий | RSD_POLZOVATELSKIEOBRABOTCHIKIBIZNESSOBYTII | Користувацькі обробники бізнесів-подій | Catalog |
| ПравилаАвтозаполненияФайлов | RSD_PRAVILAAVTOZAPOLNENIYAFAI_LOV | Настройки заповнення файлів | Catalog |
| ПравилаРазмещенияФайловВТомах | RSD_PRAVILARAZMESHCHENIYAFAI_LOVVTOMAKH | Правила розміщення файлів у томах | Catalog |
| ПредопределенныеВариантыОтчетов | RSD_PREDOPREDELENNYEVARIANTYOTCHETOV | Напередвизначені варіанти звітів | Catalog |
| ПредопределенныеВариантыОтчетовРасширений | RSD_PREDOPREDELENNYEVARIANTYOTCHETOVRASSHIRENII | Зумовлені варіанти звітів розширень | Catalog |
| ПрофилиГруппДоступа | RSD_PROFILIGRUPPDOSTUPA | Повноваження | Catalog |
| РабочиеГруппы | RSD_RABOCHIEGRUPPY | Робочі групи | Catalog |
| РолиИсполнителей | RSD_ROLIISPOLNITELEI | Ролі виконавців | Catalog |
| СертификатыКлючейЭлектроннойПодписиИШифрования | RSD_SERTIFIKATYKLYUCHEI_ELEKTRONNOI_PODPISIISHIFROVANIYA | Сертифікати ключів електронного підпису та шифрування | Catalog |
| СообщенияОбсуждений | RSD_SOOBSHCHENIYAOBSUZHDENII | Повідомлення форуму | Catalog |
| СтруктураПредприятия | RSD_STRUKTURAPREDPRIYATIYA | Структура підприємства | Catalog |
| ТемыЗаметок | RSD_TEMYZAMETOK | Теми заміток | Catalog |
| ТерриторииИПомещения | RSD_TERRITORIIIPOMESHCHENIYA | Приміщення і території | Catalog |
| УведомленияПрограммы | RSD_UVEDOMLENIYAPROGRAMMY | Повідомлення програми | Catalog |
| УдалитьПомещения | RSD_UDALITPOMESHCHENIYA | Вилучити приміщення | Catalog |
| УдалитьПроизошедшиеБизнесСобытия | RSD_UDALITPROIZOSHEDSHIEBIZNESSOBYTIYA | (не використовується) Бізнес-події, які відбулися | Catalog |
| УдалитьШаблоныТекстовПисем | RSD_UDALITSHABLONYTEKSTOVPISEM | Вилучити шаблони текстів листів | Catalog |
| УсловияЗадач | RSD_USLOVIYAZADACH | Умови перевірки задач | Catalog |
| УсловияМаршрутизации | RSD_USLOVIYAMARSHRUTIZATSII | Умови маршрутизації | Catalog |
| УчетныеЗаписиЭлектроннойПочты | RSD_UCHETNYEZAPISIELEKTRONNOI_POCHTY | Облікові записи | Catalog |
| ФизическиеЛица | RSD_FIZICHESKIELITSA | Фізичні особи | Catalog |
| ШаблоныГруппКонтрольныхТочек | RSD_SHABLONYGRUPPKONTROLNYKHTOCHEK | Шаблони груп контрольних точок | Catalog |
| ШаблоныКонтрольныхТочек | RSD_SHABLONYKONTROLNYKHTOCHEK | Шаблони контрольних точок | Catalog |
| ШаблоныТекстов | RSD_SHABLONYTEKSTOV | Шаблони текстів | Catalog |

<!-- батч 005: регістри відомостей хвиль 2–4 (транслітерація детермінована генератором gen_register_batch) -->
| RSD_ЗапретНаИспользованиеТелеграмБота | RSD_ZAPRETNAISPOLZOVANIETELEGRAMBOTA | Заборона на використання бота Telegram для співробітників | InformationRegister |
| RSD_ИсторияРассылкиСообщенийУчастникамТелеграмЧата | RSD_ISTORIYARASSYLKISOOBSHCHENII_UCHASTNIKAMTELEGRAMCHATA | Історія розсилання повідомлень учасникам Telegram чату | InformationRegister |
| RSD_КлючевыеСловаСтатейДДС | RSD_KLYUCHEVYESLOVASTATEI_DDS | Ключові слова статей РГК | InformationRegister |
| RSD_НастройкиПодключенияБотаТелеграм | RSD_NASTROI_KIPODKLYUCHENIYABOTATELEGRAM | Налаштування підключения бота Telegram | InformationRegister |
| RSD_ОшибкиРассылкиСообщенийУчасникамТендерБота | RSD_OSHIBKIRASSYLKISOOBSHCHENII_UCHASNIKAMTENDERBOTA | Помилки розсилання повідомлень учасникам Тендер бота | InformationRegister |
| RSD_ПодпискаНаОбновленияПоВидуРабот | RSD_PODPISKANAOBNOVLENIYAPOVIDURABOT | Підписка на оновлення по виду робіт | InformationRegister |
| RSD_ПользователиТелеграм | RSD_POLZOVATELITELEGRAM | Користувачі Telegram | InformationRegister |
| RSD_ПротоколИспользованияДокументации | RSD_PROTOKOLISPOLZOVANIYADOKUMENTATSII | Протокол використання документації | InformationRegister |
| RSD_РегистрОтправкиРассылокТелеграм | RSD_REGISTROTPRAVKIRASSYLOKTELEGRAM | Відправки розсилок телеграм | InformationRegister |
| RSD_РегистрационныеДанныеERP | RSD_REGISTRATSIONNYEDANNYEERP | Реєстраційні данні ERP | InformationRegister |
| RSD_ШаблоныСообщенийПользователямTenderБоту | RSD_SHABLONYSOOBSHCHENII_POLZOVATELYAMTENDERBOTU | Шаблони повідомлень користувачам Tender боту | InformationRegister |
| ВерсииОбъектов | RSD_VERSIIOBEKTOV | Версії об'єктів | InformationRegister |
| ДанныеОбработанныеВЦентральномУзлеРИБ | RSD_DANNYEOBRABOTANNYEVTSENTRALNOMUZLERIB | Дані, оброблені в центральному вузлі РІБ | InformationRegister |
| ДокументыФизическихЛиц | RSD_DOKUMENTYFIZICHESKIKHLITS | Документи фізичних осіб | InformationRegister |
| ДополнительныеСведения | RSD_DOPOLNITELNYESVEDENIYA | Додаткові відомості | InformationRegister |
| ДоступноеВремяПользователя | RSD_DOSTUPNOEVREMYAPOLZOVATELYA | Доступний час користувача | InformationRegister |
| ЗамерыВремени | RSD_ZAMERYVREMENI | Заміри часу | InformationRegister |
| ЗамерыВремениТехнологические | RSD_ZAMERYVREMENITEKHNOLOGICHESKIE | Виміри часу технологічні | InformationRegister |
| ЗамерыМетрик | RSD_ZAMERYMETRIK | Виміри показників | InformationRegister |
| ЗанятостьПользователя | RSD_ZANYATOSTPOLZOVATELYA | Зайнятість користувача | InformationRegister |
| ЗапросыРазрешенийНаИспользованиеВнешнихРесурсов | RSD_ZAPROSYRAZRESHENII_NAISPOLZOVANIEVNESHNIKHRESURSOV | Запити дозволів на використання зовнішніх ресурсів | InformationRegister |
| ЗначенияПоказателейРаботыПользователя | RSD_ZNACHENIYAPOKAZATELEI_RABOTYPOLZOVATELYA | Значення показників роботи користувача | InformationRegister |
| ИзмененныеНастройкиСинхронизацииСМобильнымКлиентом | RSD_IZMENENNYENASTROI_KISINKHRONIZATSIISMOBILNYMKLIENTOM | Змінені настройки синхронізації з мобільним клієнтом | InformationRegister |
| ИсполнителиЗадач | RSD_ISPOLNITELIZADACH | Виконавці ролей | InformationRegister |
| ИсполнителиРолейИДелегаты | RSD_ISPOLNITELIROLEI_IDELEGATY | Виконавці ролей та делегати | InformationRegister |
| ИспользованиеАдресатовПользователями | RSD_ISPOLZOVANIEADRESATOVPOLZOVATELYAMI | Використання адресатів користувачами | InformationRegister |
| ИспользованиеПочты | RSD_ISPOLZOVANIEPOCHTY | Використання пошти | InformationRegister |
| КалендарныеГрафики | RSD_KALENDARNYEGRAFIKI | Календарні графіки | InformationRegister |
| КоличествоПисемВПапках | RSD_KOLICHESTVOPISEMVPAPKAKH | Кількість листів у папках | InformationRegister |
| КурсыВалют | RSD_KURSYVALYUT | Курси валют | InformationRegister |
| НазначениеДополнительныхОбработок | RSD_NAZNACHENIEDOPOLNITELNYKHOBRABOTOK | Призначення додаткових обробок | InformationRegister |
| НаследованиеНастроекПравОбъектов | RSD_NASLEDOVANIENASTROEKPRAVOBEKTOV | Наслідування настройок прав об'єктів | InformationRegister |
| НастройкаПовторенияБизнесПроцессов | RSD_NASTROI_KAPOVTORENIYABIZNESPROTSESSOV | Настройка повторення процесів | InformationRegister |
| НастройкиАвтоочисткиПапокПисем | RSD_NASTROI_KIAVTOOCHISTKIPAPOKPISEM | Настройки автоочищення папок листів | InformationRegister |
| НастройкиВерсионированияОбъектов | RSD_NASTROI_KIVERSIONIROVANIYAOBEKTOV | Настройки версіонування об'єктів | InformationRegister |
| НастройкиДоступностиДляВидовДокументов | RSD_NASTROI_KIDOSTUPNOSTIDLYAVIDOVDOKUMENTOV | Настройки доступності для видів документів | InformationRegister |
| НастройкиКомандПечати | RSD_NASTROI_KIKOMANDPECHATI | Настройки команд друку | InformationRegister |
| НастройкиОповещенийОПисьмах | RSD_NASTROI_KIOPOVESHCHENII_OPISMAKH | Настройки сповіщень про листи | InformationRegister |
| НастройкиОтложеннойОтправкиПисем | RSD_NASTROI_KIOTLOZHENNOI_OTPRAVKIPISEM | Настройки відкладеного відправлення листів | InformationRegister |
| НастройкиПравОбъектов | RSD_NASTROI_KIPRAVOBEKTOV | Настройки прав об'єктів | InformationRegister |
| НастройкиРабочегоКалендаря | RSD_NASTROI_KIRABOCHEGOKALENDARYA | Настройки робочого календаря | InformationRegister |
| НастройкиТекущихДел | RSD_NASTROI_KITEKUSHCHIKHDEL | Настройки поточних справ | InformationRegister |
| НастройкиУведомлений | RSD_NASTROI_KIUVEDOMLENII | Настройка повідомлень | InformationRegister |
| НастройкиЭтаповОбработкиДокументов | RSD_NASTROI_KIETAPOVOBRABOTKIDOKUMENTOV | Настройки етапів обробки документів | InformationRegister |
| ОбменСМобильнымиНастройкиПользователей | RSD_OBMENSMOBILNYMINASTROI_KIPOLZOVATELEI | Обмін з мобільними настройки користувачів | InformationRegister |
| ОбработанныеУведомления | RSD_OBRABOTANNYEUVEDOMLENIYA | Оброблені повідомлення | InformationRegister |
| ОбработкаНовыхПисемДляОтправкиPushУведомлений | RSD_OBRABOTKANOVYKHPISEMDLYAOTPRAVKIPUSHUVEDOMLENII | Обробка нових листів для відсилання push-повідомлень | InformationRegister |
| ОбщиеНастройкиУзловИнформационныхБаз | RSD_OBSHCHIENASTROI_KIUZLOVINFORMATSIONNYKHBAZ | Загальні настройки вузлів інформаційних баз | InformationRegister |
| ОчередьУведомлений | RSD_OCHEREDUVEDOMLENII | Черга повідомлень | InformationRegister |
| ПапкиПисемБыстрогоДоступа | RSD_PAPKIPISEMBYSTROGODOSTUPA | Папки листів швидкого доступу | InformationRegister |
| ПапкиПисемТекущихДел | RSD_PAPKIPISEMTEKUSHCHIKHDEL | Папки листів поточних справ | InformationRegister |
| ПапкиПисемЧастоИспользуемые | RSD_PAPKIPISEMCHASTOISPOLZUEMYE | Часто використовувані Папки листів | InformationRegister |
| ПапкиУчетныхЗаписей | RSD_PAPKIUCHETNYKHZAPISEI | Папки облікових записів | InformationRegister |
| ПодчиненностьПодразделений | RSD_PODCHINENNOSTPODRAZDELENII | Підпорядкованість підрозділів | InformationRegister |
| ПодчиненностьСотрудников | RSD_PODCHINENNOSTSOTRUDNIKOV | Підпорядкованість співробітників | InformationRegister |
| ПолномочияПользователей | RSD_POLNOMOCHIYAPOLZOVATELEI | Повноваження користувачів | InformationRegister |
| ПолучателиОповещенийОПроблемахРаботыПрограммы | RSD_POLUCHATELIOPOVESHCHENII_OPROBLEMAKHRABOTYPROGRAMMY | Одержувачі оповіщень про проблеми роботи програми | InformationRegister |
| ПользователиВКонтейнерах | RSD_POLZOVATELIVKONTEI_NERAKH | Користувачі в контейнерах | InformationRegister |
| ПользовательскиеНастройкиДоступаКОбработкам | RSD_POLZOVATELSKIENASTROI_KIDOSTUPAKOBRABOTKAM | Користувацькі настройки доступу до обробок | InformationRegister |
| ПороговыеЗначенияПоказателейВиджетов | RSD_POROGOVYEZNACHENIYAPOKAZATELEI_VIDZHETOV | Порогові значення показників віджетів | InformationRegister |
| ПраваРолей | RSD_PRAVAROLEI | Права ролей | InformationRegister |
| ПравилаДляОбменаДанными | RSD_PRAVILADLYAOBMENADANNYMI | Правила для обміну даними | InformationRegister |
| ПроверкаПоступленияНовыхПисем | RSD_PROVERKAPOSTUPLENIYANOVYKHPISEM | Перевірка надходження нових листів | InformationRegister |
| ПроизошедшиеБизнесСобытия | RSD_PROIZOSHEDSHIEBIZNESSOBYTIYA | Відбулися бізнес події | InformationRegister |
| ПротоколРаботыПользователей | RSD_PROTOKOLRABOTYPOLZOVATELEI | Протокол роботи користувачів | InformationRegister |
| ПроцессыДляЗапуска | RSD_PROTSESSYDLYAZAPUSKA | Процеси для запуску | InformationRegister |
| РабочиеКаталогиФайловКомпьютера | RSD_RABOCHIEKATALOGIFAI_LOVKOMPYUTERA | Робочі каталоги файлів комп'ютера | InformationRegister |
| РазрешенияДляЛокальныхАдминистраторов | RSD_RAZRESHENIYADLYALOKALNYKHADMINISTRATOROV | Дозволи для локальних адміністраторів | InformationRegister |
| РазрешенияДоступаИсключительные | RSD_RAZRESHENIYADOSTUPAISKLYUCHITELNYE | Дозволи доступу виняткові | InformationRegister |
| РазрешенияДоступаОбщие | RSD_RAZRESHENIYADOSTUPAOBSHCHIE | Дозволи доступу загальні | InformationRegister |
| РазрешенияНаИспользованиеВнешнихРесурсов | RSD_RAZRESHENIYANAISPOLZOVANIEVNESHNIKHRESURSOV | Дозвіл на використання зовнішніх ресурсів | InformationRegister |
| РазрешенныеМобильныеПользователи | RSD_RAZRESHENNYEMOBILNYEPOLZOVATELI | Дозволені мобільні користувачі | InformationRegister |
| РежимыПодключенияВнешнихМодулей | RSD_REZHIMYPODKLYUCHENIYAVNESHNIKHMODULEI | Режими підключення зовнішніх модулів | InformationRegister |
| РезультатыОбменаДанными | RSD_REZULTATYOBMENADANNYMI | Попередження при синхронізації даних | InformationRegister |
| СведенияОГолосовании | RSD_SVEDENIYAOGOLOSOVANII | Відомості про голосування | InformationRegister |
| СведенияОПользователях | RSD_SVEDENIYAOPOLZOVATELYAKH | Відомості про користувачів | InformationRegister |
| СведенияОПользователяхДокументооборот | RSD_SVEDENIYAOPOLZOVATELYAKHDOKUMENTOOBOROT | Відомості про користувачів документообіг | InformationRegister |
| СведенияОПомещениях | RSD_SVEDENIYAOPOMESHCHENIYAKH | Відомості про приміщення | InformationRegister |
| СведенияОСообщенияхОбменаСИнтегрированнымиСистемами | RSD_SVEDENIYAOSOOBSHCHENIYAKHOBMENASINTEGRIROVANNYMISISTEMAMI | Відомості про повідомлення обміну з інтегрованими системами | InformationRegister |
| СведенияОСообщенияхОбменаСМобильнымиКлиентами | RSD_SVEDENIYAOSOOBSHCHENIYAKHOBMENASMOBILNYMIKLIENTAMI | Відомості про повідомлення обміну з мобільними клієнтами | InformationRegister |
| СведенияОТемахОбсуждений | RSD_SVEDENIYAOTEMAKHOBSUZHDENII | Відомості про теми обговорень | InformationRegister |
| СведенияОТочкахМаршрута | RSD_SVEDENIYAOTOCHKAKHMARSHRUTA | Відомості про точки маршруту | InformationRegister |
| СвязиЗначенийСвойствИОбъектовИнтегрированныхСистем | RSD_SVYAZIZNACHENII_SVOI_STVIOBEKTOVINTEGRIROVANNYKHSISTEM | Зв'язку значень властивостей об'єктів інтегрованих систем | InformationRegister |
| СвязиОбъектовИСообщенийИнтегрированныхСистем | RSD_SVYAZIOBEKTOVISOOBSHCHENII_INTEGRIROVANNYKHSISTEM | Зв'язки об'єктів і повідомлень інтегрованих систем | InformationRegister |
| СинхронизацияПапокПисемСМобильнымКлиентом | RSD_SINKHRONIZATSIYAPAPOKPISEMSMOBILNYMKLIENTOM | Синхронізація папок листів з мобільним клієнтом | InformationRegister |
| СоставыГруппПользователей | RSD_SOSTAVYGRUPPPOLZOVATELEI | Склади груп користувачів | InformationRegister |
| СостоянияОбменовДанными | RSD_SOSTOYANIYAOBMENOVDANNYMI | Стани обмінів даними | InformationRegister |
| СпособыУведомленияПользователей | RSD_SPOSOBYUVEDOMLENIYAPOLZOVATELEI | Способи повідомлення користувачів | InformationRegister |
| СтепеньГотовностиСообщенийИнтегрированныхСистем | RSD_STEPENGOTOVNOSTISOOBSHCHENII_INTEGRIROVANNYKHSISTEM | Ступінь готовності повідомлень інтегрованих систем | InformationRegister |
| ТемыЗаметокДокументооборота | RSD_TEMYZAMETOKDOKUMENTOOBOROTA | Теми заміток документообігу | InformationRegister |
| УдалитьДелегированиеПравПользователям | RSD_UDALITDELEGIROVANIEPRAVPOLZOVATELYAM | Делегування прав | InformationRegister |
| УдалитьНастройкиВерсионированияОбъектов | RSD_UDALITNASTROI_KIVERSIONIROVANIYAOBEKTOV | (не використовується) Налаштування версионирования об'єктів | InformationRegister |
| УдалитьНастройкиУведомленияОЗадачах | RSD_UDALITNASTROI_KIUVEDOMLENIYAOZADACHAKH | Видалити налаштування повідомлення про задачі | InformationRegister |
| УдалитьНастройкиУведомленияОКонтроле | RSD_UDALITNASTROI_KIUVEDOMLENIYAOKONTROLE | Вилучити настройки повідомлення про контроль | InformationRegister |
| УдалитьНастройкиУведомленияОкончанияСрокаДействия | RSD_UDALITNASTROI_KIUVEDOMLENIYAOKONCHANIYASROKADEI_STVIYA | Вилучити настройки повідомлення закінчення строку дії | InformationRegister |
| УдалитьРабочиеКаталогиФайлов | RSD_UDALITRABOCHIEKATALOGIFAI_LOV | Вилучити робочі каталоги файлів | InformationRegister |
| УдалитьСведенияОПросмотрах | RSD_UDALITSVEDENIYAOPROSMOTRAKH | Вилучити відомості про перегляди | InformationRegister |
| УдалитьФайлыВРабочемКаталоге | RSD_UDALITFAI_LYVRABOCHEMKATALOGE | Вилучити файли в робочому каталозі | InformationRegister |
| ФайлыВРабочемКаталогеКомпьютера | RSD_FAI_LYVRABOCHEMKATALOGEKOMPYUTERA | Файли в робочому каталозі комп'ютера | InformationRegister |
