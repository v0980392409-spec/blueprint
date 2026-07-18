-- =============================================================================
-- Батч 001: Будинки (Catalog.RSD_Дома) — DDL
-- Ціль: схема BAS_REVERSE, Oracle Database 26ai (native BOOLEAN, IDENTITY)
-- Виконувати з NLS_LANG=.AL32UTF8 — інакше кириличні коментарі зіпсуються.
-- Повторюваний: спочатку DROP IF EXISTS у зворотному порядку залежностей.
-- =============================================================================

DROP TABLE IF EXISTS RSD_ORGANIZATIONS_CONTACT_INFO CASCADE CONSTRAINTS;
DROP TABLE IF EXISTS RSD_ORGANIZATIONS_ADD_ATTRS CASCADE CONSTRAINTS;
DROP TABLE IF EXISTS RSD_HOUSE_SECTIONS CASCADE CONSTRAINTS;
DROP TABLE IF EXISTS RSD_HOUSES CASCADE CONSTRAINTS;
DROP TABLE IF EXISTS RSD_ORGANIZATIONS CASCADE CONSTRAINTS;

-- -----------------------------------------------------------------------------
-- Організації (Catalog.Организации)
-- -----------------------------------------------------------------------------
CREATE TABLE RSD_ORGANIZATIONS (
    ID                   NUMBER GENERATED ALWAYS AS IDENTITY,
    LEGACY_REF           VARCHAR2(36)       NOT NULL,
    CODE                 VARCHAR2(9 CHAR)   NOT NULL,
    NAME                 VARCHAR2(150 CHAR) NOT NULL,
    TAX_ID               VARCHAR2(12 CHAR),
    EDRPOU_CODE          VARCHAR2(12 CHAR),
    COMMENT_TEXT         CLOB,
    FULL_NAME            CLOB,
    MAIN_BANK_ACCOUNT_ID NUMBER,  -- FK → RSD_BANKOVSKIESCHETA; замкнуто migration/003-nsi-waves-2-4/close-deferred-fks.sql
    DOC_PREFIX           VARCHAR2(2 CHAR),
    ENTITY_KIND_ID       NUMBER             NOT NULL,  -- FK → RSD_ENUMS(ID) enum_type='ЮрФизЛицо'; замикається migration/002-enums-wave-1/close-deferred-fks.sql (був §9.5)
    IS_VAT_PAYER         BOOLEAN DEFAULT FALSE NOT NULL,
    DEVELOPER_ID         NUMBER,  -- FK → RSD_KONTRAGENTY; замкнуто migration/003-nsi-waves-2-4/close-deferred-fks.sql
    IS_DELETED           BOOLEAN DEFAULT FALSE NOT NULL,
    CREATED_AT           TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    CREATED_BY           VARCHAR2(255 CHAR) DEFAULT COALESCE(SYS_CONTEXT('APEX$SESSION','APP_USER'), USER) NOT NULL,
    UPDATED_AT           TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    UPDATED_BY           VARCHAR2(255 CHAR) DEFAULT COALESCE(SYS_CONTEXT('APEX$SESSION','APP_USER'), USER) NOT NULL,
    CONSTRAINT RSD_ORGANIZATIONS_PK PRIMARY KEY (ID),
    CONSTRAINT RSD_ORGANIZATIONS_UK_LEGACY UNIQUE (LEGACY_REF),
    CONSTRAINT RSD_ORGANIZATIONS_UK_CODE UNIQUE (CODE)
);

COMMENT ON TABLE RSD_ORGANIZATIONS IS 'Організації (Catalog.Организации): юридичні та фізичні особи-власники';
COMMENT ON COLUMN RSD_ORGANIZATIONS.ID IS 'Сурогатний первинний ключ';
COMMENT ON COLUMN RSD_ORGANIZATIONS.LEGACY_REF IS 'UUID запису в 1С (Ссылка) — звірка міграції; технічне';
COMMENT ON COLUMN RSD_ORGANIZATIONS.CODE IS 'Код (з 1С, унікальний)';
COMMENT ON COLUMN RSD_ORGANIZATIONS.NAME IS 'Найменування';
COMMENT ON COLUMN RSD_ORGANIZATIONS.TAX_ID IS 'ІПН — ідентифікаційний номер платника податків';
COMMENT ON COLUMN RSD_ORGANIZATIONS.EDRPOU_CODE IS 'Код за ЄДРПОУ';
COMMENT ON COLUMN RSD_ORGANIZATIONS.COMMENT_TEXT IS 'Коментар — будь-яка додаткова інформація';
COMMENT ON COLUMN RSD_ORGANIZATIONS.FULL_NAME IS 'Повне найменування';
COMMENT ON COLUMN RSD_ORGANIZATIONS.MAIN_BANK_ACCOUNT_ID IS 'Основний банківський рахунок (ціль EXTERNAL, констрейнт відкладено)';
COMMENT ON COLUMN RSD_ORGANIZATIONS.DOC_PREFIX IS 'Префікс нумерації документів організації (2 символи)';
COMMENT ON COLUMN RSD_ORGANIZATIONS.ENTITY_KIND_ID IS 'Вид організації (юр/фіз особа; ціль EXTERNAL, констрейнт відкладено); обовʼязкове';
COMMENT ON COLUMN RSD_ORGANIZATIONS.IS_VAT_PAYER IS 'Платник ПДВ';
COMMENT ON COLUMN RSD_ORGANIZATIONS.DEVELOPER_ID IS 'Забудовник (Catalog.Контрагенты, ціль EXTERNAL)';
COMMENT ON COLUMN RSD_ORGANIZATIONS.IS_DELETED IS 'Позначка видалення (мʼяке видалення; технічне)';

CREATE INDEX RSD_ORGANIZATIONS_IX_TAX_ID ON RSD_ORGANIZATIONS (TAX_ID);

-- -----------------------------------------------------------------------------
-- Будинки (Catalog.RSD_Дома)
-- -----------------------------------------------------------------------------
CREATE TABLE RSD_HOUSES (
    ID              NUMBER GENERATED ALWAYS AS IDENTITY,
    LEGACY_REF      VARCHAR2(36)       NOT NULL,
    CODE            VARCHAR2(9 CHAR)   NOT NULL,
    NAME            VARCHAR2(150 CHAR) NOT NULL,
    ORGANIZATION_ID NUMBER,
    HOUSE_ADDRESS   VARCHAR2(300 CHAR) NOT NULL,
    IS_ACTIVE       BOOLEAN DEFAULT TRUE  NOT NULL,
    ITEM_NO         VARCHAR2(30 CHAR),
    IS_HOUSE_ZERO   BOOLEAN DEFAULT FALSE NOT NULL,
    IS_DELETED      BOOLEAN DEFAULT FALSE NOT NULL,
    CREATED_AT      TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    CREATED_BY      VARCHAR2(255 CHAR) DEFAULT COALESCE(SYS_CONTEXT('APEX$SESSION','APP_USER'), USER) NOT NULL,
    UPDATED_AT      TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    UPDATED_BY      VARCHAR2(255 CHAR) DEFAULT COALESCE(SYS_CONTEXT('APEX$SESSION','APP_USER'), USER) NOT NULL,
    CONSTRAINT RSD_HOUSES_PK PRIMARY KEY (ID),
    CONSTRAINT RSD_HOUSES_UK_LEGACY UNIQUE (LEGACY_REF),
    CONSTRAINT RSD_HOUSES_UK_CODE UNIQUE (CODE),
    CONSTRAINT RSD_HOUSES_FK_ORGANIZATION FOREIGN KEY (ORGANIZATION_ID)
        REFERENCES RSD_ORGANIZATIONS (ID)
);

COMMENT ON TABLE RSD_HOUSES IS 'Будинки (Catalog.RSD_Дома): реєстр будинків забудовника';
COMMENT ON COLUMN RSD_HOUSES.ID IS 'Сурогатний первинний ключ';
COMMENT ON COLUMN RSD_HOUSES.LEGACY_REF IS 'UUID запису в 1С (Ссылка) — звірка міграції; технічне';
COMMENT ON COLUMN RSD_HOUSES.CODE IS 'Код (з 1С, унікальний)';
COMMENT ON COLUMN RSD_HOUSES.NAME IS 'Найменування будинку';
COMMENT ON COLUMN RSD_HOUSES.ORGANIZATION_ID IS 'Організація-власник';
COMMENT ON COLUMN RSD_HOUSES.HOUSE_ADDRESS IS 'Адреса будинку (обовʼязкова; у 1С синонім «Область» — див. §9.2 специфікації)';
COMMENT ON COLUMN RSD_HOUSES.IS_ACTIVE IS 'Активність';
COMMENT ON COLUMN RSD_HOUSES.ITEM_NO IS 'Номер будинку';
COMMENT ON COLUMN RSD_HOUSES.IS_HOUSE_ZERO IS 'Будинок 0 (LOT 100)';
COMMENT ON COLUMN RSD_HOUSES.IS_DELETED IS 'Позначка видалення (мʼяке видалення; технічне)';

CREATE INDEX RSD_HOUSES_IX_ORGANIZATION ON RSD_HOUSES (ORGANIZATION_ID);

-- -----------------------------------------------------------------------------
-- Секції (Catalog.RSD_Секции, підпорядкований Будинкам)
-- -----------------------------------------------------------------------------
CREATE TABLE RSD_HOUSE_SECTIONS (
    ID         NUMBER GENERATED ALWAYS AS IDENTITY,
    LEGACY_REF VARCHAR2(36)       NOT NULL,
    OWNER_ID   NUMBER             NOT NULL,
    CODE       VARCHAR2(9 CHAR)   NOT NULL,
    NAME       VARCHAR2(150 CHAR) NOT NULL,
    ITEM_NO    NUMBER(15)         NOT NULL,
    IS_ACTIVE  BOOLEAN DEFAULT TRUE  NOT NULL,
    IS_DELETED BOOLEAN DEFAULT FALSE NOT NULL,
    CREATED_AT TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    CREATED_BY VARCHAR2(255 CHAR) DEFAULT COALESCE(SYS_CONTEXT('APEX$SESSION','APP_USER'), USER) NOT NULL,
    UPDATED_AT TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    UPDATED_BY VARCHAR2(255 CHAR) DEFAULT COALESCE(SYS_CONTEXT('APEX$SESSION','APP_USER'), USER) NOT NULL,
    CONSTRAINT RSD_HOUSE_SECTIONS_PK PRIMARY KEY (ID),
    CONSTRAINT RSD_HOUSE_SECTIONS_UK_LEGACY UNIQUE (LEGACY_REF),
    CONSTRAINT RSD_HOUSE_SECTIONS_UK_CODE UNIQUE (CODE),
    CONSTRAINT RSD_HOUSE_SECTIONS_FK_OWNER FOREIGN KEY (OWNER_ID)
        REFERENCES RSD_HOUSES (ID),
    CONSTRAINT RSD_HOUSE_SECTIONS_CK_ITEM_NO CHECK (ITEM_NO >= 0)
);

COMMENT ON TABLE RSD_HOUSE_SECTIONS IS 'Секції будинків (Catalog.RSD_Секции, підпорядкований довідник)';
COMMENT ON COLUMN RSD_HOUSE_SECTIONS.ID IS 'Сурогатний первинний ключ';
COMMENT ON COLUMN RSD_HOUSE_SECTIONS.LEGACY_REF IS 'UUID запису в 1С (Ссылка) — звірка міграції; технічне';
COMMENT ON COLUMN RSD_HOUSE_SECTIONS.OWNER_ID IS 'Будинок-власник секції';
COMMENT ON COLUMN RSD_HOUSE_SECTIONS.CODE IS 'Код (з 1С, унікальний у довіднику)';
COMMENT ON COLUMN RSD_HOUSE_SECTIONS.NAME IS 'Найменування секції';
COMMENT ON COLUMN RSD_HOUSE_SECTIONS.ITEM_NO IS 'Номер секції (обовʼязковий, невідʼємний)';
COMMENT ON COLUMN RSD_HOUSE_SECTIONS.IS_ACTIVE IS 'Активність';
COMMENT ON COLUMN RSD_HOUSE_SECTIONS.IS_DELETED IS 'Позначка видалення (мʼяке видалення; технічне)';

CREATE INDEX RSD_HOUSE_SECTIONS_IX_OWNER ON RSD_HOUSE_SECTIONS (OWNER_ID);

-- -----------------------------------------------------------------------------
-- Організації: додаткові реквізити (ТЧ ДополнительныеРеквизиты)
-- -----------------------------------------------------------------------------
CREATE TABLE RSD_ORGANIZATIONS_ADD_ATTRS (
    ID              NUMBER GENERATED ALWAYS AS IDENTITY,
    ORGANIZATION_ID NUMBER NOT NULL,
    LINE_NO         NUMBER NOT NULL,
    PROPERTY_ID     NUMBER,  -- FK deferred: ChartOfCharacteristicTypes.ДополнительныеРеквизитыИСведения is EXTERNAL
    TEXT_VALUE      CLOB,
    CONSTRAINT RSD_ORG_ADD_ATTRS_PK PRIMARY KEY (ID),
    CONSTRAINT RSD_ORG_ADD_ATTRS_UK_LINE UNIQUE (ORGANIZATION_ID, LINE_NO),
    CONSTRAINT RSD_ORG_ADD_ATTRS_FK_ORG FOREIGN KEY (ORGANIZATION_ID)
        REFERENCES RSD_ORGANIZATIONS (ID) ON DELETE CASCADE
);

COMMENT ON TABLE RSD_ORGANIZATIONS_ADD_ATTRS IS 'Додаткові реквізити організацій (таблична частина); колонки Значення немає — див. §9.1 специфікації';
COMMENT ON COLUMN RSD_ORGANIZATIONS_ADD_ATTRS.ORGANIZATION_ID IS 'Організація';
COMMENT ON COLUMN RSD_ORGANIZATIONS_ADD_ATTRS.LINE_NO IS 'Номер рядка';
COMMENT ON COLUMN RSD_ORGANIZATIONS_ADD_ATTRS.PROPERTY_ID IS 'Властивість — додатковий реквізит (ціль EXTERNAL)';
COMMENT ON COLUMN RSD_ORGANIZATIONS_ADD_ATTRS.TEXT_VALUE IS 'Текстовий рядок — повний текст строкового додаткового реквізиту';

-- -----------------------------------------------------------------------------
-- Організації: контактна інформація (ТЧ КонтактнаяИнформация)
-- -----------------------------------------------------------------------------
CREATE TABLE RSD_ORGANIZATIONS_CONTACT_INFO (
    ID                 NUMBER GENERATED ALWAYS AS IDENTITY,
    ORGANIZATION_ID    NUMBER NOT NULL,
    LINE_NO            NUMBER NOT NULL,
    TYPE_ID            NUMBER,  -- FK deferred: Enum.ТипыКонтактнойИнформации is EXTERNAL
    KIND_ID            NUMBER,  -- FK deferred: Catalog.ВидыКонтактнойИнформации is EXTERNAL
    PRESENTATION       VARCHAR2(500 CHAR),
    FIELD_VALUES       CLOB,
    COUNTRY            VARCHAR2(100 CHAR),
    REGION             VARCHAR2(50 CHAR),
    CITY               VARCHAR2(50 CHAR),
    EMAIL_ADDRESS      VARCHAR2(100 CHAR),
    SERVER_DOMAIN      VARCHAR2(100 CHAR),
    PHONE_NUMBER       VARCHAR2(20 CHAR),
    PHONE_NUMBER_LOCAL VARCHAR2(20 CHAR),
    LIST_KIND_ID       NUMBER,  -- FK deferred: Catalog.ВидыКонтактнойИнформации is EXTERNAL
    VALID_FROM         DATE,
    CONSTRAINT RSD_ORG_CONTACT_INFO_PK PRIMARY KEY (ID),
    CONSTRAINT RSD_ORG_CONTACT_INFO_UK_LINE UNIQUE (ORGANIZATION_ID, LINE_NO),
    CONSTRAINT RSD_ORG_CONTACT_INFO_FK_ORG FOREIGN KEY (ORGANIZATION_ID)
        REFERENCES RSD_ORGANIZATIONS (ID) ON DELETE CASCADE
);

COMMENT ON TABLE RSD_ORGANIZATIONS_CONTACT_INFO IS 'Контактна інформація організацій (таблична частина)';
COMMENT ON COLUMN RSD_ORGANIZATIONS_CONTACT_INFO.ORGANIZATION_ID IS 'Організація';
COMMENT ON COLUMN RSD_ORGANIZATIONS_CONTACT_INFO.LINE_NO IS 'Номер рядка';
COMMENT ON COLUMN RSD_ORGANIZATIONS_CONTACT_INFO.TYPE_ID IS 'Тип контактної інформації (телефон, адреса тощо; ціль EXTERNAL)';
COMMENT ON COLUMN RSD_ORGANIZATIONS_CONTACT_INFO.KIND_ID IS 'Вид контактної інформації (ціль EXTERNAL)';
COMMENT ON COLUMN RSD_ORGANIZATIONS_CONTACT_INFO.PRESENTATION IS 'Представлення контактної інформації для відображення у формах';
COMMENT ON COLUMN RSD_ORGANIZATIONS_CONTACT_INFO.FIELD_VALUES IS 'Службове поле зберігання контактної інформації';
COMMENT ON COLUMN RSD_ORGANIZATIONS_CONTACT_INFO.COUNTRY IS 'Країна (для адреси)';
COMMENT ON COLUMN RSD_ORGANIZATIONS_CONTACT_INFO.REGION IS 'Регіон (для адреси)';
COMMENT ON COLUMN RSD_ORGANIZATIONS_CONTACT_INFO.CITY IS 'Місто (для адреси)';
COMMENT ON COLUMN RSD_ORGANIZATIONS_CONTACT_INFO.EMAIL_ADDRESS IS 'Адреса електронної пошти';
COMMENT ON COLUMN RSD_ORGANIZATIONS_CONTACT_INFO.SERVER_DOMAIN IS 'Доменне імʼя сервера пошти або веб-сторінки';
COMMENT ON COLUMN RSD_ORGANIZATIONS_CONTACT_INFO.PHONE_NUMBER IS 'Повний номер телефону';
COMMENT ON COLUMN RSD_ORGANIZATIONS_CONTACT_INFO.PHONE_NUMBER_LOCAL IS 'Номер телефону без кодів і додаткового номера';
COMMENT ON COLUMN RSD_ORGANIZATIONS_CONTACT_INFO.LIST_KIND_ID IS 'Вид контактної інформації для списку (ціль EXTERNAL)';
COMMENT ON COLUMN RSD_ORGANIZATIONS_CONTACT_INFO.VALID_FROM IS 'Дата актуальності контактної інформації';

CREATE INDEX RSD_ORG_CONTACT_INFO_IX_TYPE ON RSD_ORGANIZATIONS_CONTACT_INFO (TYPE_ID);
CREATE INDEX RSD_ORG_CONTACT_INFO_IX_KIND ON RSD_ORGANIZATIONS_CONTACT_INFO (KIND_ID);
