# export/ — фіксація Workflow у репо (SQL, не APEXLang)

`workflow-soglasovanie.sql` — **визначення Workflow `SOGLASOVANIE` + Task Definition
`TASK_SOGLASOVANIE`**, витягнуте з SQL-експорту app 200. Це артефакт-істина Шару 2:
**APEXLang його не тримає** (`applications/budynky/` при реімпорті workflow зітре), тому
фіксуємо окремим SQL.

## Звідки
```bash
# SQLcl усередині ORDS, під схемою BAS_REVERSE:
apex export -applicationid 200        # → f200.sql (повний застосунок, ~284 КБ)
```
Секція `--application/shared_components/workflow/*` цього експорту (task_definitions +
workflows) → цей файл. Виклики: `wwv_flow_imp_shared.create_task_def / create_workflow /
_version / _variable / _activity / _participant / _transition`.

## Що всередині (звірено)
- Static ID компонентів — **латиниця**: `SOGLASOVANIE`, `TASK_SOGLASOVANIE`, змінна `V_OUTCOME`.
- 5 активностей: `start_1`, `позначити-активним`, `погодження` (Human Task), `записати-результат`,
  `end_1`. Static ID трьох користувацьких активностей — кирилиця (`unistr(...)`, APEX
  згенерував з назв); на рантаймі працює (пілот пройдено), косметика.
- Маршрут лінійний; рішення (747/746) обирає код активності `записати-результат` за `:V_OUTCOME`.

## Re-import (за потреби)
Фрагмент — **капітал-артефакт** (джерело правди/ревʼю), не самостійний скрипт: посилається на
`wwv_flow_imp`-контекст із шапки повного експорту. Для перенесення workflow на інший стенд —
переекспортувати весь app (`apex export -applicationid 200`) і імпортувати f200.sql, або
авторити код-first через `wwv_flow_imp_shared.create_workflow*` (API на стенді підтверджено).

Деталі складання й тесту — у [`../README.md`](../README.md). Профільний скіл — `.claude/skills/apex-workflow/`.
