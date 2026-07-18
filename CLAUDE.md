# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Що це за репо

Експеримент №2 міграції з BAS (1С) на **Oracle APEX 26.1** — через **APEX Blueprints** і **APEXLang**, а не ручну побудову сторінок (то був експеримент №1, репо `../revers`). Мова артефактів — українська; спілкування з користувачем — російською.

Шлях фічі: функціональні вимоги + метадані схеми → blueprint (Markdown, за `blueprints/prompt/blueprint-prompt.md`) → імпорт в APEX як Application Blueprint → скаффолд → доопрацювання в APEXLang (`.apx`) з валідацією SQLcl (`apex validate`).

## Стенд і доступи (деталі — docs/stand.md)

- VPS: `ssh apex-vps` (алиас у `~/.ssh/config`, root). Стек у `/opt/apex-stand`: контейнери `apex-db` (Oracle DB Free 26ai), `apex-ords` (ORDS + APEX 26.1), `apex-caddy`, `apex-minio`.
- APEX: <https://apex.173-242-60-109.sslip.io/ords/>, workspace/схема `BAS_REVERSE`.
- **Цільовий застосунок — app 122 «ERP»**; app 100 «MASTER» — еталон конвенцій UI та фреймворку синхронізації (`bas_sync_pkg`, живе в `../revers/apex-master/`).
- Секрети — тільки на VPS (`/root/apex-credentials.txt`, `/opt/apex-stand/.env`), у репо не комітяться.
- Дані BAS — OData `https://rv.entercom.ua:5683/` (ERP `/Riverside`, ДО `/bas_doc`); `404` = «не опубліковано», кирилиця в URL лише екранованою.

## Команди

```bash
# SQL до БД (кирилиця псується без NLS_LANG)
ssh apex-vps 'source /opt/apex-stand/.env && docker exec -i -e NLS_LANG=.AL32UTF8 apex-db sqlplus sys/$ORACLE_PWD@FREEPDB1 as sysdba'

# SQLcl — всередині контейнера ORDS (локально не встановлений)
ssh apex-vps 'docker exec -it apex-ords /opt/oracle/sqlcl/bin/sql BAS_REVERSE@//db:1521/FREEPDB1'
# у SQLcl: apex export -applicationid 122 -as-apexlang   |   apex validate -dir <dir>
```

Білда і тестів немає — «збірка» тут це генерація blueprint / APEXLang-артефактів та їх імпорт в APEX.

## Структура і звідки що взято

- `blueprints/` — офіційний пакет [oracle/apex@26.1/blueprints](https://github.com/oracle/apex/tree/26.1/blueprints): канонічний промпт генератора blueprint, allowlist іконок Font APEX, приклади order-entry і supply-chain-management (вимоги → метадані → згенерований blueprint → SQL схеми). **Не редагувати** — це vendored-копія; оновлювати з апстріму цілком.
- `.claude/skills/apexlang/` — офіційний скіл Oracle ([oracle/skills](https://github.com/oracle/skills)) для генерації/редагування `.apx`. Його `SKILL.md` — власна точка входу з жорсткими контрактами (start order, app-location, runtime через `node tools/apexctl.mjs`) — при роботі з APEXLang слідувати йому, не імпровізувати.
- `reference/ords/`, `reference/sqlcl/` — доки з oracle/skills (vendored, не редагувати).
- `reference/apexlang-sample/apextogo/` — повний приклад застосунку в `.apx` (структура: `application.apx`, `pages/pNNNNN-*.apx`, `shared-components/*.apx`, `deployments/default.json`, `.apex/apexlang.json`).
- `applications/erp/` — **робочий APEXLang-експорт цільового застосунку 122 «ERP»** зі стенду (SQLcl: `apex export -applicationid 122 -exptype APEXLANG`). Це і є артефакт міграції: редагується тут, валідується `apex validate -input`, імпортується назад `apex import`. Після імпорту в APEX — переекспортувати, щоб репо лишався джерелом правди.
- `docs/` — рукописні доки цього експерименту (`stand.md` — стенд/доступи/цільовий застосунок).

## Суміжні локальні репо (контекст, не залежності)

- `../revers` — експеримент №1 (BAS Документообіг на APEX): конституція, `ui-conventions.md`, `apex-master/` (SQL еталона й синхронізації), `infra/apex-vps/` (**інфраструктурні скрипти стенду живуть там**, тут не дублюються).
- `../BAS new` — as-is корпус BAS: `reference-erp/` (BAS ERP, 41 підсистема, glossary uk↔ru, `index/objects.csv`) — головне джерело метаданих і вимог для blueprint застосунку ERP; `reference/` — Документообіг.

## Конвенції (успадковані з експерименту №1)

- Ідентифікатори БД — латиниця, кастомні з префіксом `RSD_`; жодних GUID (`*_Key`) на екрані; `DELETION_MARK` замість фізичного DELETE.
- Підписи UI — дослівно з BAS (українською); дати `DD.MM.YYYY`.
- Внутрішні імена 1С (російські, напр. `Catalog.ВнутренниеДокументы`) не перекладаються — це технічний ключ.
