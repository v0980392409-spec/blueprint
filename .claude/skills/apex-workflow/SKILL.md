---
name: apex-workflow
description: >
  Explain, build, or migrate Oracle APEX 26.1 Workflows and Human Tasks — the
  routing/approval layer (Слой 2), distinct from bas2apex structure migration.
  Use whenever the user asks about APEX workflow/маршрут/routes/согласование/
  approval flow/human task/task definition — including "объясни как работает
  workflow в APEX", "построй маршрут", "собери согласование в Designer",
  "мигрируй маршрут / BusinessProcess", "почему задача не создаётся", "как
  ветвить по решению", "apex_workflow / apex_human_task / start_workflow".
  Teaches a novice the model AND drives the build/migration + headless test.
---

# apex-workflow — маршруты и задачи Oracle APEX 26.1

Скил про **Слой 2** миграции — маршрут/логику согласования (в отличие от `bas2apex`, который
переносит структуру: справочники/документы/регистры → таблицы). Два режима:

- **Объяснить** (пользователь-новичок спрашивает «как это работает») → веди по
  [`references/concepts.md`](references/concepts.md), объясняй по-русски, термины APEX — латиницей.
- **Сделать** (собрать маршрут / мигрировать BAS-маршрут / отладить) → веди по
  [`references/build-and-code-first.md`](references/build-and-code-first.md) и
  [`references/bas-migration.md`](references/bas-migration.md).

## Модель в трёх предложениях

**Workflow** — визуальный маршрут из **активностей** (шагов), соединённых **связями**, который
движок проводит по строке данных. Один шаг — **`Human Task - Create`** — создаёт **задачу**
человеку (по её **Task Definition**) и ждёт исход; исход кладётся в авто-переменную
**`TASK_OUTCOME`**, по которой **`Switch`** ветвит маршрут. Workflow и Task — **две разные
сущности** (у маршрута свои участники-администраторы, у задачи — свои исполнители).

## Справочные файлы

| Файл | О чём |
|---|---|
| [`references/concepts.md`](references/concepts.md) | Модель для новичка: 5 кирпичей, каталог 13 активностей, связи/ветвление, состояния, глоссарий EN↔RU, ошибки новичка |
| [`references/human-tasks-and-api.md`](references/human-tasks-and-api.md) | Задачи: Task Definition, типы/участники/исходы, состояния, `APEX_HUMAN_TASK` API, вью, ретенция, троблшутинг |
| [`references/build-and-code-first.md`](references/build-and-code-first.md) | Сборка в Designer (пошагово), код-first, рантайм API, headless-тест, мониторинг, фиксация |
| [`references/bas-migration.md`](references/bas-migration.md) | BAS `BusinessProcess`/маршрут → APEX Workflow: таблица соответствий, процедура, шаблон, пробелы |

## Дерево решений

- **«Объясни X»** → concepts.md, при нужде human-tasks-and-api.md. Не грузи пользователя API,
  пока он просит модель.
- **«Построй маршрут с нуля»** → build-and-code-first.md §1 (Designer) или §2 (код). Собирает
  владелец (логин — его действие); я готовлю точные значения полей + SQL.
- **«Мигрируй маршрут BAS»** → bas-migration.md: Слой 1 (данные) уже механически; Слой 2 —
  реконструкция маршрута + канонический шаблон. Один процесс = один батч `migration/NNN-...`.
- **«Задача не создаётся / маршрут Faulted / не даёт прав»** → build-and-code-first.md §7 +
  human-tasks-and-api.md §10 (регистр имён, сессия, Error-связь, dev vs Active).

## Канонический approve/reject-маршрут (запомни как шаблон)

```
Start → [Execute Code] статус=Активен → [Human Task - Create] (Outcome→TASK_OUTCOME)
      → [Switch: Check Workflow Variable = TASK_OUTCOME]
            ├─ = APPROVED → [Execute Code] результат=Погоджено → End
            └─ = REJECTED → [Execute Code] результат=Не погоджено → End
```
Источник версии = Table строки процесса, PK = ID → в активностях `:APEX$WORKFLOW_DETAIL_PK`.
Пилот на стенде — «Согласование», app 200, схема `BAS_REVERSE`.

## Топ-пастки (полный список — в референсах)

1. **Кириллический Static ID** (Workflow и Task Definition) → перезаписать латиницей.
2. **Active не активируется без участников** маршрута (Owner/Admin).
3. **Ветвит `Switch`, не связи.** Связи — `Normal`/`Error`/`Timeout`; ветки — у Switch.
4. **`ORA-20987`** на операциях задачи → имена участников в ВЕРХНЕМ регистре.
5. **Headless** — под схемой `BAS_REVERSE` + `apex_session.create_session` (не sysdba).
6. **Workflow не в APEXLang** → фиксировать SQL-экспортом (`-expType APPLICATION_SOURCE`);
   реимпорт `.apx` его сотрёт.

## Границы (честно)

- Мануал документирует авторинг **только в Designer**; код-first (`wwv_flow_imp_shared.
  create_workflow*`) на стенде работает, но сигнатуры недокументированы — использовать осознанно.
- Поля активностей `Execute Code` / `Invoke API` / `Send Email` / `Send Push Notification`
  официально **не** описаны (нет подраздела в мануале); `Execute Code` знаем по стенду (батч 013).
- Продакшн-участники требуют **identity-bridge** BAS→APEX (пользователи/роли 1С ↔ логины APEX) —
  пока не сделано; пилот на статических `CLAUDE`/`VIKTOR`.
