# Provenance
- Source Prompt: blueprint-prompt.md (v26.1.220)
- Functional Requirements: fr.md
- Schema Metadata: schema-metadata.md
- UX Patterns: Built-in
# Application Definition
- Name: Погодження
- Description: Погодження application for RSD_V_SOGLASOVANIE, RSD_SOGLASOVANIE, RSD_V_SOGLAS_ISPOLNITELI, RSD_V_SOGLAS_REZULTATY maintenance, hierarchy browsing, reporting, and KPI analytics.
- Comments: Uses RSD_V_SOGLASOVANIE, RSD_SOGLASOVANIE, RSD_V_SOGLAS_ISPOLNITELI, RSD_V_SOGLAS_REZULTATY only for maintenance, hierarchy browsing, reporting, and KPI analytics.
- Primary Application Language: uk
- Home Page: Page 1
- Access Controls:
  - Roles:
    - Role: ADMIN
      - Description: Full access including delete on the approval header, plus browse, edit, and analytics.
    - Role: CONTRIBUTOR
      - Description: Create and edit the approval header; no delete; full browse and analytics access.
    - Role: READER
      - Description: Read-only access to the dashboard, the approval list, and the read-only detail reports.
- List of Values:
  - LOV
    - Name: LOV_POLZOVATELI
    - Type: SQL
    - SQL:
```sql
select p.name as display
     , p.id as return
from rsd_polzovateli p
where p.is_deleted = false
order by p.name
```
    - Display: display
    - Return: return
  - LOV
    - Name: LOV_SOSTOYANIE
    - Type: SQL
    - SQL:
```sql
select e.name as display
     , e.id as return
from rsd_enums e
where e.enum_type = 'СостоянияБизнесПроцессов'
    and e.is_deleted = false
order by e.sort_order, e.name
```
    - Display: display
    - Return: return
  - LOV
    - Name: LOV_REZULTAT
    - Type: SQL
    - SQL:
```sql
select e.name as display
     , e.id as return
from rsd_enums e
where e.enum_type = 'РезультатыСогласования'
    and e.is_deleted = false
order by e.sort_order, e.name
```
    - Display: display
    - Return: return
  - LOV
    - Name: LOV_VARIANT
    - Type: SQL
    - SQL:
```sql
select e.name as display
     , e.id as return
from rsd_enums e
where e.enum_type = 'ВариантыМаршрутизацииЗадач'
    and e.is_deleted = false
order by e.sort_order, e.name
```
    - Display: display
    - Return: return
  - LOV
    - Name: LOV_VAZHNOST
    - Type: SQL
    - SQL:
```sql
select e.name as display
     , e.id as return
from rsd_enums e
where e.enum_type = 'ВариантыВажностиЗадачи'
    and e.is_deleted = false
order by e.sort_order, e.name
```
    - Display: display
    - Return: return
- Page Groups
  - Page Group
    - Name: Погодження
    - Description: Approval process module: dashboard analytics over RSD_V_SOGLASOVANIE, the faceted approval list, and the modal approval process form with its read-only detail reports.
- Menu
  - Menu Name: Navigation Menu
  - Entries:
    - Entry
      - Label: Дашборд
      - Icon: fa-dashboard
      - Action: Navigate
      - Target: Page 1
      - Authorized Roles: ADMIN, CONTRIBUTOR, READER
    - Entry
      - Label: Погодження
      - Icon: fa-handshake-o
      - Action: Navigate
      - Target: Page 2
      - Authorized Roles: ADMIN, CONTRIBUTOR, READER
- Breadcrumb
  - Name: Breadcrumb
  - Entries:
    - Entry
      - Name: Дашборд
      - Page: Page 1
    - Entry
      - Name: Погодження
      - Page: Page 2
## Pages
### Page 1: Дашборд
- Description: Analytics landing page with approval KPIs and distribution charts over RSD_V_SOGLASOVANIE.
- Comments: Home dashboard summarizing the approval registry; four KPI cards and three distribution charts give all roles a read-only overview before drilling into the list.
- Pattern: metric-chart-two-up
- Page Mode: standard
- Menu: true
- Page Group: Погодження
- Security Requirements:
  - Authorized Roles: ADMIN, CONTRIBUTOR, READER
#### Regions
##### Region: Усього погоджень
- Comments: KPI card counting every approval process in RSD_V_SOGLASOVANIE; anchors the dashboard overview for all roles.
- Position: body
- Colstart: 1
- Colspan: 6
- Component:
  - Component Type: Metric Card
- Metric Subtitle: Усі процеси погодження
- Metric Icon: fa-tasks
- Metric Icon Style: default
- Data Source:
  - Type: SQL
  - SQL:
```sql
select count(*) as metric
from rsd_v_soglasovanie s
```
  - Summary: Total count of approval processes in the reporting view.
- Columns:
  - Column Name: METRIC
    - Label: Усього погоджень
    - Datatype: number
    - Render As: metric
    - Visible: true
    - Format Mask: 999G999G999G999G990
##### Region: Активних
- Comments: KPI card counting approvals whose resolved state is Активний; highlights work in progress for all roles.
- Position: body
- Colstart: 7
- Colspan: 6
- Component:
  - Component Type: Metric Card
- Metric Subtitle: Стан: Активний
- Metric Icon: fa-spinner
- Metric Icon Style: default
- Data Source:
  - Type: SQL
  - SQL:
```sql
select count(*) as metric
from rsd_v_soglasovanie s
where s.sostoyanie_name = 'Активний'
```
  - Summary: Count of approval processes currently in the Активний state.
- Columns:
  - Column Name: METRIC
    - Label: Активних
    - Datatype: number
    - Render As: metric
    - Visible: true
    - Format Mask: 999G999G999G999G990
##### Region: Погоджено
- Comments: KPI card counting approvals whose resolved result is Погоджено; measures positive outcomes for all roles.
- Position: body
- Colstart: 1
- Colspan: 6
- Component:
  - Component Type: Metric Card
- Metric Subtitle: Результат: Погоджено
- Metric Icon: fa-check-circle
- Metric Icon Style: default
- Data Source:
  - Type: SQL
  - SQL:
```sql
select count(*) as metric
from rsd_v_soglasovanie s
where s.rezultat_name = 'Погоджено'
```
  - Summary: Count of approval processes with the Погоджено result.
- Columns:
  - Column Name: METRIC
    - Label: Погоджено
    - Datatype: number
    - Render As: metric
    - Visible: true
    - Format Mask: 999G999G999G999G990
##### Region: Не погоджено
- Comments: KPI card counting approvals whose resolved result is Не погоджено; surfaces rejected outcomes for all roles.
- Position: body
- Colstart: 7
- Colspan: 6
- Component:
  - Component Type: Metric Card
- Metric Subtitle: Результат: Не погоджено
- Metric Icon: fa-times-circle
- Metric Icon Style: default
- Data Source:
  - Type: SQL
  - SQL:
```sql
select count(*) as metric
from rsd_v_soglasovanie s
where s.rezultat_name = 'Не погоджено'
```
  - Summary: Count of approval processes with the Не погоджено result.
- Columns:
  - Column Name: METRIC
    - Label: Не погоджено
    - Datatype: number
    - Render As: metric
    - Visible: true
    - Format Mask: 999G999G999G999G990
##### Region: Погодження за станом
- Comments: Bar chart grouping the approval count by resolved business-process state; gives all roles the state distribution.
- Position: body
- Colstart: 1
- Colspan: 6
- Component:
  - Component Type: Chart
  - Qualifier: Bar
- Data Source:
  - Type: SQL
  - SQL:
```sql
select s.sostoyanie_name as label
     , count(*) as value
from rsd_v_soglasovanie s
group by s.sostoyanie_name
order by value desc
```
  - Summary: Approval process counts grouped by resolved state, largest first.
- Columns:
  - Column Name: LABEL
    - Label: Стан
    - Datatype: varchar2
    - Render As: label
  - Column Name: VALUE
    - Label: Кількість
    - Datatype: number
    - Render As: value
##### Region: Погодження за результатом
- Comments: Donut chart grouping the approval count by resolved result; rows with no result are grouped as Без результату for all roles.
- Position: body
- Colstart: 7
- Colspan: 6
- Component:
  - Component Type: Chart
  - Qualifier: Donut
- Data Source:
  - Type: SQL
  - SQL:
```sql
select nvl(s.rezultat_name, 'Без результату') as label
     , count(*) as value
from rsd_v_soglasovanie s
group by nvl(s.rezultat_name, 'Без результату')
order by value desc
```
  - Summary: Approval process counts grouped by resolved result, with the null result labeled Без результату.
- Columns:
  - Column Name: LABEL
    - Label: Результат
    - Datatype: varchar2
    - Render As: label
  - Column Name: VALUE
    - Label: Кількість
    - Datatype: number
    - Render As: value
##### Region: Погодження за варіантом
- Comments: Bar chart grouping the approval count by routing variant; shows the routing-method distribution for all roles.
- Position: body
- Colstart: 1
- Colspan: 6
- Component:
  - Component Type: Chart
  - Qualifier: Bar
- Data Source:
  - Type: SQL
  - SQL:
```sql
select s.variant_name as label
     , count(*) as value
from rsd_v_soglasovanie s
group by s.variant_name
order by value desc
```
  - Summary: Approval process counts grouped by routing variant, largest first.
- Columns:
  - Column Name: LABEL
    - Label: Варіант
    - Datatype: varchar2
    - Render As: label
  - Column Name: VALUE
    - Label: Кількість
    - Datatype: number
    - Render As: value
### Page 2: Погодження
- Description: Faceted search over approval processes with a filterable classic report.
- Comments: Entry list of the approval registry with sidebar facets; the row edit link and the create action open the modal approval form for CONTRIBUTOR and ADMIN, while READER may only browse.
- Pattern: faceted-search
- Page Mode: standard
- Menu: true
- Page Group: Погодження
- Security Requirements:
  - Authorized Roles: ADMIN, CONTRIBUTOR, READER
#### Regions
##### Region: Фільтри погоджень
- Comments: Sidebar facets over the resolved text columns of RSD_V_SOGLASOVANIE; the faceted search built-in search input covers text search over Найменування.
- Position: left-column
- Colstart: 1
- Colspan: 12
- Component:
  - Component Type: Faceted Search
- Filtered Region: Результати пошуку погоджень
- Filters:
  - Filter
    - Name: P2_F_SOSTOYANIE_NAME
    - Label: Стан
    - Render As: checkboxGroup
    - Database Column: SOSTOYANIE_NAME
    - Datatype: varchar2
  - Filter
    - Name: P2_F_REZULTAT_NAME
    - Label: Результат
    - Render As: checkboxGroup
    - Database Column: REZULTAT_NAME
    - Datatype: varchar2
  - Filter
    - Name: P2_F_VARIANT_NAME
    - Label: Варіант погодження
    - Render As: checkboxGroup
    - Database Column: VARIANT_NAME
    - Datatype: varchar2
  - Filter
    - Name: P2_F_VAZHNOST_NAME
    - Label: Важливість
    - Render As: checkboxGroup
    - Database Column: VAZHNOST_NAME
    - Datatype: varchar2
  - Filter
    - Name: P2_F_AVTOR_NAME
    - Label: Автор
    - Render As: checkboxGroup
    - Database Column: AVTOR_NAME
    - Datatype: varchar2
##### Region: Результати пошуку погоджень
- Comments: Classic report over RSD_V_SOGLASOVANIE serving as the faceted search target; the view already excludes soft-deleted rows and each row links to the approval form.
- Position: body
- Colstart: 1
- Colspan: 12
- Component:
  - Component Type: Classic Report
  - Qualifier: Standard
- Data Source:
  - Type: View
  - Name: RSD_V_SOGLASOVANIE
  - Primary Keys: ID
  - Order By: DATANACHALA desc
  - Summary: Approval processes ordered by start date descending; soft-deleted rows are already excluded by the view.
- Columns:
  - Column Name: ID
    - Label: ІД
    - Datatype: number
    - Render As: hidden
  - Column Name: NAIMENOVANIE
    - Label: Найменування
    - Datatype: varchar2
    - Render As: plainText
  - Column Name: AVTOR_NAME
    - Label: Автор
    - Datatype: varchar2
    - Render As: plainText
  - Column Name: SOSTOYANIE_NAME
    - Label: Стан
    - Datatype: varchar2
    - Render As: plainText
  - Column Name: REZULTAT_NAME
    - Label: Результат
    - Datatype: varchar2
    - Render As: plainText
  - Column Name: VARIANT_NAME
    - Label: Варіант погодження
    - Datatype: varchar2
    - Render As: plainText
  - Column Name: VAZHNOST_NAME
    - Label: Важливість
    - Datatype: varchar2
    - Render As: plainText
  - Column Name: DATANACHALA
    - Label: Дата початку
    - Datatype: timestamp
    - Render As: plainText
    - Format Mask: DD.MM.YYYY HH24:MI
  - Column Name: SROKISPOLNENIYAPROTSESSA
    - Label: Строк виконання
    - Datatype: timestamp
    - Render As: plainText
    - Format Mask: DD.MM.YYYY HH24:MI
- Links:
  - Link:
    - Link To: Page 3
    - Link Passing: ID
    - Link Target Items: P3_ID
    - Label: Редагувати
    - Link Icon: fa-edit
    - Authorized Roles: ADMIN, CONTRIBUTOR
- Actions:
  - Action
    - Label: Створити погодження
    - Link To: Page 3
    - slot: CREATE
    - Action Type: navigate
    - Authorized Roles: ADMIN, CONTRIBUTOR
### Page 3: Процес погодження
- Description: Modal form for editing the header of an approval process with two read-only detail reports.
- Comments: Approval process create/edit dialog launched from the Погодження list; save or cancel returns to the list; delete is limited to ADMIN, and the detail reports present migrated approver and result rows for review only.
- Pattern: modal-drawer
- Page Mode: modalDialog
- Menu: false
- Page Group: Погодження
- Security Requirements:
  - Authorized Roles: ADMIN, CONTRIBUTOR
#### Regions
##### Region: Процес погодження
- Comments: Single-record form over RSD_SOGLASOVANIE editing the approval header; Найменування, Автор, Стан, and Варіант погодження are mandatory, and Повторне погодження and Підписувати ЕП are switch-style boolean toggles.
- Position: body
- Colstart: 1
- Colspan: 12
- Component:
  - Component Type: Form
- Data Source:
  - Type: Table
  - Name: RSD_SOGLASOVANIE
  - Primary Keys: ID
  - Summary: Single approval process row addressed by the ID primary key item.
- Columns:
  - Column Name: ID
    - Label: ІД
    - Datatype: number
    - Page Item Name: P3_ID
    - Render As: hidden
  - Column Name: NAIMENOVANIE
    - Label: Найменування
    - Datatype: varchar2
    - Page Item Name: P3_NAIMENOVANIE
    - Render As: textField
    - Required: true
    - MaxLength: 150
  - Column Name: DOC_DATE
    - Label: Дата документа
    - Datatype: timestamp
    - Page Item Name: P3_DOC_DATE
    - Render As: datePicker
    - Format Mask: DD.MM.YYYY HH24:MI
  - Column Name: AVTOR_ID
    - Label: Автор
    - Datatype: number
    - Page Item Name: P3_AVTOR_ID
    - Render As: selectList
    - LOV: LOV_POLZOVATELI
    - Required: true
  - Column Name: SOSTOYANIE_ID
    - Label: Стан
    - Datatype: number
    - Page Item Name: P3_SOSTOYANIE_ID
    - Render As: selectList
    - LOV: LOV_SOSTOYANIE
    - Required: true
  - Column Name: REZULTATSOGLASOVANIYA_ID
    - Label: Результат
    - Datatype: number
    - Page Item Name: P3_REZULTATSOGLASOVANIYA_ID
    - Render As: selectList
    - LOV: LOV_REZULTAT
  - Column Name: VARIANTSOGLASOVANIYA_ID
    - Label: Варіант погодження
    - Datatype: number
    - Page Item Name: P3_VARIANTSOGLASOVANIYA_ID
    - Render As: selectList
    - LOV: LOV_VARIANT
    - Required: true
  - Column Name: VAZHNOST_ID
    - Label: Важливість
    - Datatype: number
    - Page Item Name: P3_VAZHNOST_ID
    - Render As: selectList
    - LOV: LOV_VAZHNOST
  - Column Name: DATANACHALA
    - Label: Дата початку
    - Datatype: timestamp
    - Page Item Name: P3_DATANACHALA
    - Render As: datePicker
    - Format Mask: DD.MM.YYYY HH24:MI
  - Column Name: DATAZAVERSHENIYA
    - Label: Дата завершення
    - Datatype: timestamp
    - Page Item Name: P3_DATAZAVERSHENIYA
    - Render As: datePicker
    - Format Mask: DD.MM.YYYY HH24:MI
  - Column Name: SROKISPOLNENIYAPROTSESSA
    - Label: Строк виконання
    - Datatype: timestamp
    - Page Item Name: P3_SROKISPOLNENIYAPROTSESSA
    - Render As: datePicker
    - Format Mask: DD.MM.YYYY HH24:MI
  - Column Name: OPISANIE
    - Label: Опис
    - Datatype: clob
    - Page Item Name: P3_OPISANIE
    - Render As: textarea
  - Column Name: POVTORITSOGLASOVANIE
    - Label: Повторне погодження
    - Datatype: boolean
    - Page Item Name: P3_POVTORITSOGLASOVANIE
    - Render As: checkbox
  - Column Name: PODPISYVATEP
    - Label: Підписувати ЕП
    - Datatype: boolean
    - Page Item Name: P3_PODPISYVATEP
    - Render As: checkbox
- Actions:
  - Action
    - Label: Create
    - slot: CREATE
    - Action Type: submit
    - Process: Create
  - Action
    - Label: Apply Changes
    - slot: CHANGE
    - Action Type: submit
    - Process: Apply
  - Action
    - Label: Delete
    - slot: DELETE
    - Action Type: submit
    - Process: Delete
    - Authorized Roles: ADMIN
  - Action
    - Label: Cancel
    - slot: CLOSE
    - Action Type: navigate
    - Process: cancelDialog
##### Region: Аркуш погодження
- Comments: Read-only classic report over RSD_V_SOGLAS_ISPOLNITELI listing the approver sheet for the current process; filtered by OWNER_ID, ordered by line number, with no create, edit, or delete actions and an empty-state message when the process has no rows.
- Position: body
- Colstart: 1
- Colspan: 12
- Component:
  - Component Type: Classic Report
  - Qualifier: Standard
- Data Source:
  - Type: View
  - Name: RSD_V_SOGLAS_ISPOLNITELI
  - Primary Keys: ID
  - Where: owner_id = to_number(:P3_ID)
  - Order By: LINE_NO asc
  - Summary: Approver sheet rows of the current approval process ordered by line number; read-only migrated data.
- Columns:
  - Column Name: ID
    - Label: ІД
    - Datatype: number
    - Render As: hidden
  - Column Name: LINE_NO
    - Label: №
    - Datatype: number
    - Render As: plainText
  - Column Name: ISPOLNITEL_TYPE
    - Label: Тип
    - Datatype: varchar2
    - Render As: plainText
  - Column Name: ISPOLNITEL_NAME
    - Label: Виконавець
    - Datatype: varchar2
    - Render As: plainText
  - Column Name: PORYADOK_NAME
    - Label: Порядок
    - Datatype: varchar2
    - Render As: plainText
  - Column Name: PROYDEN_LABEL
    - Label: Пройдено
    - Datatype: varchar2
    - Render As: plainText
  - Column Name: SROKISPOLNENIYA
    - Label: Строк
    - Datatype: timestamp
    - Render As: plainText
    - Format Mask: DD.MM.YYYY HH24:MI
##### Region: Результати погодження
- Comments: Read-only classic report over RSD_V_SOGLAS_REZULTATY listing the approval results by iteration for the current process; filtered by OWNER_ID, ordered by line number, with no create, edit, or delete actions and an empty-state message when the process has no rows.
- Position: body
- Colstart: 1
- Colspan: 12
- Component:
  - Component Type: Classic Report
  - Qualifier: Standard
- Data Source:
  - Type: View
  - Name: RSD_V_SOGLAS_REZULTATY
  - Primary Keys: ID
  - Where: owner_id = to_number(:P3_ID)
  - Order By: LINE_NO asc
  - Summary: Approval result rows of the current approval process ordered by line number; read-only migrated data.
- Columns:
  - Column Name: ID
    - Label: ІД
    - Datatype: number
    - Render As: hidden
  - Column Name: LINE_NO
    - Label: №
    - Datatype: number
    - Render As: plainText
  - Column Name: NOMERITERATSII
    - Label: Ітерація
    - Datatype: number
    - Render As: plainText
  - Column Name: REZULTAT_NAME
    - Label: Результат
    - Datatype: varchar2
    - Render As: plainText
