# blueprint — експеримент №2: міграція BAS → Oracle APEX 26.1

Другий експеримент міграції з BAS (1С) на Oracle APEX — цього разу через **APEX Blueprints** та **APEXLang** (нові можливості APEX 26.1), а не ручну побудову сторінок.

Ціль: зі функціональних вимог + метаданих схеми генерувати blueprint (Markdown) → імпортувати в APEX як Application Blueprint → отримувати скаффолд застосунку, який далі доопрацьовується в текстовому форматі APEXLang (`.apx`) з валідацією через SQLcl.

## Що в репо

| Шлях | Що це | Джерело |
|---|---|---|
| `blueprints/` | офіційний пакет Blueprint Application Scaffolding: канонічний промпт генератора (`prompt/blueprint-prompt.md`), allowlist іконок, два повні приклади (order-entry, supply-chain-management) із вхідними вимогами, метаданими схеми та згенерованими blueprint | [oracle/apex@26.1](https://github.com/oracle/apex/tree/26.1/blueprints) |
| `.claude/skills/apexlang/` | офіційний скіл Oracle для роботи з APEXLang в AI-агентах (генерація/редагування `.apx`, воркфлоу «create app from FR + model») — підхоплюється Claude Code автоматично | [oracle/skills](https://github.com/oracle/skills/tree/main/apex/apexlang) |
| `reference/ords/` | доки з ORDS: архітектура, інсталяція, auto-REST, автентифікація, безпека, REST API design тощо | [oracle/skills/db/ords](https://github.com/oracle/skills/tree/main/db/ords) |
| `reference/sqlcl/` | доки з SQLcl: basics, CI/CD, diff, liquibase, MCP server тощо (`apex validate` живе у SQLcl) | [oracle/skills/db/sqlcl](https://github.com/oracle/skills/tree/main/db/sqlcl) |
| `reference/apexlang-sample/apextogo/` | повний приклад застосунку в форматі APEXLang (`.apx`) — референс структури | [oracle/apex@26.1 sample-apps](https://github.com/oracle/apex/tree/26.1/sample-apps) |
| `applications/erp/` | APEXLang-експорт цільового застосунку 122 «ERP» зі стенду (робочий артефакт міграції) | стенд, `apex export -exptype APEXLANG` |
| `docs/stand.md` | стенд (VPS, ORDS, БД), доступи, цільовий застосунок 122, OData-джерела BAS | цей репо |

## Швидкий старт

1. Прочитати [docs/stand.md](docs/stand.md) — стенд і доступи.
2. Прочитати [blueprints/QUICKSTART.md](blueprints/QUICKSTART.md) — як генерується та імпортується blueprint.
3. Формат `.apx` — дивитись [reference/apexlang-sample/apextogo/](reference/apexlang-sample/apextogo/) і скіл `.claude/skills/apexlang/`.

## Ліцензії

Матеріали Oracle (`blueprints/`, `.claude/skills/apexlang/`, `reference/`) — Universal Permissive License (UPL) 1.0, див. `blueprints/LICENSE.txt` та `reference/LICENSE-oracle-skills.txt`.
