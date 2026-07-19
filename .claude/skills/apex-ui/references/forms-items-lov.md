# Формы, item'ы, LOV — референс

Формы и master-detail, каталог item'ов с маппингом 1С→APEX, списки значений, навигация Page
Designer. Свод App Builder User's Guide. Идентификаторы — дословно. Регионы/графики — в
[regions-and-charts.md](regions-and-charts.md).

## Формы (4 типа)

1. **`Form`** — одна запись insert/update (Local DB / REST Enabled SQL / REST Source); к региону
   привязаны items.
2. **`Report with Form`** (`Include Form`) — список + drill-форма правки.
3. **редактируемый `Interactive Grid`** — многострочная inline-правка.
4. **`Master Detail`** — один-ко-многим, две таблицы на одном взаимодействии.

### Master-Detail — 3 раскладки
- **`Stacked`** — одна страница, два редактируемых IG (master + detail). Wizard: App/Page.
- **`Side by Side`** — слева список master, справа запись + detail-отчёты, модальная правка. App/Page.
- **`Drill Down`** — две страницы: IR (master) → форма + IG (detail). **Только Create Page Wizard.**
- Конфиг: `Data Source`, `Primary Key Column(s)`, `Master Detail Foreign Key`, `Use Breadcrumb/
  Navigation`. Авто-валидации для `NOT NULL` и `NUMBER/DATE/TIMESTAMP` (кроме read-only).

> **Маппинг BAS**: шапка документа → `Form` + `Automatic Row Processing (DML)`; ТЧ (табличная
> часть) → detail `Interactive Grid` в `Stacked`/`Drill Down`.

## DML: Automatic Row Processing

Декларативный DML без ручного SQL: движок сам делает insert/update/delete + защиту от потери
изменений. Два вида процесса: `Form - Automatic Row Processing (DML)` и `Interactive Grid -
Automatic Row Processing (DML)`. Создание: Page Designer → Processing → Create Process → Process
Type = **Data Manipulation** → `Automatic Row Processing (DML)`. У процесса: `Name`, `Sequence`,
`Point` (напр. `Onload - After Header` для fetch, `After Submit` для DML), `Type`.

**`Lost Update Type`** (защита от потери изменений):
- **Row Values** — контрольная сумма конкатенации всех обновляемых колонок на момент запроса,
  сверяется при commit.
- **Row Version Column** — колонка-версия, инкрементируемая (лучше триггером БД) при каждом
  апдейте; сверяется вместо суммы.

## Item'ы (31 тип) — маппинг 1С → APEX

Типы (Page Designer → Item → Type): `Checkbox`, `Checkbox Group`, `Color Picker`, `Combobox`,
`Date Picker`, `Date Picker (jQuery) (Desupported)`, `Display Image`, `Display Map`, `Display
Only`, `File Upload`, `Geocoded Address`, `Image Upload`, `Hidden`, `Markdown Editor`, `List
Manager`, `Number Field`, `Password`, `Percent Graph`, `Popup LOV`, `QR Code`, `Radio Group`,
`Rich Text Editor`, `Select List`, `Select Many`, `Select One`, `Shuttle`, `Textarea`, `Star
Rating`, `Switch`, `Text Field`, `Text Field with Autocomplete`.

| Поле BAS (1С) | Item APEX |
|---|---|
| Перечисление (мало значений) | `Select List` / `Radio Group` (всегда видны) |
| Ссылка на большой справочник | **`Popup LOV`** (модальный поиск) / `Select One` |
| Ссылка на малый справочник | `Select List` (dynamic LOV) |
| Мультивыбор (теги, много ссылок) | `Shuttle` / `List Manager` / `Select Many` |
| Булев флаг | `Switch` / `Checkbox` |
| Дата/дата-время | `Date Picker` (**никогда** `Date Picker (jQuery)` — Desupported) |
| Число | `Number Field` |
| Строка | `Text Field` / `Textarea` |
| Картинка/скан | `Image Upload` / `Display Image` (BLOB/URL) |

## LOV (списки значений)

- **Shared / Named LOV** — shared-компонент, переиспользуется всем приложением (одна точка
  правки). Мастер: Create List of Values.
- **Inline / local** — прямо на одном item'е, не переиспользуется.
- **Static** — фиксированные пары display/return.
- **Dynamic** — SQL с колонками `DISPLAY`/`RETURN` (можно bind session state).

> **Маппинг BAS**: Перечисление → static LOV или **dynamic LOV над `RSD_ENUMS`** (конвенция репо);
> ссылка на справочник → dynamic LOV над соответствующей `RSD_`-таблицей.

## Навигация Page Designer

- **Левая панель** — деревья/вкладки: `Rendering`, `Dynamic Actions`, `Processing`, `Shared
  Components`. В Rendering — регионы, items, кнопки.
- **Центр** — вкладки `Layout` / `Component View` / `Page Search` / `Help`.
- **Правая** — **Property Editor** (атрибуты выбранного; при мультивыборе — только общие).
- **Processing** — секции `Processing` / `Validating` / `Branches`; `Point` процесса: `Before
  Header`, `After Header`, `After Submit`, `Onload - After Header`.

Дальше — генерацию `.apx` отдавать скиллу `apexlang` (здесь только выбор региона/item + ключевые
атрибуты).
