# Сборка маршрута и рантайм (Designer + код-first)

Практика: как собрать APEX Workflow в Designer, запускать/тестировать кодом, мониторить и
фиксировать в репо. Модель — [concepts.md](concepts.md); задачи/API — [human-tasks-and-api.md](human-tasks-and-api.md).
Опора: официальный мануал §20.2–20.6 + проверенный пилот `migration/013-workflow-soglasovanie-build/`
(app 200, схема `BAS_REVERSE`).

---

## 0. Предусловия

- Компонент Workflow доступен (APEX 26.1 на стенде — да).
- Схеме приложения выдан грант **`CREATE JOB`** (движок сабмитит DBMS_SCHEDULER-джобы).
- Логин в App Builder — **действие владельца** (мне запрещено вводить пароли в формы). Я готовлю
  точные значения полей и SQL; сборку в Designer выполняет владелец, либо идём код-first.

---

## 1. Путь A — сборка в Workflow Designer (пошагово)

Канонический approve/reject-маршрут (обобщение пилота «Согласование», исправлено на нативный
Switch-паттерн). Формат: **поле → значение**.

### A. Task Definition (карточка задачи)
Shared Components → Workflows and Automations → **Task Definitions** → **Create**:
- `Name` → `Погодження`
- `Type` → `Approval Task` (2 исхода: `APPROVED`/`REJECTED`)
- `Subject` → `Погодження: &NAIMENOVANIE.`
- `Priority` → `3-Medium`
- В форме → секция **Advanced → Static ID** → **перезаписать латиницей** `TASK_SOGLASOVANIE`
  ⚠️ (APEX подставит кириллицу — сломается).
- **Participants** → Add Participant: `Potential Owner`, `Identity Type = User`,
  `Value Type = Static`, `Value = CLAUDE`; повторить для `VIKTOR` (пилотная заглушка; продакшн —
  `Value Type = SQL Query` из исполнителей процесса).
- `Due On Type` → `None` (для теста). → **Create** / **Apply Changes**.

### B. Workflow (маршрут)
Shared Components → Workflows and Automations → **Workflows** (⚠️ **не** Task Definitions!) →
**Create**:
- `Name` → `Погодження`; `Static ID` → **латиницей** `SOGLASOVANIE`.
- Корень маршрута → **Additional Data / Source**: `Source Type = Table`,
  `Table = RSD_SOGLASOVANIE`, `Primary Key Column = ID`. → даёт `:APEX$WORKFLOW_DETAIL_PK` (=ID).

### C. Активности (палитра / Create Activity)
1. **`Workflow Start`** — есть по умолчанию.
2. **`Execute Code`** «Позначити активним» — PL/SQL:
   ```sql
   update RSD_SOGLASOVANIE
      set SOSTOYANIE_ID = 768,               -- Активний
          DATANACHALA   = systimestamp
    where ID = :APEX$WORKFLOW_DETAIL_PK;
   ```
3. **`Human Task - Create`** «Погодження»:
   - `Definition` → `Погодження` (TASK_SOGLASOVANIE)
   - `Details Primary Key Item` → переменная/параметр с PK (или `APEX$WORKFLOW_DETAIL_PK`)
   - `Outcome` → `TASK_OUTCOME` · `Owner` → `APPROVER` (**авто-переменные**, APEX создаёт сам)
4. **`Switch`** «Рішення» — `Type = Check Workflow Variable`, `Compare Variable = TASK_OUTCOME`.
5. **`Execute Code`** «Погоджено» (ветвь APPROVED):
   ```sql
   update RSD_SOGLASOVANIE
      set REZULTATSOGLASOVANIYA_ID = 747,     -- Погоджено
          DATAZAVERSHENIYA         = systimestamp
    where ID = :APEX$WORKFLOW_DETAIL_PK;
   insert into RSD_SOGLASOVANIE_REZULTATYSOGLASOVANIYA (OWNER_ID, LINE_NO, NOMERITERATSII, REZULTATSOGLASOVANIYA_ID)
   select :APEX$WORKFLOW_DETAIL_PK, nvl(max(LINE_NO),0)+1, 1, 747
     from RSD_SOGLASOVANIE_REZULTATYSOGLASOVANIYA where OWNER_ID = :APEX$WORKFLOW_DETAIL_PK;
   ```
6. **`Execute Code`** «Не погоджено» (ветвь REJECTED): то же, но `746`.
7. **`Workflow End`** — `End State = Completed`.

### D. Связи
- Start → «Позначити активним» → «Погодження» → «Рішення» (Switch): все `Normal`.
- Switch → «Погоджено»: ветвь, `Operator = =`, значение `APPROVED`.
- Switch → «Не погоджено»: ветвь, `Operator = =`, значение `REJECTED`.
- «Погоджено» → End; «Не погоджено» → End: `Normal`.

### E. Участники маршрута + активация
- Дерево → **Participants** → Create: `Workflow Owner`/`Administrator` (напр. `CLAUDE`).
  Без участников **Active-версия не активируется**.
- **Save** → **Show Messages** (исправить ошибки) → **Activate**.

### F. Страницы UI (по желанию)
Create Page Wizard → Component **`Workflow Console`**: `Report Context` = `My Workflows` /
`Admin Workflows` / `Initiated by Me`; опц. `Include Dashboard Page`; создаёт Console + Details
(+ Dashboard). Инбокс задач: Component **`Unified Task List`** (контексты `My Tasks` /
`Admin Tasks` / `Initiated by Me`).

---

## 2. Путь B — код-first (авторинг маршрута кодом)

На стенде подтверждён полный app-import API (авторинг маршрута как код):
`wwv_flow_imp_shared.create_workflow` / `_version` / `_activity` / `_transition` / `_branch` /
`_participant` / `_variable` / `_comp_param` (+ `create_task_def*`). Типы активностей в API:
`NATIVE_WORKFLOW_START`/`_END`, `NATIVE_CREATE_TASK` (Human Task), `NATIVE_WORKFLOW_SWITCH`,
`NATIVE_INVOKE_API` (Execute Code), `NATIVE_PARALLEL_WF`, `NATIVE_WORKFLOW_WAIT`,
`NATIVE_SEND_EMAIL`.

> Практика: официальный мануал документирует **только Designer** для авторинга. Код-first
> возможен, но хрупок (недокументированные сигнатуры). **Рекомендация: авторить в Designer,
> фиксировать SQL-экспортом.** Код-first — для массового тиражирования шаблона, когда Designer
> дорог. APEXLang маршрут **не** держит — это отдельный SQL-трек (см. §5).

---

## 3. Рантайм API (проверено на стенде)

Для headless всё — **под схемой `BAS_REVERSE`** (не sysdba: движку нужен APEX-контекст, иначе
`ORA-06598`), внутри валидной сессии.

### Старт и управление маршрутом
```sql
apex_session.create_session(p_app_id => 200, p_page_id => 1, p_username => 'CLAUDE');

l_instance := apex_workflow.start_workflow(
                p_application_id => 200,
                p_static_id      => 'SOGLASOVANIE',
                p_detail_pk      => '94',        -- PK строки-предмета
                p_initiator      => 'CLAUDE');
```
Прочие процедуры `apex_workflow`: `retry(instance_id)` (Faulted → повтор активности сбоя),
`resume(instance_id, activity_static_id)` (Suspended; дефолт — текущая активность),
`continue_activity(...)` (для Wait/async-плагинов), `update_variables(...)` (правка переменных,
и обязательно для `CLOB` > VARCHAR2), `refresh_participants(...)` (подхватить новых участников в
бегущие инстансы), `clear_test_data(app_id, static_id)` (снести dev-инстансы),
`set_log_level(instance_id, apex_debug.c_log_level_app_trace)` (включить лог инстанса).

### Завершение задачи (двигает маршрут дальше)
```sql
apex_session.create_session(p_app_id => 200, p_page_id => 1, p_username => 'CLAUDE');
apex_human_task.complete_task(p_task_id => l_task_id, p_outcome => 'APPROVED', p_autoclaim => true);
-- или apex_human_task.approve_task / reject_task (см. human-tasks-and-api.md)
```
`p_autoclaim => true` важно для headless: если задача `Unassigned`, неявно заклеймит.

---

## 4. Headless-тест (наскрозной)

Шаблон (проверено на процессе ID=94, `sql/pilot-test.sql`):
```sql
-- 1. старт
declare l_i number; begin
  apex_session.create_session(200, 1, 'CLAUDE');
  l_i := apex_workflow.start_workflow(200, p_static_id=>'SOGLASOVANIE', p_detail_pk=>'94', p_initiator=>'CLAUDE');
  commit;
end;
/
-- 2. найти созданную задачу
select max(task_id) from apex_tasks where application_id=200 and task_def_static_id='TASK_SOGLASOVANIE';
-- 3. завершить APPROVED
declare l_t number; begin
  apex_session.create_session(200, 1, 'CLAUDE');
  select max(task_id) into l_t from apex_tasks where application_id=200 and task_def_static_id='TASK_SOGLASOVANIE';
  apex_human_task.complete_task(p_task_id=>l_t, p_outcome=>'APPROVED', p_autoclaim=>true);
  commit;
end;
/
-- 4. проверка: REZULTATSOGLASOVANIYA_ID = 747 + строка ТЧ; аудит:
select * from apex_workflow_audit where application_id=200 order by 1 desc fetch first 15 rows only;
```
Запуск: `ssh apex-vps 'docker exec -i apex-ords /opt/oracle/sqlcl/bin/sql BAS_REVERSE/<pwd>@//db:1521/FREEPDB1' < pilot-test.sql`
(`<pwd>` — `/root/apex-credentials.txt`, строка `^schema BAS_REVERSE`, поле 4).

> После `complete_task` маршрут может доигрываться фоновым движком (не синхронно): строка
> обновится, когда выполнится ветвь Switch. Перепроверить SELECT через миг или через Monitor Activity.

---

## 5. Мониторинг и вью

- **UI**: App Builder → **Monitor Activity** (инстансы/задачи); страницы Workflow Console/Details/
  Dashboard; Workflow **Utilization**/**History** reports (Shared Components → Workflows).
- **Debug**: включить `Debug Level` у версии → Utilities → Debug Messages → добавить колонку
  `Workflow Instance`; или `select message from apex_debug_messages where workflow_instance_id=<id>`.
- **Runtime-вью**: `APEX_WORKFLOWS` (инстансы), `APEX_WORKFLOW_ACTIVITIES`, `APEX_WORKFLOW_VARIABLES`,
  `APEX_WORKFLOW_PARTICIPANTS`, **`APEX_WORKFLOW_AUDIT`** (трасса событий). Задачи: `APEX_TASKS`,
  `apex_human_task.get_tasks(...)`.
- **Метаданные (дизайн)**: `APEX_APPL_WORKFLOWS`, `APEX_APPL_WORKFLOW_VERSIONS`, `_ACTIVITIES`,
  `_TRANSITIONS`, `_BRANCHES`, `_VARIABLES`, `_PARTICIPANT`, `_PARAMS`, `_ACT_VARS`, `_ACT_BRANCH`.

---

## 6. Фиксация в репо (маршрут НЕ в APEXLang!)

APEXLang (`applications/<alias>/`) **не** держит определение workflow — реимпорт `.apx` его
**сотрёт**. Поэтому маршрут — отдельный **SQL-трек**:
```
apex export -applicationid 200 -expType APPLICATION_SOURCE -dir <d>   # SQLcl в контейнере ords
```
Положить `f200.sql` (или фрагмент `create_workflow*`) в `migration/NNN-.../export/`. Это
артефакт-истина Слоя 2. После любого пересбора в Designer — переэкспортировать.

---

## 7. Пастки (сжато)

| Пастка | Решение |
|---|---|
| Кириллический Static ID (Workflow и Task) | перезаписать латиницей вручную |
| Active-версия не активируется | добавить участника маршрута (Owner/Admin) |
| `ORA-06598` при headless | гнать под `BAS_REVERSE`, не sysdba; `apex_session.create_session` |
| «Task Not Found» в scheduler-джобе | нужна `apex_session.create_session` перед API |
| `ORA-20987` на операции задачи | имена участников в ВЕРХНЕМ регистре |
| В App Builder нет проверок прав | это dev-версия; проверки — только на Active |
| Ошибка активности → весь маршрут `Faulted` | добавить `Error`-связь по SQL-коду |
| Маршрут пропал после реимпорта `.apx` | он не в APEXLang; фиксировать SQL-экспортом |
