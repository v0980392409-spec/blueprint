# Батч 014 «Погодження» — функціональні вимоги (EARS)

## 1. Scope

REQ-1.1 The system shall provide an Oracle APEX application module for browsing,
analyzing, and maintaining approval processes (погодження) in the BAS_REVERSE
schema.
REQ-1.2 The system shall use only the following objects as persistent data
sources: view `RSD_V_SOGLASOVANIE` (approval list and analytics), base table
`RSD_SOGLASOVANIE` (approval form), view `RSD_V_SOGLAS_ISPOLNITELI` (approver
sheet detail report), and view `RSD_V_SOGLAS_REZULTATY` (approval results detail
report).
REQ-1.3 The system shall not require any additional tables, views, or columns
beyond the objects defined in the supplied schema metadata; the reference
objects `RSD_POLZOVATELI` and `RSD_ENUMS` are used only as list-of-values
sources.
REQ-1.4 All user-facing labels, page names, menu entries, and messages shall be
in Ukrainian, using the display-labels from the schema metadata.
REQ-1.5 Wherever dates are displayed, the format mask `DD.MM.YYYY` shall be used,
with `HH24:MI` appended for timestamps.
REQ-1.6 The columns `ID`, `LEGACY_REF`, `IS_DELETED`, `OWNER_ID`, and all audit
columns are technical: the system shall not display them in reports and shall not
offer them as editable form fields, except that `ID` may serve as the hidden
primary key and link key.
REQ-1.7 Every report, list, and analytic in the application shall operate on the
supplied views, which already exclude soft-deleted approval records.

## 2. Global navigation

REQ-2.1 The system shall provide top-level main menu navigation for the following
non-modal pages only, in this order: Дашборд, Погодження.
REQ-2.2 The system shall expose the approval form as a modal page reached through
row actions on the Погодження list, not as a main menu entry.
REQ-2.3 When a user launches the approval form from the list, the system shall
return the user to the list after save or cancel.

## 3. Lists of Values

REQ-3.1 The system shall define a shared list of values `LOV_POLZOVATELI` with
the SQL source
`select NAME as display, ID as return from RSD_POLZOVATELI where IS_DELETED = false order by NAME`.
REQ-3.2 The system shall define a shared list of values `LOV_SOSTOYANIE` with the
SQL source
`select NAME as display, ID as return from RSD_ENUMS where ENUM_TYPE = 'СостоянияБизнесПроцессов' and IS_DELETED = false order by SORT_ORDER, NAME`.
REQ-3.3 The system shall define a shared list of values `LOV_REZULTAT` with the
SQL source
`select NAME as display, ID as return from RSD_ENUMS where ENUM_TYPE = 'РезультатыСогласования' and IS_DELETED = false order by SORT_ORDER, NAME`.
REQ-3.4 The system shall define a shared list of values `LOV_VARIANT` with the SQL
source
`select NAME as display, ID as return from RSD_ENUMS where ENUM_TYPE = 'ВариантыМаршрутизацииЗадач' and IS_DELETED = false order by SORT_ORDER, NAME`.
REQ-3.5 The system shall define a shared list of values `LOV_VAZHNOST` with the SQL
source
`select NAME as display, ID as return from RSD_ENUMS where ENUM_TYPE = 'ВариантыВажностиЗадачи' and IS_DELETED = false order by SORT_ORDER, NAME`.

## 4. Pages

### 4.1 Дашборд (home)

REQ-4.1.1 The system shall provide a home page «Дашборд» presenting analytics over
`RSD_V_SOGLASOVANIE`.
REQ-4.1.2 The page shall display four badge/KPI cards: «Усього погоджень» (count of
all rows), «Активних» (rows where `SOSTOYANIE_NAME` = 'Активний'), «Погоджено»
(rows where `REZULTAT_NAME` = 'Погоджено'), and «Не погоджено» (rows where
`REZULTAT_NAME` = 'Не погоджено').
REQ-4.1.3 The page shall display a chart «Погодження за станом» grouping the row
count by `SOSTOYANIE_NAME`.
REQ-4.1.4 The page shall display a chart «Погодження за результатом» grouping the
row count by `REZULTAT_NAME`, treating rows with no result as «Без результату».
REQ-4.1.5 The page shall display a chart «Погодження за варіантом» grouping the row
count by `VARIANT_NAME`.

### 4.2 Погодження (list)

REQ-4.2.1 The system shall provide a page «Погодження» with a Faceted Search report
over `RSD_V_SOGLASOVANIE`.
REQ-4.2.2 The report shall display these columns: Найменування, Автор
(`AVTOR_NAME`), Стан (`SOSTOYANIE_NAME`), Результат (`REZULTAT_NAME`), Варіант
погодження (`VARIANT_NAME`), Важливість (`VAZHNOST_NAME`), Дата початку
(`DATANACHALA`), Строк виконання (`SROKISPOLNENIYAPROTSESSA`).
REQ-4.2.3 The faceted filters shall include, as checkbox/list facets over the
resolved text columns: Стан (`SOSTOYANIE_NAME`), Результат (`REZULTAT_NAME`),
Варіант погодження (`VARIANT_NAME`), Важливість (`VAZHNOST_NAME`), Автор
(`AVTOR_NAME`).
REQ-4.2.4 The faceted search built-in search input shall search over Найменування.
REQ-4.2.5 Each report row shall provide an edit link opening the approval form
(section 4.3) for the selected process, passing `ID`.
REQ-4.2.6 The report shall be ordered by `DATANACHALA` descending by default.

### 4.3 Погодження (form)

REQ-4.3.1 The system shall provide a modal form page «Погодження» over
`RSD_SOGLASOVANIE` for editing the header of an approval process.
REQ-4.3.2 The form shall include these fields in this order: Найменування, Дата
документа, Автор, Стан, Результат, Варіант погодження, Важливість, Дата початку,
Дата завершення, Строк виконання, Опис, Повторне погодження, Підписувати ЕП.
REQ-4.3.3 The field Автор shall render as a select list using `LOV_POLZOVATELI`;
Стан using `LOV_SOSTOYANIE`; Результат using `LOV_REZULTAT`; Варіант погодження
using `LOV_VARIANT`; Важливість using `LOV_VAZHNOST`.
REQ-4.3.4 The fields Найменування, Автор, Стан, and Варіант погодження shall be
required.
REQ-4.3.5 The field Опис shall render as a textarea; Повторне погодження and
Підписувати ЕП shall render as switches.
REQ-4.3.6 The form page shall contain a read-only detail region «Аркуш погодження»
as a classic report over `RSD_V_SOGLAS_ISPOLNITELI` filtered by the current
process (`OWNER_ID` = the form's `ID`), with columns: № (`LINE_NO`), Тип
(`ISPOLNITEL_TYPE`), Виконавець (`ISPOLNITEL_NAME`), Порядок (`PORYADOK_NAME`),
Пройдено (`PROYDEN_LABEL`), Строк (`SROKISPOLNENIYA`), ordered by `LINE_NO`.
REQ-4.3.7 The form page shall contain a read-only detail region «Результати
погодження» as a classic report over `RSD_V_SOGLAS_REZULTATY` filtered by the
current process (`OWNER_ID` = the form's `ID`), with columns: № (`LINE_NO`),
Ітерація (`NOMERITERATSII`), Результат (`REZULTAT_NAME`), ordered by `LINE_NO`.
REQ-4.3.8 The two detail regions shall not offer create, edit, or delete actions;
they present historical migrated data for review only.
REQ-4.3.9 When the current process has no rows in a detail region, that region
shall display an empty-state message rather than an error.

## 5. Roles

REQ-5.1 The system shall define three roles: ADMIN (full access including delete on
the approval header), CONTRIBUTOR (create and edit the approval header, no delete),
READER (read only).
REQ-5.2 The pages Дашборд, Погодження shall be visible to all three roles; the
create and edit actions on the approval form shall require CONTRIBUTOR or ADMIN;
delete shall require ADMIN.
