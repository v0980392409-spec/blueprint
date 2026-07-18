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
