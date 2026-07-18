# Батч 001 «Будинки» — функціональні вимоги (EARS)

## 1. Scope

REQ-1.1 The system shall provide an Oracle APEX application module for managing
houses (будинки), their sections (секції), and organizations (організації) in
the BAS_REVERSE schema.
REQ-1.2 The system shall use only the following base tables as persistent data
sources: `RSD_HOUSES`, `RSD_HOUSE_SECTIONS`, `RSD_ORGANIZATIONS`,
`RSD_ORGANIZATIONS_ADD_ATTRS`, `RSD_ORGANIZATIONS_CONTACT_INFO`.
REQ-1.3 The system shall not require any additional tables, views, or columns
beyond the objects defined in the supplied schema metadata.
REQ-1.4 All user-facing labels, page names, menu entries, and messages shall be
in Ukrainian, using the display-labels from the schema metadata.
REQ-1.5 Wherever dates are displayed, the format mask `DD.MM.YYYY` shall be
used (with `HH24:MI` appended for timestamps).
REQ-1.6 The columns `LEGACY_REF`, `IS_DELETED`, `FIELD_VALUES`, `CREATED_AT`,
`CREATED_BY`, `UPDATED_AT`, `UPDATED_BY` are technical: the system shall not
display them in reports and shall not offer them as editable form fields.
REQ-1.7 Every report and list in the application shall exclude rows where
`IS_DELETED` is true.
REQ-1.8 The system shall treat the columns `ENTITY_KIND_ID`,
`MAIN_BANK_ACCOUNT_ID`, `DEVELOPER_ID`, `PROPERTY_ID`, `TYPE_ID`, `KIND_ID`,
`LIST_KIND_ID` as plain numeric inputs without lists of values, because their
target reference tables are not migrated yet.

## 2. Global navigation

REQ-2.1 The system shall provide top-level main menu navigation for the
following non-modal pages only, in this order: Будинки, Організації.
REQ-2.2 The system shall expose all modal form pages through row actions and
create actions rather than main menu entries.
REQ-2.3 When a user launches a modal form from a source page, the system shall
return the user to the launching page after save or cancel.
REQ-2.4 When a user attempts to delete a row that is still referenced by
related child data, the system shall prevent the delete and explain that the
dependent data must be removed first.

## 3. Pages

### 3.1 Будинки (list)

REQ-3.1.1 The system shall provide a page «Будинки» with an Interactive Report
over `RSD_HOUSES`.
REQ-3.1.2 The report shall display: Код, Найменування, Організація (as
`ORGANIZATION_ID` joined to `RSD_ORGANIZATIONS.NAME` labeled «Організація»),
Адреса будинку, Номер, Активність, Будинок 0 (LOT 100).
REQ-3.1.3 The report shall provide filters on Організація and Активність.
REQ-3.1.4 Each report row shall provide an edit link opening the house form;
the page shall provide a create action «Створити будинок».

### 3.2 Будинок (form)

REQ-3.2.1 The system shall provide a modal form page «Будинок» over
`RSD_HOUSES` for create and edit.
REQ-3.2.2 The form shall include fields: Код, Найменування, Організація,
Адреса будинку, Номер, Активність, Будинок 0 (LOT 100).
REQ-3.2.3 The fields Найменування and Адреса будинку shall be required.
REQ-3.2.4 The form page shall contain an editable Interactive Grid «Секції»
over `RSD_HOUSE_SECTIONS` filtered by the current house (`OWNER_ID`), with
columns: Код, Найменування, Номер, Активність, ordered by Номер.
REQ-3.2.5 In the «Секції» grid the fields Найменування and Номер shall be
required, and Номер shall reject negative values.

### 3.3 Організації (list)

REQ-3.3.1 The system shall provide a page «Організації» with a Faceted Search
report over `RSD_ORGANIZATIONS`.
REQ-3.3.2 The report shall display: Код, Найменування, ІПН, Код за ЄДРПОУ,
Префікс, Платник ПДВ.
REQ-3.3.3 The faceted filters shall include: Платник ПДВ, and search over
Найменування, ІПН, Код за ЄДРПОУ.
REQ-3.3.4 Each report row shall provide an edit link opening the organization
form; the page shall provide a create action «Створити організацію».

### 3.4 Організація (form)

REQ-3.4.1 The system shall provide a modal form page «Організація» over
`RSD_ORGANIZATIONS` for create and edit.
REQ-3.4.2 The form shall include fields: Код, Найменування, Повне
найменування, ІПН, Код за ЄДРПОУ, Вид організації, Платник ПДВ, Префікс,
Основний банківський рахунок, Забудовник, Коментар.
REQ-3.4.3 The fields Найменування and Вид організації shall be required.
REQ-3.4.4 The form page shall contain an editable Interactive Grid «Контактна
інформація» over `RSD_ORGANIZATIONS_CONTACT_INFO` filtered by the current
organization, with columns: № рядка, Тип, Вид, Представлення, Країна, Регіон,
Місто, Адреса ЕП, Номер телефону, Діє з.
REQ-3.4.5 The form page shall contain an editable Interactive Grid «Додаткові
реквізити» over `RSD_ORGANIZATIONS_ADD_ATTRS` filtered by the current
organization, with columns: № рядка, Властивість, Текстовий рядок.

## 4. Roles

REQ-4.1 The system shall define three roles: ADMIN (full access including
delete), CONTRIBUTOR (create and edit, no delete), READER (read only).
REQ-4.2 Pages «Будинки» and «Організації» shall be visible to all three roles;
create and edit actions shall require CONTRIBUTOR or ADMIN.
