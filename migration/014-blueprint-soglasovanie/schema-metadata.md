# Table: RSD_V_SOGLASOVANIE
Comment: Погодження — звітна проекція (BusinessProcess.Согласование з резолвленими підписами); джерело для списку та дашборда

## Columns:
  - ID - NUMBER NOT NULL [pk]
  - NAIMENOVANIE - VARCHAR2(150 CHAR)
  - DOC_DATE - TIMESTAMP
  - DATANACHALA - TIMESTAMP
  - DATAZAVERSHENIYA - TIMESTAMP
  - SROKISPOLNENIYAPROTSESSA - TIMESTAMP
  - OPISANIE - CLOB
  - AVTOR_NAME - VARCHAR2(150 CHAR)
  - SOSTOYANIE_NAME - VARCHAR2(150 CHAR)
  - REZULTAT_NAME - VARCHAR2(150 CHAR)
  - VARIANT_NAME - VARCHAR2(150 CHAR)
  - VAZHNOST_NAME - VARCHAR2(150 CHAR)
  - POVTORIT_LABEL - VARCHAR2(6 CHAR)
  - PODPISYVAT_LABEL - VARCHAR2(6 CHAR)

## Column Comments:
  - ID - Сурогатний ключ процесу погодження
  - NAIMENOVANIE - Найменування (тема) погодження
  - DOC_DATE - Дата документа
  - DATANACHALA - Дата початку процесу
  - DATAZAVERSHENIYA - Дата завершення процесу
  - SROKISPOLNENIYAPROTSESSA - Строк виконання процесу
  - OPISANIE - Опис
  - AVTOR_NAME - Автор (резолвлене імʼя користувача)
  - SOSTOYANIE_NAME - Стан бізнес-процесу
  - REZULTAT_NAME - Результат погодження
  - VARIANT_NAME - Варіант маршрутизації
  - VAZHNOST_NAME - Важливість
  - POVTORIT_LABEL - Повторити погодження (Так/Ні)
  - PODPISYVAT_LABEL - Підписувати ЕП (Так/Ні)

## Column Display Attributes:
  - ID
    - description: Сурогатний ключ процесу.
    - display-label: ІД
    - read-only: true
    - semantic-type: identifier
  - NAIMENOVANIE
    - description: Найменування (тема) погодження.
    - display-label: Найменування
    - primary-display-column: true
  - DOC_DATE
    - description: Дата документа.
    - display-label: Дата
    - semantic-type: date_time
    - format-mask: DD.MM.YYYY HH24:MI
  - DATANACHALA
    - description: Дата початку процесу.
    - display-label: Дата початку
    - semantic-type: date_time
    - format-mask: DD.MM.YYYY HH24:MI
  - DATAZAVERSHENIYA
    - description: Дата завершення процесу.
    - display-label: Дата завершення
    - semantic-type: date_time
    - format-mask: DD.MM.YYYY HH24:MI
  - SROKISPOLNENIYAPROTSESSA
    - description: Плановий строк виконання процесу.
    - display-label: Строк виконання
    - semantic-type: date_time
    - format-mask: DD.MM.YYYY HH24:MI
  - OPISANIE
    - description: Опис погодження.
    - display-label: Опис
  - AVTOR_NAME
    - description: Автор процесу погодження.
    - display-label: Автор
  - SOSTOYANIE_NAME
    - description: Поточний стан бізнес-процесу.
    - display-label: Стан
  - REZULTAT_NAME
    - description: Підсумковий результат погодження.
    - display-label: Результат
  - VARIANT_NAME
    - description: Варіант маршрутизації (послідовно / паралельно / змішано).
    - display-label: Варіант погодження
  - VAZHNOST_NAME
    - description: Важливість.
    - display-label: Важливість
  - POVTORIT_LABEL
    - description: Ознака повторного погодження.
    - display-label: Повторне погодження
  - PODPISYVAT_LABEL
    - description: Ознака підписання ЕП.
    - display-label: Підписувати ЕП

## Constraints:
  - (view; key column is ID)

## Table Attributes:
  - description: Звітна проекція процесів погодження з резолвленими підписами автора, стану, результату, варіанта та важливості; лише не видалені записи.
  - display-label: Погодження

# Table: RSD_SOGLASOVANIE
Comment: Погодження (BusinessProcess.Согласование): базова таблиця процесу — джерело форми (редагування шапки)

## Columns:
  - ID - NUMBER NOT NULL [pk]
  - NAIMENOVANIE - VARCHAR2(150 CHAR)
  - DOC_DATE - TIMESTAMP
  - AVTOR_ID - NUMBER [fk]
  - SOSTOYANIE_ID - NUMBER [fk]
  - REZULTATSOGLASOVANIYA_ID - NUMBER [fk]
  - VARIANTSOGLASOVANIYA_ID - NUMBER [fk]
  - VAZHNOST_ID - NUMBER [fk]
  - DATANACHALA - TIMESTAMP
  - DATAZAVERSHENIYA - TIMESTAMP
  - SROKISPOLNENIYAPROTSESSA - TIMESTAMP
  - OPISANIE - CLOB
  - POVTORITSOGLASOVANIE - BOOLEAN
  - PODPISYVATEP - BOOLEAN
  - IS_DELETED - BOOLEAN NOT NULL

## Column Comments:
  - ID - Сурогатний ключ
  - NAIMENOVANIE - Найменування (тема) погодження
  - DOC_DATE - Дата документа
  - AVTOR_ID - Автор (посилання на RSD_POLZOVATELI)
  - SOSTOYANIE_ID - Стан бізнес-процесу (RSD_ENUMS, тип СостоянияБизнесПроцессов)
  - REZULTATSOGLASOVANIYA_ID - Результат погодження (RSD_ENUMS, тип РезультатыСогласования)
  - VARIANTSOGLASOVANIYA_ID - Варіант маршрутизації (RSD_ENUMS, тип ВариантыМаршрутизацииЗадач)
  - VAZHNOST_ID - Важливість (RSD_ENUMS, тип ВариантыВажностиЗадачи)
  - DATANACHALA - Дата початку процесу
  - DATAZAVERSHENIYA - Дата завершення процесу
  - SROKISPOLNENIYAPROTSESSA - Плановий строк виконання процесу
  - OPISANIE - Опис
  - POVTORITSOGLASOVANIE - Повторити погодження
  - PODPISYVATEP - Підписувати ЕП
  - IS_DELETED - Позначка мʼякого видалення

## Column Display Attributes:
  - ID
    - description: Сурогатний ключ процесу.
    - display-label: ІД
    - read-only: true
    - semantic-type: identifier
  - NAIMENOVANIE
    - description: Найменування (тема) погодження.
    - display-label: Найменування
    - primary-display-column: true
    - value-required: true
  - DOC_DATE
    - description: Дата документа.
    - display-label: Дата документа
    - semantic-type: date_time
    - format-mask: DD.MM.YYYY HH24:MI
  - AVTOR_ID
    - ai-context: Список значень LOV_POLZOVATELI над RSD_POLZOVATELI (NAME як відображення, ID як значення).
    - description: Автор процесу погодження.
    - display-label: Автор
    - value-required: true
  - SOSTOYANIE_ID
    - ai-context: Список значень LOV_SOSTOYANIE над RSD_ENUMS з фільтром ENUM_TYPE='СостоянияБизнесПроцессов'.
    - description: Поточний стан бізнес-процесу.
    - display-label: Стан
    - value-required: true
  - REZULTATSOGLASOVANIYA_ID
    - ai-context: Список значень LOV_REZULTAT над RSD_ENUMS з фільтром ENUM_TYPE='РезультатыСогласования'.
    - description: Підсумковий результат погодження.
    - display-label: Результат
  - VARIANTSOGLASOVANIYA_ID
    - ai-context: Список значень LOV_VARIANT над RSD_ENUMS з фільтром ENUM_TYPE='ВариантыМаршрутизацииЗадач'.
    - description: Варіант маршрутизації.
    - display-label: Варіант погодження
    - value-required: true
  - VAZHNOST_ID
    - ai-context: Список значень LOV_VAZHNOST над RSD_ENUMS з фільтром ENUM_TYPE='ВариантыВажностиЗадачи'.
    - description: Важливість.
    - display-label: Важливість
  - DATANACHALA
    - description: Дата початку процесу.
    - display-label: Дата початку
    - semantic-type: date_time
    - format-mask: DD.MM.YYYY HH24:MI
  - DATAZAVERSHENIYA
    - description: Дата завершення процесу.
    - display-label: Дата завершення
    - semantic-type: date_time
    - format-mask: DD.MM.YYYY HH24:MI
  - SROKISPOLNENIYAPROTSESSA
    - description: Плановий строк виконання процесу.
    - display-label: Строк виконання
    - semantic-type: date_time
    - format-mask: DD.MM.YYYY HH24:MI
  - OPISANIE
    - description: Опис погодження.
    - display-label: Опис
  - POVTORITSOGLASOVANIE
    - description: Ознака повторного погодження.
    - display-label: Повторне погодження
  - PODPISYVATEP
    - description: Ознака підписання електронним підписом.
    - display-label: Підписувати ЕП
  - IS_DELETED
    - description: Технічна позначка мʼякого видалення; у формі не показується.
    - display-label: Позначка видалення
    - read-only: true

## Constraints:
  - RSD_SOGLASOVANIE_PK - PRIMARY KEY (ID)
  - RSD_SOGLASOVANIE_UK_LEGACY_REF_ - UNIQUE (LEGACY_REF)
  - RSD_SOGLASOVANIE_FK_AVTOR_ID - FOREIGN KEY (AVTOR_ID) REFERENCES RSD_POLZOVATELI (ID)
  - RSD_SOGLASOVANIE_FK_SOSTOYANIE_ID - FOREIGN KEY (SOSTOYANIE_ID) REFERENCES RSD_ENUMS (ID)
  - RSD_SOGLASOVANIE_FK_REZULTATSOGLASOVANIYA_ID - FOREIGN KEY (REZULTATSOGLASOVANIYA_ID) REFERENCES RSD_ENUMS (ID)
  - RSD_SOGLASOVANIE_FK_VARIANTSOGLASOVANIYA_ID - FOREIGN KEY (VARIANTSOGLASOVANIYA_ID) REFERENCES RSD_ENUMS (ID)
  - RSD_SOGLASOVANIE_FK_VAZHNOST_ID - FOREIGN KEY (VAZHNOST_ID) REFERENCES RSD_ENUMS (ID)

## Table Attributes:
  - description: Процеси погодження (шапка). Форма редагує тему, автора, стан, результат, варіант маршрутизації, важливість, дати, опис і прапорці; технічні та службові поля 1С у форму не виносяться.
  - display-label: Погодження

# Table: RSD_V_SOGLAS_ISPOLNITELI
Comment: Аркуш погодження — виконавці (ТЧ RSD_SOGLASOVANIE_ISPOLNITELI з резолвленим поліморфним виконавцем); детальний звіт, тільки читання

## Columns:
  - ID - NUMBER NOT NULL [pk]
  - OWNER_ID - NUMBER NOT NULL [fk]
  - LINE_NO - NUMBER NOT NULL
  - ISPOLNITEL_TYPE - VARCHAR2(60 CHAR)
  - ISPOLNITEL_NAME - VARCHAR2(150 CHAR)
  - PORYADOK_NAME - VARCHAR2(150 CHAR)
  - PROYDEN_LABEL - VARCHAR2(6 CHAR)
  - SROKISPOLNENIYA - TIMESTAMP

## Column Comments:
  - ID - Ключ рядка
  - OWNER_ID - Процес погодження, якому належить рядок
  - LINE_NO - Номер рядка
  - ISPOLNITEL_TYPE - Тип виконавця (Роль або Користувач)
  - ISPOLNITEL_NAME - Виконавець (імʼя користувача; для ролей порожньо — довідник ролей не мігровано)
  - PORYADOK_NAME - Порядок погодження
  - PROYDEN_LABEL - Крок пройдено (Так/Ні)
  - SROKISPOLNENIYA - Строк виконання кроку

## Column Display Attributes:
  - ID
    - description: Ключ рядка аркуша погодження.
    - display-label: ІД
    - read-only: true
    - semantic-type: identifier
  - OWNER_ID
    - description: Процес погодження, якому належить рядок.
    - display-label: Процес
    - read-only: true
    - semantic-type: identifier
  - LINE_NO
    - description: Порядковий номер рядка.
    - display-label: №
    - read-only: true
  - ISPOLNITEL_TYPE
    - description: Тип виконавця — роль або конкретний користувач.
    - display-label: Тип
    - read-only: true
  - ISPOLNITEL_NAME
    - ai-context: Порожньо для рядків типу «Роль» — довідник повних ролей поки не мігровано.
    - description: Виконавець-користувач.
    - display-label: Виконавець
    - read-only: true
  - PORYADOK_NAME
    - description: Порядок проходження кроку.
    - display-label: Порядок
    - read-only: true
  - PROYDEN_LABEL
    - description: Чи пройдено крок погодження.
    - display-label: Пройдено
    - read-only: true
  - SROKISPOLNENIYA
    - description: Строк виконання кроку.
    - display-label: Строк
    - read-only: true
    - semantic-type: date_time
    - format-mask: DD.MM.YYYY HH24:MI

## Constraints:
  - (view; key column is ID; OWNER_ID links to RSD_V_SOGLASOVANIE.ID / RSD_SOGLASOVANIE.ID)

## Table Attributes:
  - description: Аркуш погодження — упорядкований перелік виконавців кроку з резолвленим поліморфним виконавцем; використовується як детальний звіт «тільки читання» на сторінці погодження.
  - display-label: Аркуш погодження

# Table: RSD_V_SOGLAS_REZULTATY
Comment: Результати погодження (ТЧ RSD_SOGLASOVANIE_REZULTATYSOGLASOVANIYA з резолвленим рішенням); детальний звіт, тільки читання

## Columns:
  - ID - NUMBER NOT NULL [pk]
  - OWNER_ID - NUMBER NOT NULL [fk]
  - LINE_NO - NUMBER NOT NULL
  - NOMERITERATSII - NUMBER(10)
  - REZULTAT_NAME - VARCHAR2(150 CHAR)

## Column Comments:
  - ID - Ключ рядка
  - OWNER_ID - Процес погодження, якому належить рядок
  - LINE_NO - Номер рядка
  - NOMERITERATSII - Номер ітерації погодження
  - REZULTAT_NAME - Рішення (Погоджено / Погоджено із зауваженнями / Не погоджено)

## Column Display Attributes:
  - ID
    - description: Ключ рядка результату.
    - display-label: ІД
    - read-only: true
    - semantic-type: identifier
  - OWNER_ID
    - description: Процес погодження, якому належить рядок.
    - display-label: Процес
    - read-only: true
    - semantic-type: identifier
  - LINE_NO
    - description: Порядковий номер рядка.
    - display-label: №
    - read-only: true
  - NOMERITERATSII
    - description: Номер ітерації погодження.
    - display-label: Ітерація
    - read-only: true
  - REZULTAT_NAME
    - description: Рішення погоджувача.
    - display-label: Результат
    - read-only: true

## Constraints:
  - (view; key column is ID; OWNER_ID links to RSD_V_SOGLASOVANIE.ID / RSD_SOGLASOVANIE.ID)

## Table Attributes:
  - description: Результати погодження по ітераціях; використовується як детальний звіт «тільки читання» на сторінці погодження.
  - display-label: Результати погодження
