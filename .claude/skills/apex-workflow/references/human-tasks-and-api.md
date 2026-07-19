# Human Tasks, Task Definitions и API — референс

Свод официального мануала APEX 26.1 (главы «Tasks», §20.14–20.22) + API Reference по
`APEX_HUMAN_TASK`. Все идентификаторы APEX — дословно (латиницей). Это справочник «что
изучено»; для обзорной модели см. [concepts.md](concepts.md), для сборки и рантайма —
[build-and-code-first.md](build-and-code-first.md).

---

## 1. Три сущности: Task / Human Task / Task Definition

- **Task (задача)** — единица работы. Бывает автоматической или человеческой.
- **Human Task (человеческая задача)** — то, что должен обработать **человек** (одобрить/
  выполнить), а не скрипт. В контексте маршрутов нас интересуют именно они.
- **Task Definition (определение задачи)** — **shared-компонент** уровня приложения
  (Shared Components → Workflows and Automations → **Task Definitions**). Это «шаблон/
  карточка» задачи: тип, участники, параметры, действия, сроки. По одному Task Definition
  создаётся сколько угодно экземпляров задач.

Как связано: делаешь Task Definition → кладёшь на страницу page process **`Human Task -
Create`** (или зовёшь `apex_human_task.create_task`) → движок создаёт экземпляр →
пользователь видит его в **Unified Task List** (инбокс) и действует → меняется **состояние**
задачи. В маршруте (Workflow) роль «создателя задачи» играет активность **Human Task**.

---

## 2. Два типа задач и их исходы

| Тип (`Type`) | Для чего | Исход (outcome) | Кнопки владельца |
|---|---|---|---|
| **`Approval Task`** | одобрить/отклонить | встроенный: `APPROVED` / `REJECTED` | **Approve** / **Reject** |
| **`Action Task`** | выполнить действие | **нет исхода** | **Save** / **Complete** |

- Константы API: `c_task_type_approval='APPROVAL'`, `c_task_type_action='ACTION'`;
  исходы `c_task_outcome_approved='APPROVED'`, `c_task_outcome_rejected='REJECTED'`.
- «Третий исход» (напр. «Одобрено с замечаниями») встроенным Approval Task недоступен —
  только Approved/Rejected. Для доп. исходов — Action Task с кастомной логикой или
  моделирование в маршруте.
- По умолчанию инициатор Approval-задачи **не может** её сам одобрить. Меняется флагом
  **`Initiator Can Complete`** (в определении или в page process). Для Action Task инициатор
  может завершать свою задачу.

---

## 3. Анатомия Task Definition

Создание: Shared Components → Task Definitions → **Create**. Диалог сразу спрашивает `Name`,
`Type`, `Subject`, `Static ID`, `Priority`, `Potential Owner`, `Business Admin`. Дальше —
полная форма с секциями.

### Settings
- **`Subject`** — тема; поддерживает подстановки `&PARAM_NAME.` (значение параметра) и
  `APEX$TASK_*`. Пример: `Погодження: &NAIMENOVANIE.`.
- **`Static ID`** — ключ для `apex_human_task.create_task` и для запросов к вью.
  ⚠️ **Пастка**: APEX подставляет кириллицу из Name → перезаписать латиницей вручную.
- **`Priority`** — 1..5, где **1 = Urgent … 5 = Lowest**, по умолчанию **3 - Medium**
  (`c_task_priority_urgent=1 … c_task_priority_lowest=5`).
- **`Initiator Can Complete`** (только Approval) — по умолчанию Off.
- **`Task Details Page`** — номер страницы с деталями экземпляра (можно сгенерить кнопкой
  Create Task Details Page). Если на ней форма — в URL добавить `&Pxx_ID=&DETAIL_PK.`.
- **`Actions Source`** — таблица/SQL, чьи строки доступны в действиях как bind (`:EMPNO`),
  и bind `:APEX$TASK_PK` (PK детали).

### Participants (участники) — 6 ролей, из них 4 конфигурируемых
Конфигурируются кнопкой **Add Participant**: `Potential Owner`, `Business Administrator`,
`Excluded Owner`, `Excluded Admin`. Ещё две роли неявные: `Task Initiator` (кто создал) и
`Actual Owner` (кто заклеймил/кому делегировали).

| Роль | Права |
|---|---|
| `Potential Owner` | может заклеймить неназначенную задачу; их может быть много |
| `Actual Owner` | владелец: approve/reject/complete, запросить инфо, править параметры |
| `Business Administrator` | продлить/переназначить/отменить/сменить приоритет, убрать owner'а |
| `Task Initiator` | создать задачу, дать доп. информацию |
| `Excluded Owner` | НЕ может клеймить/одобрять (нельзя задать Authorization Scheme'ой) |
| `Excluded Admin` | НЕ может администрировать |

Для каждого участника: **`Identity Type`** = `User` или `Authorization Scheme` (схема =
аналог «группы»; `c_task_identity_type_user='USER'`, `..._auth='AUTH'`). При `User` —
**`Value Type`** = `Static` / `SQL Query` / `Function Body` / `Expression` (последние три
могут вернуть одного пользователя или список через запятую). При `Authorization Scheme` —
`Value Type = Static`, `Value` = имя схемы.

> **Пастка авторизации (troubleshooting)**: имена пользователей APEX хранит в **ВЕРХНЕМ**
> регистре. Potential Owner в определении указывать в верхнем регистре, иначе на операциях
> задачи `ORA-20987: Not authorized for Task operations`. «Много ложных срабатываний из-за
> регистра».

**Vacation Rules** — PL/SQL-процедура, возвращающая альтернативных участников (замещение).
Уровень определения переопределяет уровень приложения. Вызывается при создании задачи и при
делегировании. Сигнатура: `procedure(p_param in apex_human_task.t_vacation_rule_input,
p_result out apex_human_task.t_vacation_rule_result)`.

### Parameters (параметры)
Атрибуты, несущие данные задачи. Поля строки: `Static ID`, `Label`, `Data Type` (`String`),
`Required`, `Visible` (показывать на Details), `Updatable` (правится ли после старта),
`Comment`. Параметры, объявленные тут, должны быть заданы в page process, создающем задачу.

### Actions (действия)
Событийные триггеры. `Type` действия: `Execute Code` / `Send Email` / `Send Push
Notification` (+ плагин процесса, если есть). `Execution Sequence` (по возрастанию),
`On Event` — из списка событий: `Claim`, `Complete`, `Delegate`, `Update Comment`,
`Update Priority`, `Update Parameter`, `Release`, `Cancel`, `Create`, `Request Information`,
`Submit Information`, `Before Expire`, `Expire`. Обработка ошибок: `Error Message` (плейсхолдер
`#SQLERRM#`), `Stop Execution on Error` (→ задача в `ERRORED`), `Log Messages When` =
`None`/`Success`/`Failure`/`All` (это же — конфиг Task History).

### Deadline / Due On / Expiration
- **`Due On Type`**: `None` / `Interval` (ISO/SQL длительность, только положительная) /
  `SQL Query` / `Function Body` / `Expression` / `Scheduler Expression` (календарный синтаксис
  БД, напр. «first Friday of the month at 4:00 p.m.»).
- **`Expiration Policy`**: `None` (по умолч.; после срока задача остаётся активной) / `Expire`
  (истекает, одобрять нельзя) / `Renew` (истекает + создаётся новая; `Maximum Renewal Count`
  до 99).

> Обновление Task Definition **не** трогает уже созданные задачи — только новые.

---

## 4. Жизненный цикл: состояния задачи

Состояния (дословно из мануала): `Created`, `Unassigned`, `Assigned`, `Info Requested`,
`Completed`, `Errored`, `Canceled`, `Expired`, `Renewed`. Константы API пишут `CANCELLED`
(две l) и добавляют `FAILED`.

| Состояние | Стадия | Переходы |
|---|---|---|
| `Created` | начальная | → `Unassigned` (много owner'ов) · → `Assigned` (один owner) · → `Errored` |
| `Unassigned` | промежут. | → `Assigned` (claim/delegate) · → `Completed` (owner решает из инбокса) · → `Errored`/`Canceled`/`Expired` |
| `Assigned` | промежут. | → `Completed` · → `Unassigned` (release) · → `Info Requested` · → `Assigned` (delegate) · → `Errored`/`Canceled`/`Expired` |
| `Info Requested` | промежут. | → `Assigned` (инициатор дал инфо) · → `Expired` |
| `Completed` | финальная | — (после — подлежит purge/архиву) |
| `Errored` | финальная | → `Renewed` (админ вручную продлевает → новая задача) |
| `Canceled` | финальная | — |
| `Expired` | финальная | Renew+лимит не достигнут → новая задача; иначе — админ вручную |

---

## 5. Unified Task List (инбокс) и Task Details

**Unified Task List** — тип страницы в Create Page Wizard (Component → `Unified Task List`).
Три **Report Context**:

| Контекст | Аудитория | Что показывает |
|---|---|---|
| `My Tasks` | владельцы | `Assigned` на юзера или `Unassigned` где он potential owner. Завершённые не видны. Сортировка по дате создания (новые сверху). |
| `Admin Tasks` | бизнес-админы | все задачи где юзер админ, включая `Errored`/`Completed`/`Canceled`. `Expired` — только по «Show expired tasks». |
| `Initiated by Me` | инициаторы | все инициированные юзером |

Может жить в отдельном приложении того же workspace (нужен shared session). В multi-tenant
уважает Tenant ID сессии. **Task Details Page** — детали одного экземпляра: метаданные,
история, комментарии и кнопки (`Approve`/`Reject` для Approval; `Save`/`Complete` для Action;
`Claim`, `Release`, `Delegate`, `Request Information`, `Submit Information`, `Set Priority`,
`Set Due Date`, `Invite/Remove/Exclude Participant`, `Cancel`, `Renew`, `Comment`,
`Update Parameter`).

---

## 6. Подстановки и bind-переменные задачи

Настраиваются в Task Definition; передают данные экземпляра на страницу.

| Токен | Значение |
|---|---|
| `APEX$TASK_ID` | id задачи |
| `APEX$TASK_PK` | PK строки-детали; **как bind — `:APEX$TASK_PK`** в PL/SQL действий и участников |
| `APEX$TASK_SUBJECT` | тема |
| `APEX$TASK_STATE` | текущее состояние |
| `APEX$TASK_OUTCOME` | исход (только Approval в `Completed`) |
| `APEX$TASK_OWNER` | текущий владелец |
| `APEX$TASK_INITIATOR` | инициатор (по умолч. — залогиненный) |
| `APEX$TASK_CREATED_ON` / `APEX$TASK_DUE_ON` | таймстемпы (формат `YYYY-MM-DD"T"HH24:MI:SS.FF3TZH:TZM`) |
| `APEX$TASK_RENEWAL_COUNT` / `APEX$TASK_MAX_RENEWAL_COUNT` | счётчик/лимит продлений |
| `APEX$TASK_PREVIOUS_ID` | id предыдущей (истёкшей) задачи в цепочке продления |
| `APEX$TASK_TEXT` | текст из Add Comment / Request/Submit Information (как bind в Execute Code/Send Email этих действий) |

> ⚠️ **Баг (documented)**: `APEX$TASK_ID` **не работает** в **Actions SQL Query** (Edit Task
> Definition) — id ещё не сгенерирован на момент разбора источника действий. Обходной путь —
> `APEX$TASK_PK`.

---

## 7. API `APEX_HUMAN_TASK` (программное управление)

Пакет требует **валидной APEX-сессии** (иначе `get_*` не вернут данных, а в scheduler-джобе —
«Task Not Found»; см. троблшутинг ниже). Ниже — сигнатуры по группам.

### Создание
```sql
apex_human_task.create_task(
  p_application_id         in number   default apex_application.g_flow_id,
  p_task_def_static_id     in varchar2,
  p_subject                in varchar2 default null,
  p_parameters             in t_task_parameters default c_empty_task_parameters,
  p_priority               in integer  default null,
  p_initiator              in varchar2 default null,
  p_initiator_can_complete in boolean  default null,
  p_detail_pk              in varchar2 default null,
  p_due_date               in timestamp with time zone default null) return number;  -- task_id
```
Один potential owner → задача сразу `Assigned`; несколько → `Unassigned`. Без potential
owner'ов — исключение. Параметры собираются так:
```sql
p_parameters => apex_human_task.t_task_parameters(
  1 => apex_human_task.t_task_parameter(static_id => 'REQ_ITEM',   string_value => l_item),
  2 => apex_human_task.t_task_parameter(static_id => 'REQ_AMOUNT', string_value => l_amount))
```

### Жизненный цикл / владение
| Процедура | Действие |
|---|---|
| `claim_task(p_task_id)` | `Unassigned`→`Assigned`, текущий юзер = owner (только potential owner) |
| `release_task(p_task_id)` | `Assigned`→`Unassigned` (только owner) |
| `delegate_task(p_task_id, p_to_user)` | назначить одному potential owner'у |
| `approve_task(p_task_id, p_autoclaim default false)` | = `complete_task` с `APPROVED` |
| `reject_task(p_task_id, p_autoclaim default false)` | = `complete_task` с `REJECTED` |
| `complete_task(p_task_id, p_outcome default null, p_autoclaim default false)` | завершить (`p_outcome` для Approval); `Assigned`→`Completed` |
| `cancel_task(p_task_id)` | → `CANCELED` (инициатор/админ; нельзя для Completed/Errored) |
| `renew_task(p_task_id, p_priority default null, p_due_date) return number` | пересоздать Expired/Errored (админ), вернёт новый id |

`p_autoclaim => true` — если задача `Unassigned`, неявно заклеймить перед действием (важно
для headless-прогонов). Константа приоритета: `apex_human_task.c_task_priority_high` и т.п.

### Информация / комментарии / история
`request_more_information(p_task_id, p_text, p_to_user default null)` →`Info Requested`;
`submit_information(p_task_id, p_text)`; `add_task_comment(p_task_id, p_text)`;
`add_to_history(p_message)` — писать лог **изнутри кода действия** (неявный контекст задачи).

### Участники / приоритет / срок / параметры
`add_task_potential_owner(p_task_id, p_potential_owner, p_identity_type default USER)`
(пока поддерживается только `USER`); `remove_potential_owner`; `exclude_potential_owner`;
`refresh_business_admins`; `set_task_priority(p_task_id, p_priority)`;
`set_task_due(p_task_id, p_due_date)` (дата в будущем); `set_task_parameter_values(p_task_id,
p_parameters, p_raise_error default true)` (только `Updatable`);
`set_initiator_can_complete(p_task_id, p_initiator_can_complete)`.

### Чтение задач — для инбокса
```sql
select * from table(apex_human_task.get_tasks(
  p_context            => 'MY_TASKS',   -- MY_TASKS | ADMIN_TASKS | INITIATED_BY_ME | SINGLE_TASK
  p_user               => apex_application.g_user,
  p_task_id            => null,          -- для SINGLE_TASK
  p_application_id     => null,          -- null = все
  p_show_expired_tasks => 'N'));
```
Возвращает pipelined `apex_t_approval_tasks` с колонками (главные для инбокса): `task_id`,
`subject`, `state`, `state_code`, `outcome`, `outcome_code`, `priority`, `priority_level`,
`actual_owner`, `initiator`, `created_on`, `created_ago`, `due_on`, `due_in`, `due_code`,
`is_completed`, `detail_pk`, `details_link_target`, `task_def_static_id`, `task_def_name`,
`task_type`, `tenant_id`, `app_id`. **Это предпочтительный путь для «Мои задачи»** — не надо
знать колонки `APEX_TASKS`. Прочие read-функции (только в сессии, не в SQL Workshop):
`get_task_history`, `get_task_delegates`, `get_task_priorities`, `get_task_parameter_value`,
`get_task_parameter_old_value`, `has_task_param_changed`, LOV: `get_lov_priority/state/type`.

### Проверки прав
`is_allowed(p_task_id, p_operation, p_user, p_new_participant)` — где `p_operation` из
констант `c_task_op_*` (`APPROVE_TASK`, `REJECT_TASK`, `COMPLETE_TASK`, `CLAIM_TASK`,
`DELEGATE_TASK`, `CANCEL_TASK`, …); `is_business_admin(p_user, p_application_id)`;
`is_of_participant_type(p_task_id, p_participant_type, p_user)`.

### Обслуживание
`delete_tasks(p_application_id, p_static_id, p_states, p_include_workflow_tasks default false)`
— чистка (по умолчанию НЕ трогает задачи, созданные workflow; осторожно!);
`handle_task_deadlines` — прогнать дедлайны сейчас (иначе фоновый джоб раз в час);
`get_next_purge_timestamp`.

---

## 8. Runtime-вью задач

| Вью | Назначение |
|---|---|
| `APEX_TASKS` | свойства каждого экземпляра задачи |
| `APEX_TASK_PARTICIPANTS` | участники по экземпляру (может отличаться от определения — админ добавлял/убирал) |
| `APEX_TASK_COMMENTS` | комментарии |
| `APEX_TASK_HISTORY` | хронология операций (кто/когда) |
| `APEX_TASK_PARAMETERS` | значения параметров (в String) |
| `APEX_PURGEABLE_TASK*` | зеркала для задач, подлежащих purge (для архивации до удаления) |

Мануал не даёт колонок этих вью — для инбокса используй `apex_human_task.get_tasks` (см. §7),
для точечного — `DESC APEX_TASKS`.

---

## 9. Ретенция и очистка задач

Демон `DBMS_SCHEDULER` раз в сутки: **держит** active/unassigned/assigned; **чистит**
completed (у кого retention ≤ сегодня), а также terminated/canceled/errored. Terminated и
canceled без retention — живут <24 ч (до ближайшего прогона). Настройки: **retention по
умолчанию 7 дней, максимум 30** (Instance Settings, инстанс-админ). NB: это **не то же**, что
ретенция workflow-инстансов (30/100 дней). **Archive of Purged Tasks Report** (Workspace
Administration) сохраняет JSON-документ подлежащих purge задач; сами файлы чистятся раз в 30
дней. Пред-purge архивация — `MERGE ... USING apex_purgeable_tasks`.

---

## 10. Троблшутинг задач

| Симптом | Причина | Решение |
|---|---|---|
| `ORA-20987: Not authorized for Task operations` | несовпадение регистра имени | имена в **ВЕРХНЕМ** регистре (APEX хранит `USER` в upper); potential owner'ы — тоже |
| **Task Not Found** при approve из DBMS Scheduler | нет APEX-сессии → задача не в контексте | `apex_session.create_session(p_app_id, p_page_id, p_username)` перед вызовом API |
| задача не истекает после `set_task_due` | джоб дедлайнов раз в час | форсировать `apex_human_task.handle_task_deadlines` |
| `APEX$TASK_ID` не работает в Actions SQL Query | id ещё не сгенерирован | использовать `APEX$TASK_PK` |
