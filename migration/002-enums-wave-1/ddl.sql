-- =============================================================================
-- Батч 002: перечислення (хвиля 1) — уніфікована lookup-таблиця RSD_ENUMS
-- Одна таблиця на всі 241 перечислень дампу (1326 значень).
-- Виконувати з NLS_LANG=.AL32UTF8. Повторюваний (DROP IF EXISTS).
-- =============================================================================
DROP TABLE IF EXISTS RSD_ENUMS CASCADE CONSTRAINTS;

CREATE TABLE RSD_ENUMS (
    ID          NUMBER GENERATED ALWAYS AS IDENTITY,
    ENUM_TYPE   VARCHAR2(100 CHAR) NOT NULL,   -- імʼя перечислення 1С (техн. ключ)
    VALUE_KEY   VARCHAR2(150 CHAR) NOT NULL,   -- імʼя значення 1С (техн. ключ для звірки даних)
    NAME        VARCHAR2(255 CHAR) NOT NULL,   -- підпис (uk)
    SORT_ORDER  NUMBER             NOT NULL,
    IS_DELETED  BOOLEAN DEFAULT FALSE NOT NULL,
    CONSTRAINT RSD_ENUMS_PK PRIMARY KEY (ID),
    CONSTRAINT RSD_ENUMS_UK UNIQUE (ENUM_TYPE, VALUE_KEY)
);

COMMENT ON TABLE RSD_ENUMS IS 'Значення перечислень 1С (уніфікований довідник; FK-ціль для <X>_ID колонок, LOV фільтрує за ENUM_TYPE)';
COMMENT ON COLUMN RSD_ENUMS.ENUM_TYPE IS 'Імʼя перечислення 1С — технічний ключ типу';
COMMENT ON COLUMN RSD_ENUMS.VALUE_KEY IS 'Імʼя значення 1С — технічний ключ для звірки при завантаженні даних';
COMMENT ON COLUMN RSD_ENUMS.NAME IS 'Підпис значення (українською)';
COMMENT ON COLUMN RSD_ENUMS.SORT_ORDER IS 'Порядок значень як у джерелі';

CREATE INDEX RSD_ENUMS_IX_TYPE ON RSD_ENUMS (ENUM_TYPE);
