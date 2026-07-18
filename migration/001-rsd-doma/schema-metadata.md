# Table: RSD_HOUSES
Comment: Будинки (Catalog.RSD_Дома): реєстр будинків забудовника

## Columns:
  - ID - NUMBER NOT NULL [pk]
  - LEGACY_REF - VARCHAR2(36) NOT NULL [uk]
  - CODE - VARCHAR2(9 CHAR) NOT NULL [uk]
  - NAME - VARCHAR2(150 CHAR) NOT NULL
  - ORGANIZATION_ID - NUMBER [fk]
  - HOUSE_ADDRESS - VARCHAR2(300 CHAR) NOT NULL
  - IS_ACTIVE - BOOLEAN NOT NULL
  - ITEM_NO - VARCHAR2(30 CHAR)
  - IS_HOUSE_ZERO - BOOLEAN NOT NULL
  - IS_DELETED - BOOLEAN NOT NULL
  - CREATED_AT - TIMESTAMP NOT NULL
  - CREATED_BY - VARCHAR2(255 CHAR) NOT NULL
  - UPDATED_AT - TIMESTAMP NOT NULL
  - UPDATED_BY - VARCHAR2(255 CHAR) NOT NULL

## Column Comments:
  - ID - Сурогатний первинний ключ
  - LEGACY_REF - UUID запису в 1С — технічна колонка звірки міграції
  - CODE - Код з 1С, унікальний
  - NAME - Найменування будинку
  - ORGANIZATION_ID - Організація-власник
  - HOUSE_ADDRESS - Адреса будинку
  - IS_ACTIVE - Ознака активності будинку
  - ITEM_NO - Номер будинку
  - IS_HOUSE_ZERO - Ознака «Будинок 0 (LOT 100)»
  - IS_DELETED - Позначка мʼякого видалення; видалені записи приховуються

## Column Display Attributes:
  - ID
    - description: Сурогатний первинний ключ.
    - display-label: ІД
    - read-only: true
    - semantic-type: identifier
  - LEGACY_REF
    - description: Технічний ключ звірки з 1С; користувачам не показується.
    - display-label: Ключ 1С
    - read-only: true
    - semantic-type: identifier
  - CODE
    - description: Код будинку з 1С.
    - display-label: Код
    - semantic-type: identifier
  - NAME
    - description: Найменування будинку.
    - display-label: Найменування
    - primary-display-column: true
    - value-required: true
  - ORGANIZATION_ID
    - description: Організація-власник будинку.
    - display-label: Організація
  - HOUSE_ADDRESS
    - description: Адреса будинку.
    - display-label: Адреса будинку
    - value-required: true
  - IS_ACTIVE
    - description: Ознака активності будинку.
    - display-label: Активність
  - ITEM_NO
    - description: Номер будинку.
    - display-label: Номер
  - IS_HOUSE_ZERO
    - description: Ознака «Будинок 0 (LOT 100)».
    - display-label: Будинок 0 (LOT 100)
  - IS_DELETED
    - description: Технічна позначка мʼякого видалення.
    - display-label: Позначка видалення
    - read-only: true
  - CREATED_AT
    - description: Момент створення запису (аудит).
    - display-label: Створено
    - read-only: true
    - semantic-type: date_time
    - format-mask: DD.MM.YYYY HH24:MI
  - CREATED_BY
    - description: Автор запису (аудит).
    - display-label: Автор
    - read-only: true
  - UPDATED_AT
    - description: Момент останньої зміни (аудит).
    - display-label: Змінено
    - read-only: true
    - semantic-type: date_time
    - format-mask: DD.MM.YYYY HH24:MI
  - UPDATED_BY
    - description: Автор останньої зміни (аудит).
    - display-label: Змінив
    - read-only: true

## Constraints:
  - RSD_HOUSES_PK - PRIMARY KEY (ID)
  - RSD_HOUSES_UK_LEGACY - UNIQUE (LEGACY_REF)
  - RSD_HOUSES_UK_CODE - UNIQUE (CODE)
  - RSD_HOUSES_FK_ORGANIZATION - FOREIGN KEY (ORGANIZATION_ID) REFERENCES RSD_ORGANIZATIONS (ID)

## Table Attributes:
  - description: Реєстр будинків забудовника; кожен будинок має підпорядковані секції.
  - display-label: Будинки

# Table: RSD_HOUSE_SECTIONS
Comment: Секції будинків (Catalog.RSD_Секции, підпорядкований довідник)

## Columns:
  - ID - NUMBER NOT NULL [pk]
  - LEGACY_REF - VARCHAR2(36) NOT NULL [uk]
  - OWNER_ID - NUMBER NOT NULL [fk]
  - CODE - VARCHAR2(9 CHAR) NOT NULL [uk]
  - NAME - VARCHAR2(150 CHAR) NOT NULL
  - ITEM_NO - NUMBER(15) NOT NULL
  - IS_ACTIVE - BOOLEAN NOT NULL
  - IS_DELETED - BOOLEAN NOT NULL
  - CREATED_AT - TIMESTAMP NOT NULL
  - CREATED_BY - VARCHAR2(255 CHAR) NOT NULL
  - UPDATED_AT - TIMESTAMP NOT NULL
  - UPDATED_BY - VARCHAR2(255 CHAR) NOT NULL

## Column Comments:
  - ID - Сурогатний первинний ключ
  - LEGACY_REF - UUID запису в 1С — технічна колонка звірки міграції
  - OWNER_ID - Будинок, якому належить секція
  - CODE - Код з 1С, унікальний
  - NAME - Найменування секції
  - ITEM_NO - Номер секції, невідʼємний
  - IS_ACTIVE - Ознака активності секції
  - IS_DELETED - Позначка мʼякого видалення

## Column Display Attributes:
  - ID
    - description: Сурогатний первинний ключ.
    - display-label: ІД
    - read-only: true
    - semantic-type: identifier
  - LEGACY_REF
    - description: Технічний ключ звірки з 1С.
    - display-label: Ключ 1С
    - read-only: true
  - OWNER_ID
    - description: Будинок-власник секції.
    - display-label: Будинок
    - value-required: true
  - CODE
    - description: Код секції з 1С.
    - display-label: Код
    - semantic-type: identifier
  - NAME
    - description: Найменування секції.
    - display-label: Найменування
    - primary-display-column: true
    - value-required: true
  - ITEM_NO
    - description: Номер секції (невідʼємне число).
    - display-label: Номер
    - value-required: true
  - IS_ACTIVE
    - description: Ознака активності секції.
    - display-label: Активність
  - IS_DELETED
    - description: Технічна позначка мʼякого видалення.
    - display-label: Позначка видалення
    - read-only: true
  - CREATED_AT
    - description: Момент створення запису (аудит).
    - display-label: Створено
    - read-only: true
    - format-mask: DD.MM.YYYY HH24:MI
  - CREATED_BY
    - description: Автор запису (аудит).
    - display-label: Автор
    - read-only: true
  - UPDATED_AT
    - description: Момент останньої зміни (аудит).
    - display-label: Змінено
    - read-only: true
    - format-mask: DD.MM.YYYY HH24:MI
  - UPDATED_BY
    - description: Автор останньої зміни (аудит).
    - display-label: Змінив
    - read-only: true

## Constraints:
  - RSD_HOUSE_SECTIONS_PK - PRIMARY KEY (ID)
  - RSD_HOUSE_SECTIONS_UK_LEGACY - UNIQUE (LEGACY_REF)
  - RSD_HOUSE_SECTIONS_UK_CODE - UNIQUE (CODE)
  - RSD_HOUSE_SECTIONS_FK_OWNER - FOREIGN KEY (OWNER_ID) REFERENCES RSD_HOUSES (ID)
  - RSD_HOUSE_SECTIONS_CK_ITEM_NO - CHECK (ITEM_NO >= 0)

## Table Attributes:
  - description: Секції будинків; редагуються з картки будинку (master-detail).
  - display-label: Секції

# Table: RSD_ORGANIZATIONS
Comment: Організації (Catalog.Организации): юридичні та фізичні особи-власники

## Columns:
  - ID - NUMBER NOT NULL [pk]
  - LEGACY_REF - VARCHAR2(36) NOT NULL [uk]
  - CODE - VARCHAR2(9 CHAR) NOT NULL [uk]
  - NAME - VARCHAR2(150 CHAR) NOT NULL
  - TAX_ID - VARCHAR2(12 CHAR)
  - EDRPOU_CODE - VARCHAR2(12 CHAR)
  - COMMENT_TEXT - CLOB
  - FULL_NAME - CLOB
  - MAIN_BANK_ACCOUNT_ID - NUMBER
  - DOC_PREFIX - VARCHAR2(2 CHAR)
  - ENTITY_KIND_ID - NUMBER NOT NULL
  - IS_VAT_PAYER - BOOLEAN NOT NULL
  - DEVELOPER_ID - NUMBER
  - IS_DELETED - BOOLEAN NOT NULL
  - CREATED_AT - TIMESTAMP NOT NULL
  - CREATED_BY - VARCHAR2(255 CHAR) NOT NULL
  - UPDATED_AT - TIMESTAMP NOT NULL
  - UPDATED_BY - VARCHAR2(255 CHAR) NOT NULL

## Column Comments:
  - ID - Сурогатний первинний ключ
  - LEGACY_REF - UUID запису в 1С — технічна колонка звірки міграції
  - CODE - Код з 1С, унікальний
  - NAME - Найменування організації
  - TAX_ID - ІПН — ідентифікаційний номер платника податків
  - EDRPOU_CODE - Код за ЄДРПОУ
  - COMMENT_TEXT - Коментар, будь-яка додаткова інформація
  - FULL_NAME - Повне найменування
  - MAIN_BANK_ACCOUNT_ID - Основний банківський рахунок (довідник поки не мігровано)
  - DOC_PREFIX - Префікс нумерації документів (2 символи)
  - ENTITY_KIND_ID - Вид організації: юридична або фізична особа (довідник поки не мігровано)
  - IS_VAT_PAYER - Платник ПДВ
  - DEVELOPER_ID - Забудовник-контрагент (довідник поки не мігровано)
  - IS_DELETED - Позначка мʼякого видалення

## Column Display Attributes:
  - ID
    - description: Сурогатний первинний ключ.
    - display-label: ІД
    - read-only: true
    - semantic-type: identifier
  - LEGACY_REF
    - description: Технічний ключ звірки з 1С.
    - display-label: Ключ 1С
    - read-only: true
  - CODE
    - description: Код організації з 1С.
    - display-label: Код
    - semantic-type: identifier
  - NAME
    - description: Найменування організації.
    - display-label: Найменування
    - primary-display-column: true
    - value-required: true
  - TAX_ID
    - description: Ідентифікаційний номер платника податків.
    - display-label: ІПН
  - EDRPOU_CODE
    - description: Код за єдиним державним реєстром підприємств і організацій України.
    - display-label: Код за ЄДРПОУ
  - COMMENT_TEXT
    - description: Довільний коментар.
    - display-label: Коментар
  - FULL_NAME
    - description: Повне найменування організації.
    - display-label: Повне найменування
  - MAIN_BANK_ACCOUNT_ID
    - ai-context: Довідник банківських рахунків ще не мігровано; показувати як числовий ідентифікатор, LOV немає.
    - description: Основний банківський рахунок.
    - display-label: Основний банківський рахунок
  - DOC_PREFIX
    - description: Два символи, що додаються на початок номерів документів організації.
    - display-label: Префікс
  - ENTITY_KIND_ID
    - ai-context: Довідник видів організацій (юр/фіз особа) ще не мігровано; показувати як числовий ідентифікатор, LOV немає.
    - description: Вид організації — юридична чи фізична особа.
    - display-label: Вид організації
    - value-required: true
  - IS_VAT_PAYER
    - description: Ознака платника ПДВ.
    - display-label: Платник ПДВ
  - DEVELOPER_ID
    - ai-context: Довідник контрагентів ще не мігровано; показувати як числовий ідентифікатор, LOV немає.
    - description: Контрагент-забудовник.
    - display-label: Забудовник
  - IS_DELETED
    - description: Технічна позначка мʼякого видалення.
    - display-label: Позначка видалення
    - read-only: true
  - CREATED_AT
    - description: Момент створення запису (аудит).
    - display-label: Створено
    - read-only: true
    - format-mask: DD.MM.YYYY HH24:MI
  - CREATED_BY
    - description: Автор запису (аудит).
    - display-label: Автор
    - read-only: true
  - UPDATED_AT
    - description: Момент останньої зміни (аудит).
    - display-label: Змінено
    - read-only: true
    - format-mask: DD.MM.YYYY HH24:MI
  - UPDATED_BY
    - description: Автор останньої зміни (аудит).
    - display-label: Змінив
    - read-only: true

## Constraints:
  - RSD_ORGANIZATIONS_PK - PRIMARY KEY (ID)
  - RSD_ORGANIZATIONS_UK_LEGACY - UNIQUE (LEGACY_REF)
  - RSD_ORGANIZATIONS_UK_CODE - UNIQUE (CODE)

## Table Attributes:
  - description: Організації — юридичні та фізичні особи; мають контактну інформацію та додаткові реквізити в дочірніх таблицях.
  - display-label: Організації

# Table: RSD_ORGANIZATIONS_ADD_ATTRS
Comment: Додаткові реквізити організацій (таблична частина 1С)

## Columns:
  - ID - NUMBER NOT NULL [pk]
  - ORGANIZATION_ID - NUMBER NOT NULL [fk]
  - LINE_NO - NUMBER NOT NULL
  - PROPERTY_ID - NUMBER
  - TEXT_VALUE - CLOB

## Column Comments:
  - ID - Сурогатний первинний ключ
  - ORGANIZATION_ID - Організація
  - LINE_NO - Номер рядка
  - PROPERTY_ID - Властивість — додатковий реквізит (довідник поки не мігровано)
  - TEXT_VALUE - Повний текст строкового додаткового реквізиту

## Column Display Attributes:
  - ID
    - description: Сурогатний первинний ключ.
    - display-label: ІД
    - read-only: true
    - semantic-type: identifier
  - ORGANIZATION_ID
    - description: Організація, якій належить рядок.
    - display-label: Організація
    - value-required: true
  - LINE_NO
    - description: Порядковий номер рядка табличної частини.
    - display-label: № рядка
    - value-required: true
  - PROPERTY_ID
    - ai-context: План видів характеристик ще не мігровано; показувати як числовий ідентифікатор, LOV немає.
    - description: Додатковий реквізит.
    - display-label: Властивість
  - TEXT_VALUE
    - description: Текст строкового додаткового реквізиту.
    - display-label: Текстовий рядок

## Constraints:
  - RSD_ORG_ADD_ATTRS_PK - PRIMARY KEY (ID)
  - RSD_ORG_ADD_ATTRS_UK_LINE - UNIQUE (ORGANIZATION_ID, LINE_NO)
  - RSD_ORG_ADD_ATTRS_FK_ORG - FOREIGN KEY (ORGANIZATION_ID) REFERENCES RSD_ORGANIZATIONS (ID) ON DELETE CASCADE

## Table Attributes:
  - description: Рядки додаткових реквізитів організації; редагуються з картки організації.
  - display-label: Додаткові реквізити

# Table: RSD_ORGANIZATIONS_CONTACT_INFO
Comment: Контактна інформація організацій (таблична частина 1С)

## Columns:
  - ID - NUMBER NOT NULL [pk]
  - ORGANIZATION_ID - NUMBER NOT NULL [fk]
  - LINE_NO - NUMBER NOT NULL
  - TYPE_ID - NUMBER
  - KIND_ID - NUMBER
  - PRESENTATION - VARCHAR2(500 CHAR)
  - FIELD_VALUES - CLOB
  - COUNTRY - VARCHAR2(100 CHAR)
  - REGION - VARCHAR2(50 CHAR)
  - CITY - VARCHAR2(50 CHAR)
  - EMAIL_ADDRESS - VARCHAR2(100 CHAR)
  - SERVER_DOMAIN - VARCHAR2(100 CHAR)
  - PHONE_NUMBER - VARCHAR2(20 CHAR)
  - PHONE_NUMBER_LOCAL - VARCHAR2(20 CHAR)
  - LIST_KIND_ID - NUMBER
  - VALID_FROM - DATE

## Column Comments:
  - ID - Сурогатний первинний ключ
  - ORGANIZATION_ID - Організація
  - LINE_NO - Номер рядка
  - TYPE_ID - Тип контактної інформації: телефон, адреса тощо (перечислення поки не мігровано)
  - KIND_ID - Вид контактної інформації (довідник поки не мігровано)
  - PRESENTATION - Представлення для відображення у формах
  - FIELD_VALUES - Службове поле зберігання контактної інформації
  - COUNTRY - Країна (для адреси)
  - REGION - Регіон (для адреси)
  - CITY - Місто (для адреси)
  - EMAIL_ADDRESS - Адреса електронної пошти
  - SERVER_DOMAIN - Доменне імʼя сервера пошти або веб-сторінки
  - PHONE_NUMBER - Повний номер телефону
  - PHONE_NUMBER_LOCAL - Номер телефону без кодів
  - LIST_KIND_ID - Вид контактної інформації для списку (довідник поки не мігровано)
  - VALID_FROM - Дата актуальності контактної інформації

## Column Display Attributes:
  - ID
    - description: Сурогатний первинний ключ.
    - display-label: ІД
    - read-only: true
    - semantic-type: identifier
  - ORGANIZATION_ID
    - description: Організація, якій належить рядок.
    - display-label: Організація
    - value-required: true
  - LINE_NO
    - description: Порядковий номер рядка табличної частини.
    - display-label: № рядка
    - value-required: true
  - TYPE_ID
    - ai-context: Перечислення типів контактної інформації ще не мігровано; показувати як числовий ідентифікатор, LOV немає.
    - description: Тип контактної інформації.
    - display-label: Тип
  - KIND_ID
    - ai-context: Довідник видів контактної інформації ще не мігровано; показувати як числовий ідентифікатор, LOV немає.
    - description: Вид контактної інформації.
    - display-label: Вид
  - PRESENTATION
    - description: Готове до показу представлення контактної інформації.
    - display-label: Представлення
    - primary-display-column: true
  - FIELD_VALUES
    - description: Службове сховище значень полів; користувачам не показується.
    - display-label: Значення полів
    - read-only: true
  - COUNTRY
    - description: Країна адреси.
    - display-label: Країна
  - REGION
    - description: Регіон адреси.
    - display-label: Регіон
  - CITY
    - description: Місто адреси.
    - display-label: Місто
  - EMAIL_ADDRESS
    - description: Адреса електронної пошти.
    - display-label: Адреса ЕП
    - semantic-type: email_address
  - SERVER_DOMAIN
    - description: Доменне імʼя сервера.
    - display-label: Доменне імʼя сервера
  - PHONE_NUMBER
    - description: Повний номер телефону.
    - display-label: Номер телефону
    - semantic-type: phone_number
  - PHONE_NUMBER_LOCAL
    - description: Номер телефону без кодів.
    - display-label: Номер без кодів
    - semantic-type: phone_number
  - LIST_KIND_ID
    - ai-context: Довідник видів контактної інформації ще не мігровано; показувати як числовий ідентифікатор, LOV немає.
    - description: Вид контактної інформації для списку.
    - display-label: Вид для списку
  - VALID_FROM
    - description: Дата, з якої контактна інформація актуальна.
    - display-label: Діє з
    - semantic-type: date
    - format-mask: DD.MM.YYYY

## Constraints:
  - RSD_ORG_CONTACT_INFO_PK - PRIMARY KEY (ID)
  - RSD_ORG_CONTACT_INFO_UK_LINE - UNIQUE (ORGANIZATION_ID, LINE_NO)
  - RSD_ORG_CONTACT_INFO_FK_ORG - FOREIGN KEY (ORGANIZATION_ID) REFERENCES RSD_ORGANIZATIONS (ID) ON DELETE CASCADE

## Table Attributes:
  - description: Рядки контактної інформації організації; редагуються з картки організації.
  - display-label: Контактна інформація
