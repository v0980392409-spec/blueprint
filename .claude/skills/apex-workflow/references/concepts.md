# APEX Workflow для новичка — модель движка

Как устроен APEX Workflow 26.1: понятия, каталог активностей, маршрутизация, состояния.
Свод официального мануала (§20.1–20.13). Идентификаторы APEX — дословно (латиницей). Задачи
(Human Task) отдельно — [human-tasks-and-api.md](human-tasks-and-api.md); сборка и рантайм —
[build-and-code-first.md](build-and-code-first.md); перенос BAS — [bas-migration.md](bas-migration.md).

---

## 1. Что такое Workflow (в одном абзаце)

**Workflow** — автоматизация бизнес-процесса: документ/задача движется от участника к
участнику по правилам. В APEX это **визуальный маршрут** (диаграмма) из шагов-«активностей»,
соединённых стрелками, который движок проводит по строке данных (напр. по строке заявки).
Аналог из 1С — «БизнесПроцесс» с картой маршрута.

Четыре части APEX Workflow: **Workflow Designer** (рисуешь маршрут) → **Workflow Version**
(версия: In Development / Active) → **Workflow Runtime Engine** (исполняет экземпляры) →
**Workflow Console** (мониторинг/администрирование).

> **Предусловие стенда**: схеме приложения нужен грант `CREATE JOB` (движок сабмитит джобы).

---

## 2. Главное разделение: Workflow ≠ Task

Это первая путаница новичка. Это **две разные сущности**, которые соединяются в одной точке:

| | **Workflow** (маршрут) | **Task / Human Task** (задача) |
|---|---|---|
| Что это | последовательность шагов | одна единица работы для человека |
| Где живёт | Shared Components → Workflows | Shared Components → Task Definitions |
| Кто «участник» | `Workflow Owner` / `Workflow Administrator` (права на инстанс) | `Potential Owner` / `Business Admin` (кто реально одобряет) |
| Состояния | `Active`/`Suspended`/`Completed`/`Terminated`/`Faulted` | `Assigned`/`Completed`/`Expired`/… |

Соединяются активностью **`Human Task - Create`**: это шаг маршрута, который создаёт экземпляр
задачи по её Task Definition, ждёт, пока человек её обработает, и кладёт исход обратно в
переменную маршрута. **Можно строить маршрут без задач** (чистая автоматика: Execute Code +
Switch), и **можно создавать задачи без маршрута** (page process `Human Task - Create` прямо на
странице). Маршрут нужен, когда шаги идут цепочкой/ветвлением и переживают сессию.

---

## 3. Пять кирпичей Workflow Definition

Определение маршрута (shared-компонент уровня приложения) состоит из:

1. **Parameters (параметры)** — входы, которые APEX передаёт **при старте**; применимы ко
   **всем версиям**; **не меняются** в рантайме. Direction `In`/`Out`/`In/Out` (`Out` — только
   при вызове из другого маршрута через Invoke Workflow, не из page process).
2. **Variables (переменные)** — специфичны для **версии**; **меняются** в рантайме (результат
   активности, `apex_workflow.update_variables`, правка админом). Типы: `VARCHAR2`, `NUMBER`,
   `BOOLEAN`, `TIMESTAMP[/WITH [LOCAL] TIME ZONE]`, `CLOB`.
3. **Activities (активности)** — сами шаги (см. §4).
4. **Connections (связи)** — стрелки, задающие путь (см. §5).
5. **Participants (участники)** — APEX-пользователи с правами на инстанс: `Workflow Owners`
   (старт/терминация/retry) и `Workflow Administrators` (+ suspend/resume + правка переменных).
   Не путать с исполнителями задач! **Обязательны перед активацией** (In Development — можно без).

Кто стартовал маршрут — **Workflow Initiator** (не обязан быть участником; может терминировать
только свои инстансы).

**Activity Variables** — локальные переменные одной активности (например, подтянуть данные для
шага). Живут только на время выполнения этой активности.

---

## 4. Каталог активностей (13 типов)

Тип выбирается в дропдауне `Type` при создании активности (по умолчанию `Execute Code`). Имя
активности **уникально** в пределах маршрута.

| Тип (Designer) | Для чего | Ветвит? |
|---|---|---|
| `Workflow Start` | единственный старт; без входящих связей | нет |
| `Workflow End` | конец; **End State** = `Completed` \| `Terminated`; без исходящих; их может быть несколько | нет |
| `Execute Code` | выполнить PL/SQL (сменить статус, записать результат) | нет |
| `Human Task - Create` | создать задачу человеку по Task Definition, ждать исход | нет¹ |
| `Switch` | **разветвить** маршрут по условию | **да** |
| `Parallel Flow` | параллельные ветки (все должны завершиться) | да (параллельно) |
| `Wait` | пауза: по таймауту или `apex_workflow.continue_activity` | нет |
| `Invoke Workflow` | вызвать другой маршрут (нельзя себя/циклы) | нет |
| `Invoke API` | вызвать API | нет |
| `Send Email` | отправить письмо | нет |
| `Send Push Notification` | пуш-уведомление | нет |
| `Generate Text with AI` | текст через AI-агента (ответ в `CLOB`-item) | нет |
| `Custom Process Type Plug-in` | активность на своём плагине (нужно `Supported For = Workflow Activities` + `Wait for Completion`) | нет |

¹ Сама Human Task не ветвит — но кладёт исход в переменную, по которой ветвит следующий `Switch`.

**Общие поля любой активности**: `Additional Data` (SQL-запрос → его колонки доступны как bind
в активности), `Deadline → Due On Type` (таймаут), `Layout → Sequence` (порядок в дереве —
**НЕ** порядок выполнения!), `Activity Variables`. Обработка ошибок — **не** на активности, а
через **Error Connection** (см. §5).

### `Human Task - Create` — ключевые поля
- `Definition` — какое Task Definition;
- `Details Primary Key Item` — workflow-item (переменная/параметр) с PK строки-предмета;
- `Outcome` / `Owner` — переменные для исхода и исполнителя.
- **APEX сам создаёт две переменные `TASK_OUTCOME` и `APPROVER`.** В рантайме после завершения
  задачи `TASK_OUTCOME` = `APPROVED`/`REJECTED`. Следующий `Switch` ветвит по ним. (Для второй
  Human Task в том же маршруте авто-переменные не пересоздаются — переиспользуй или заведи вручную.)

### `Switch` — 4 типа условия
- `True False` — по `Rows Returned/Not Returned`, `Expression`, `Function Body` или
  `Workflow Variable =/!=/is [NOT] NULL`; ветки `When` = `True`/`False`/`Null`.
- `Check Workflow Variable` — сравнить переменную (`Compare Variable`) через `Operator` по веткам.
  **Это канонический способ ветвить по `TASK_OUTCOME`.**
- `Case` — `Compare Data Type`/`Compare Type` (SQL/Expression/Function Body); ветки `Sequence` +
  `Operator` + `Value`.
- `If Elsif Else` — ветки `Sequence` + `Type` (условие) + `To`. `Sequence` задаёт порядок оценки.

---

## 5. Маршрутизация: связи (2 вида)

Связь — стрелка между активностями. Два структурно разных вида:

### Transitions (транзиции) — 3 типа
- **`Normal`** — обычная стрелка. У каждой активности ≥1 входящая и ≥1 исходящая Normal
  (кроме Start — нет входящих, End — нет исходящих).
- **`Error`** — цель при **конкретной ошибке**: `Operator` + `Value` = SQL-код ошибки
  (напр. `-01403` для `NO_DATA_FOUND`). Их может быть несколько, порядок оценки — `Sequence`.
  **Если ошибка есть, а Error-связи нет → маршрут в `Faulted`.**
- **`Timeout`** — доступна, только если у активности задан `Due On`. Одна. У `Wait` своего
  таймаута — нельзя (у него встроенный).

### Branches (ветви) — выходы `Switch`
Выходы активности `Switch` — это **не** Normal/Error/Timeout, а отдельная сущность «ветвь».
Пример: `True False Check` даёт ветвь на true и ветвь на false. У `Parallel Flow` «ветви» —
это параллельные дорожки (не условные).

> **Поправка к моему прежнему пониманию (батч 013).** Я думал «связи бывают только Normal/Error,
> ветвить нельзя, значит выбираем в коде». На самом деле: (а) есть ещё `Timeout`; (б) ветвление
> **есть** — через активность `Switch` (это её Branches, отдельные от транзиций). Нативный
> approve/reject-маршрут: `Human Task → Switch(Check Workflow Variable = TASK_OUTCOME) →` ветки
> `APPROVED`/`REJECTED`. Выбор в коде — рабочий, но не канонический fallback.

---

## 6. Состояния (жизненный цикл)

Одинаковые имена на двух уровнях означают разное.

**Workflow-инстанс (5):** `Active` (бежит) · `Suspended` (приостановлен, только этот уровень;
резюмит админ) · `Completed` (дошёл до End/Completed) · `Terminated` (остановлен/End-Terminated;
retry невозможен) · `Faulted` (ошибка активности; админ делает Retry или Terminate).

**Активность (5):** `Active` · `Waiting` (ждёт результата — задачу, вложенный WF, все ветки;
только этот уровень) · `Completed` · `Terminated` · `Faulted`.

Различие: `Suspended` — только у маршрута; `Waiting` — только у активности. Retry «оживляет»
Faulted → Active. Resume — только для Suspended. (`Retry` ≠ `Resume`.)

---

## 7. Как маршрут запускается и живёт

- **Старт (декларативно)**: page process типа `Workflow` → `Settings.Type = Start`, выбрать
  `Definition`, задать `Details Primary Key` (item с PK строки) и параметры. Другие операции
  того же плагина: `Terminate`/`Suspend`/`Resume`/`Retry`.
- **Старт (кодом)**: `apex_workflow.start_workflow(...)` (проверено на стенде; см.
  build-and-code-first.md). Для headless нужен `apex_session.create_session(...)`.
- **Версии**: у маршрута одна `Active` версия. Из App Builder (сессия разработчика) выполняется
  **development**-версия **без проверок авторизации**; без dev-сессии — **active** с проверками.
  Page process берёт **определение**, не версию.
- **Реимпорт приложения**: бегущие инстансы → `Suspended`, после — авто-возобновление (или
  админ решает). Деактивация версии: текущие инстансы дорабатывают, новые не стартуют.
- **Ретенция**: демон `DBMS_SCHEDULER` раз в сутки; держит Active/Suspended/Faulted; чистит
  Completed через 30 дней (по умолч. 30, макс. 100); Terminated живут <24 ч.

---

## 8. Подстановки маршрута (`APEX$WORKFLOW_*`)

Передают данные инстанса на страницу/в PL/SQL активностей:

| Токен | Значение |
|---|---|
| `APEX$WORKFLOW_ID` | id инстанса |
| `APEX$WORKFLOW_DETAIL_PK` | PK строки-источника; **как bind — `:APEX$WORKFLOW_DETAIL_PK`** в любом PL/SQL активностей/переменных/участников |
| `APEX$WORKFLOW_STATE` | текущее состояние инстанса |
| `APEX$WORKFLOW_ACTIVITY_ID` | id текущей активности |
| `APEX$WORKFLOW_INITIATOR` | кто стартовал |
| `APEX$WORKFLOW_CREATED_ON` | таймстемп создания |

---

## 9. Глоссарий EN ↔ RU

| APEX (EN) | По-русски | 1С-аналог |
|---|---|---|
| Workflow / Workflow Definition | Маршрут / определение маршрута | БизнесПроцесс (вид) |
| Workflow Version | Версия маршрута | — |
| Workflow Instance | Экземпляр маршрута | Экземпляр БизнесПроцесса |
| Activity | Активность (шаг) | Точка маршрута |
| Transition / Connection | Связь (стрелка) | Переход |
| Branch (Switch) | Ветвь | Условие/разветвление |
| Human Task | Человеческая задача | ЗадачаИсполнителя |
| Task Definition | Определение задачи | (вид задачи) |
| Participant (workflow) | Участник маршрута (owner/admin) | — |
| Potential Owner (task) | Потенциальный исполнитель | Исполнитель |
| Outcome | Исход (APPROVED/REJECTED) | РезультатСогласования |
| Faulted / Suspended | Сбой / приостановлен | — |

---

## 10. Типичные ошибки новичка (чек-лист)

1. **Путать участников маршрута и исполнителей задачи.** Owner/Admin маршрута ≠ Potential Owner
   задачи. Кто реально одобряет — в Task Definition.
2. **Кириллический Static ID.** APEX подставляет кириллицу из Name → Workflow и Task не
   находятся по static_id. **Перезаписать латиницей** (Workflow, Task Definition — оба).
3. **Активировать без участников.** Active-версия требует ≥1 участника, иначе не активируется.
4. **Забыть Error-связь** на активности, где возможна ошибка (напр. `NO_DATA_FOUND`) → `Faulted`.
5. **Ждать ветвления от связей.** Ветвит `Switch`, а не Normal/Error. Approve/reject → Switch по
   `TASK_OUTCOME`.
6. **Регистр имён.** APEX хранит логины в ВЕРХНЕМ регистре; participant в нижнем → `ORA-20987`.
7. **Тестировать в App Builder и удивляться отсутствию проверок прав** — это dev-версия, она их
   не делает. Проверки — только на Active.
8. **Забыть, что workflow не в APEXLang.** Реимпорт `.apx` сотрёт маршрут — фиксировать
   SQL-экспортом (`-expType APPLICATION_SOURCE`).
