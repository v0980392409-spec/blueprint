---
name: apex-ui
description: >
  Choose and design the RIGHT Oracle APEX 26.1 UI for a BAS object — which region
  type / page pattern renders a справочник, документ, регистр, or dashboard well,
  and why. Use whenever the user asks "какой регион/страницу выбрать", "сделай
  браузер справочника/документа", "Interactive Report или Interactive Grid",
  "фасетный поиск / Faceted Search / Smart Filters", "карточки / Cards", "дашборд /
  KPI / графики", "мастер-детейл форма", "какой item type для поля", "список
  значений / LOV", "как показать табличную часть (ТЧ) документа". Decision aid used
  while writing the FR (bas2apex stage 4) or hand-editing .apx post-import; hands off
  to `apexlang` for actual .apx syntax and to `bas2apex` for the migration pipeline.
---

# apex-ui — выбор и проектирование UI Oracle APEX 26.1

Помогает решить **какой регион/страницу строить** для BAS-объекта — то, что не покрывают
`bas2apex` (останавливается на blueprint: что за таблицы), `apexlang` (низкоуровневый синтаксис
`.apx`, когда регион уже выбран) и `apex-workflow` (маршруты). Это **справочник решений** для
разговора «какой регион?» + карты соответствий. Синтаксис `.apx` не дублируем — отдаём `apexlang`.

## Карта решений: BAS-объект → APEX-паттерн

| BAS (1С) | Задача UI | APEX-паттерн |
|---|---|---|
| Справочник — просмотр списка | листать/сортировать/экспорт | **`Interactive Report`** (браузер, как стор. 8–10 app 200) |
| Справочник — фильтровать по атрибутам | фасетный отбор | **`Faceted Search`** (cards/classic + фасеты) или **`Smart Filters`** (компактно) |
| Справочник — выбор в поле | подобрать ссылку | item **`Popup LOV`** (много строк) / **`Select One`** / `Select List` (мало) над dynamic LOV |
| Перечисление (enum) | picklist/подпись | static LOV или **dynamic LOV над `RSD_ENUMS`** |
| Документ — шапка | ввод/правка одной записи | **`Form`** + процесс **`Automatic Row Processing (DML)`** |
| Документ — шапка + ТЧ | заголовок + строки | **Master-Detail**: `Stacked` (2 IG) / `Side by Side` / `Drill Down` (IR→форма+IG) |
| Табличная часть (ТЧ) — редактируемая | много строк inline | **`Interactive Grid`** (Edit Enabled) |
| Регистр — «зріз останніх» | только чтение | **`Interactive Report`** над view зрізу |
| Дашборд / KPI | сводка + графики | **`Cards`** (плитки) + **`Chart`** (`Status Meter Gauge`/`Bar`/`Donut`) |
| Иерархия (Структура підприємства) | дерево | **`Tree`** region |
| Прогресс BusinessProcess | ход маршрута | **`Workflow Diagram`** region → см. скилл `apex-workflow` |

## Interactive Report vs Interactive Grid (частый выбор)

- **`Interactive Report`** — просмотр: сортировка, фильтры, **Group By / Pivot**, экспорт (CSV/
  Excel/PDF), сохранённые отчёты, подписки. **НЕ редактируется inline** (правка — через отдельную
  форму). Бери для браузеров справочников/документов.
- **`Interactive Grid`** — то же + **inline-редактирование** (Add/Duplicate/Delete Row, правка
  ячеек), Freeze/Aggregations. **Нет** Group By/Pivot/computed. DML — процессом `Interactive Grid
  - Automatic Row Processing (DML)`. Бери для редактируемых ТЧ и master-detail.

## Справочные файлы

| Файл | О чём |
|---|---|
| [`references/regions-and-charts.md`](references/regions-and-charts.md) | Каталог 20+ типов регионов; сравнение отчётов (IR/IG/Classic/Cards/Faceted/Smart Filters); типы фасетов; JET-графики (17 типов + SQL-формы); Maps/Calendar/Tree |
| [`references/forms-items-lov.md`](references/forms-items-lov.md) | Формы (4 типа) + master-detail (Stacked/Side-by-Side/Drill-Down) + Automatic Row Processing (DML) + Lost Update; 31 тип item'а с маппингом 1С→APEX; LOV (shared/inline, static/dynamic); навигация Page Designer |

## Когда применять

- **На этапе FR (bas2apex, stage 4)** — записать в требования, какой UI-паттерн задуман (регион/
  страница), чтобы blueprint сгенерил ближе к цели.
- **При ручной правке `.apx`** (`applications/*/pages/*.apx` после импорта) — выбрать регион/item,
  затем **отдать `apexlang`** генерацию синтаксиса (не писать `.apx` из этого скилла).

## Границы

- Синтаксис `.apx`, compiler-truth, шаблоны, runtime — это `apexlang`. Здесь только «какой регион/
  item + ключевые атрибуты», а дальше hand-off.
- Пайплайн миграции, spec, blueprint — это `bas2apex`. Здесь — решение о UI внутри него.
- `Date Picker (jQuery)` — **Desupported**, никогда не целиться в него (только `Date Picker`).
- Фасеты авто-открываются только над **таблицей** (Data Dictionary Cache, джоб
  `ORACLE_APEX_DICTIONARY_CACHE`); над view/SQL — только `VARCHAR2`-фасеты вручную.
