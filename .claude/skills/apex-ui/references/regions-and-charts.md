# Регионы, отчёты, графики — референс

Каталог типов регионов APEX 26.1 и когда что брать. Свод App Builder User's Guide (гл. 8
«Developing Reports», регионы, графики). Идентификаторы — дословно. Формы/items/LOV — в
[forms-items-lov.md](forms-items-lov.md); карта решений BAS→паттерн — в [SKILL.md](../SKILL.md).

## Каталог типов регионов (Page Designer → Region → Type)

**Стандартные:**

| Тип | Для чего |
|---|---|
| `Interactive Report` | SQL-отчёт с богатой runtime-кастомизацией (сорт/фильтр/Group By/Pivot/экспорт) |
| `Interactive Grid` | то же + inline-редактирование, Freeze, Aggregations |
| `Classic Report` | простой шаблонный SQL-отчёт (Media List/Comments/Timeline/Badge List/Value-Attr Pairs) |
| `Cards` | плиточная раскладка (`Grid`/`Float`/`Horizontal (Row)`) |
| `Faceted Search` | регион фасетов + отчёт (cards/classic) — отбор как в e-commerce |
| `Smart Filters` | компактно: поле поиска + чипы-подсказки; результат cards/classic/map/calendar |
| `Form` | одна запись (local/REST/Duality); к нему привязаны items |
| `Chart` | графики Oracle JET |
| `Map` | точки/линии/полигоны, слои |
| `Calendar` | Monthly/Weekly/Daily/List; drag-and-drop |
| `Tree` | иерархия parent-child |
| `List` | статический/динамический список (обычно навигация) |
| `Reflow Report` | адаптивный отчёт (колонки→строки на узком экране) |
| `Search` | результаты из Search Configuration (shared) |
| `Region Display Selector` | переключатель между регионами страницы |
| `Static Content` / `Dynamic Content` | текст/HTML (в т.ч. из функции) |
| `Breadcrumb`, `Help Text`, `URL` | навигация / help-страница / внешний контент |
| `Workflow Diagram` | read-only ход Workflow → скилл `apex-workflow` |

**Из плагинов (installed):** `Avatar`, `Badge`, `Comments`, `Content Row`, `Media List`,
`Timeline`, `Source Display`.

## Сравнение отчётных типов (что строить)

### `Interactive Report` (IR)
Просмотр. Меню заголовка: Sort, Hide, Control Break, Filter. Actions: Columns/Filters/Data/
Format/**Chart**/**Group By**/**Pivot**/Report/Download/Subscription. Сохранённые отчёты (Private/
Public/Default). Экспорт CSV/HTML/Excel/PDF. **Не редактируется inline** (правка — отдельная
форма через `Include Form`). Ограничения: нет scroll-пагинации, нет freeze-колонок, слабее чарты.

### `Interactive Grid` (IG)
IR-кастомизация + **inline-редактирование** (Row Actions: Single Row View/Add/Duplicate/Delete/
Refresh/Revert; правка ячеек). Меню заголовка: Control Break/Aggregations/**Freeze**/Hide/Filter.
DML — процесс `Interactive Grid - Automatic Row Processing (DML)`. **Нет** Group By/Pivot/computed,
фикс. высота строки, не помнит текущую страницу. Master-detail: два редактируемых IG на странице.

### `Classic Report`
Самый шаблонный. Шаблоны: `Media List`/`Comments`/`Timeline`/`Badge List`/`Value Attributes
Pairs` (нужны совпадающие алиасы колонок). Report Layouts для PDF. Юзеру — только сорт + простой
фильтр.

### `Cards`
Плитки `Grid`/`Float`/`Horizontal (Row)`. Части: Header/Media/Body/Actions. Media = `BLOB`/`URL`/
`iFrame`. Действия на `Button`/`Full Card`/`Title`/`Subtitle`/`Media`. Хорош для сводки/лендинга.

### `Faceted Search` vs `Smart Filters`
- **Faceted Search** — слева фасеты, справа отчёт (cards/classic). Фасеты авто-открываются над
  **таблицей** (топ-5 колонок score ≥ 20, Data Dictionary Cache, джоб `ORACLE_APEX_DICTIONARY_CACHE`);
  над view/SQL — только `VARCHAR2` вручную. Опц. график на фасет (bar/pie). Для BAS «формы списка»
  с отбором по нескольким атрибутам справочника.
- **Smart Filters** — одно поле + чипы-подсказки, компактнее (узкие экраны). Результат cards/
  classic/map/calendar.

**Типы фасетов** (Facet → Type):

| Тип | Поведение |
|---|---|
| `Checkbox Group` | мультивыбор; хранит как colon-строку; нужен LOV |
| `Radio Group` / `Select List` | одиночный выбор; нужен LOV |
| `Input Field` | свободный текст; `DATE`/`TIMESTAMP` в `YYYYMMDDHH24MISS`; операторы |
| `Range` | границы (нижняя вкл., верхняя искл.): `100\|500` / `\|100` / `500\|` |
| `Search` | поиск по значениям фасета; **один на регион**, всегда сверху |

## Графики (Oracle JET)

Только JET (в 26.1 никакого legacy/AnyChart). Типы: `Bar`, `Line`, `Line with Area`, `Area`,
`Combination`, `Scatter`, `Bubble`, `Box Plot`, `Pie`, `Donut`, `Funnel`, `Pyramid`, `Polar`,
`Radar`, `Stock`, `Gantt`, `Status Meter Gauge`.

SQL-формы (Column Mapping `LABEL`/`VALUE`):
- мультисерия: `select link, label, series_1_value [, series_2_value, ...]` — имена серий = алиасы;
- `Range`: `select link, label, low_value, high_value`;
- `Scatter`: `select link, label, x_value, y_value`;
- Stock/Candlestick: `select link, label, open, low, high, close`.

**Дашборд/KPI** (как app 201): `Cards` (плитки-сводка) + `Chart` (`Status Meter Gauge`/`Bar`/
`Donut`), опц. `Region Display Selector` для переключения.

## Maps / Calendar / Tree

- **`Map`** — таблица/REST-источник; `Point`/`Line`/`Polygon`/`GeoJSON`; один+ слоёв (свой SQL на
  слой). 26.1: bounding-box, data-driven стили/легенды (проверить живьём).
- **`Calendar`** — `Start Date`(+`End Date` для длительности); Monthly/Weekly/Daily/List; drag-drop
  двигает записи (пишет прямо).
- **`Tree`** — parent-child; для иерархий (напр. Структура підприємства с self-FK).
