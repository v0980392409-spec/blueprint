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
