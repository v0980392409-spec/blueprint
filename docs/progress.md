# Стан міграції та наступні кроки

Робочий журнал експерименту №2 (BAS → APEX через Blueprint/APEXLang). Оновлюється
в кінці сесії. Останнє оновлення: 2026-07-19.

## Що зроблено (повний вертикальний зріз пройдено)

**Скіл `bas2apex`** (`.claude/skills/bas2apex/`) — конвеєр міграції з інструментами:
- `tools/extract_cluster.py` — вижимка кластера з XML-дампу (+ підпорядковані за `<Owners>`, UUID предопределённых).
- `tools/build_migration_map.py` — карта залежностей усього дампу (граф, хвилі, цикли). Результат — `docs/migration-map.md`, [issue #1](https://github.com/v0980392409-spec/blueprint/issues/1).
- `tools/gen_catalog_batch.py` — генератор DDL довідників (транслітерація, FK окремою секцією, `field-map.json` з PARENT_ID/OWNER — ref/ref-poly+OWNER_TYPE).
- `tools/gen_register_batch.py` — генератор регістрів відомостей (виміри→UNIQUE-ключ, ресурси/реквізити, періодичність→VALID_FROM+view зрізу, RecorderSubordinate, поліморфні виміри→REF_TYPE/REF_ID).
- `tools/gen_document_batch.py` — генератор документів (підклас gc.Gen: DOC_NO/DATE/IS_POSTED+ТЧ→дочірні; `sections` у field-map для завантаження ТЧ). Придатний і для BusinessProcess/Task (--only).
- `tools/gen_enum_batch.py` — генератор lookup-таблиці перечислень.
- `tools/gen_odata_loaders.py` — двофазний завантажувач OData (RAW→типізована проекція): `$skip`-пагінація, `--limit N` (bounded), проекція ТЧ (`section_block` JSON_TABLE), види owner_type/ref-poly, `enc` за типом.
- `tools/gen_reconcile.py` — reconcile крос-FK за field-map (ref/ref-ext/ref-poly).
- `references/` — правила маппінгу, шаблон специфікації, derive-guide. `SKILL.md` — 7 етапів + пастки.

**Батчі (артефакти в `migration/`, встановлено на стенд BAS_REVERSE):**
- `001-rsd-doma` — пілот: RSD_HOUSES/HOUSE_SECTIONS/ORGANIZATIONS (+ ТЧ). Blueprint → **app 200 «BUDYNKY»** в APEX (7 сторінок + адмін-сторінка перечислень, LOV на формі організації). Ролі ADMIN видані CLAUDE/VIKTOR.
- `002-enums-wave-1` — 241 перечислення → `RSD_ENUMS` (1326 значень). Замкнуто FK `ENTITY_KIND_ID`.
- `003-nsi-waves-2-4` — 76 довідників НСІ → **137 таблиць / 223 FK / 180 seed**. Замкнуто цикли Контрагенти↔Організації↔Рахунки, Користувачі↔ФізОсоби. §9: 113 пунктів на ревю.
- `004-data-nsi` — **живі дані** з OData: усі 6 ядрових довідників **на 100%** — Контрагенти 10597, Банк.рахунки 5752, ФізОсоби 800, Користувачі 662, Організації 158, Валюти 39 (~18 000 записів). Крос-FK розвʼязані й перевірені на живих даних.
- **UI живих даних (app 200)** — додано дві IR-сторінки-браузери за взірцем стор. 8: **стор. 9 «Контрагенти»** (RSD_KONTRAGENTY, 10576 живих + join лейблів Юр/фіз особа, Фізична особа, Відповідальний) і **стор. 10 «Користувачі»** (RSD_POLZOVATELI, 490 живих + Фізична особа, прапорці Недійсний/Службовий). Меню + breadcrumb + pageGroup «Довідники». Валідовано (`apex validate`, 0 warn) та імпортовано (`apex import -workspaceId`, як SYS) — 11 сторінок, ACL CLAUDE/VIKTOR збережено. Джерело правди — `applications/budynky/`.
- `005-registers-w234` — **структура регістрів відомостей** хвиль 2–4: **99 InformationRegister → 99 таблиць / 552 колонки / 109 FK (+58 відкладено) / 7 view «зрізу останніх»**. Новий генератор `gen_register_batch.py`: виміри→UNIQUE-ключ, ресурси/реквізити→колонки, періодичність→`VALID_FROM`(+view), RecorderSubordinate→RECORDER_*, нетипізовані виміри (28)→поліморфний ключ REF_TYPE/REF_ID. Встановлено на стенд (0 INVALID). §9: 69 пунктів. «Питання підсумків» вирішено: **view зрізу останніх** (арх. рішення власника).
- `008-documents` — **структура документів**: 8 Document → **25 таблиць** (8 шапок + 17 ТЧ) / 150 колонок / 49 FK. Новий генератор `gen_document_batch.py` (підклас gc.Gen, reuse col/tab_section): стандарт DOC_NO/DOC_DATE/IS_POSTED(Posting=Allow)/IS_DELETED+аудит, ТЧ→дочірні `<DOC>_<SECTION>` (OWNER_ID+LINE_NO). Встановлено (0 INVALID; 268 таблиць RSD_*). §9: scope нумерації (NumberPeriodicity), 7 composite. Master-Detail — етап blueprint.
- `012-bp-data-bounded` — **bounded-вибірка 5 великих процесів по 500** (+ТЧ): Согласование/КомплексныйПроцесс/Ознакомление/Исполнение/Утверждение → **2500 header** + ТЧ (напр. SOGLASOVANIE_ISPOLNITELI 843, _REZULTATYSOGLASOVANIYA 702), 0 ORA. Нове: `--limit N` (один `$top=N` без пагінації, для семплу великих; payload 500≈2.6MB ОК) + fix bounded-репортингу (`dbms_output` до `commit`). Повний архів (185k+) — Code-prefix за Number, за потреби.
- `011-bp-data-small` — **дані ТЧ процесів з OData (капабіліті + демо)**: завантажено 3 малих процеси повністю (header+ТЧ: РешениеВопросов 19, Рассмотрение 4, ОбработкаВнутр 2 = OData $count, 0 ORA; ТЧ з OWNER_ID/LINE_NO/enum-FK). Розширено конвеєр: `gen_document_batch` кладе ТЧ у field-map (`sections`); `gen_odata_loaders` — проекція ТЧ (`section_block` через JSON_TABLE), `proj_expr(src=...)`, **виправлено `enc`** (префікс OData з типу — був баг: усі не-довідники як `Catalog_`→404). Документи ДО порожні (404). Великі процеси (Согласование 185k…) — за рішенням про обсяг (Code-prefix, мільйони ТЧ).
- `010-bp-processes` — **Шар 1 решти 12 BusinessProcess**: Исполнение, КомплексныйПроцесс, Обработка{Внутр/Вх/Исх}Документа, Ознакомление, Поручение, Приглашение, Рассмотрение, Регистрация, РешениеВопросов, Утверждение → **72 таблиці** (12 шапок + 60 ТЧ) / 677 колонок / 143 FK (+141 відкл.). Тим самим `gen_document_batch`. Встановлено (**351 таблиця RSD_*, 0 INVALID**). Усі 13 BP на стенді. Шар 2 (маршрути) — за шаблоном Согласования (README батча 009), у Workflow Designer.
- `009-workflow-soglasovanie` — **пілот BP→Workflow (Согласование)**. Шар 1: 11 таблиць (RSD_SOGLASOVANIE +7 ТЧ, RSD_ZADACHAISPOLNITELYA +2 ТЧ; 279 таблиць RSD_*, 0 INVALID). Шар 2: маршрут реконструйовано (структура + РезультатыСогласования + BSL-імена — графічної карти в дампі немає) у **специфікацію APEX Workflow** (Старт→Human Task погодження→Switch за рішеннями→Погоджено/Ні; activities/transitions/participants у README + mermaid). APEX Workflow на стенді доступний (26.1). Межа: движок workflow не авториться APEXLang'ом (немає граматики) — складається у Workflow Designer за специфікацією (крок власника).
- `006-data-nsi-2` — **живі дані решти НСІ**: **17 довідників / 1642 рядки** з OData, лічильники точно = `$count` (Умови маршрутизації 664, Види вх. док. 513, Структура підприємства 155 з ієрархією 144, Приміщення 30, Посади 2 тощо). Виправлено `gen_odata_loaders` (**$skip** замість зламаного keyset Ref_Key — тихо обривав >500). Нове: `relax-constraints` (UNIQUE(CODE) seed↔live), `dedup-seed` (−9 seed-дублів), `reconcile-parent` (self-FK ієрархії — gap gen_catalog_batch). Пропущено: УведомленияПрограммы (6478, без Code); 51/78 довідників — 404 (не опубліковані).

## Стан стенду (BAS_REVERSE)

- app 100 MASTER (еталон), app 122 ERP (порожній цільовий), app 130 ВД, **app 200 BUDYNKY** (пілот; **13 сторінок**; браузери живих даних: Організації, Контрагенти, Користувачі, **Погодження** (стор. 11) + **Master-Detail стор. 12** (drill з стор.11: шапка процесу classic report + IR погоджувачів з резолвом Роль/Користувач)).
- **351 таблиця `RSD_*`** + 7 view, **0 INVALID**: НСІ хвиль 1–4 (довідники) + **99 регістрів** + **8 документів** (25 табл.) + **13 BusinessProcess** (83 табл.).
- Живі дані: **23 довідники** (6 ядрових ~18k + 17 решти НСІ 1642) + **8 процесів** (3 малих повністю + 5 великих по 500 header + ТЧ; напр. Согласование 500 з погоджувачами/результатами).
- Web Credential `BAS_DOC_CRED`, staging `RSD_ODATA_RAW` (сирий OData JSON довідників + процесів).

## Ключові пастки (усі в SKILL.md)

- Blueprint-конвертер: `Datatype: boolean` у фасеті, кириличні static id, локаль JVM (`LANG=C.utf8`), ASCII-alias, порожній ACL після імпорту.
- Передача файлів з macOS: `git archive | docker exec tar` (не scp/docker cp — AppleDouble).
- Дані: обмеження 1С (Code/FillChecking/OWNER) → NULLABLE; `''`=NULL; атомарний MERGE.
- **Пагінація великих сутностей 1С OData**: deep-`$skip` cap ~3000, `$orderby` ігнорується, GUID-keyset не працює → **партиціювання за префіксом `Code` через `startswith`**.

## Зроблено цієї сесії (2026-07-19, 17 комітів)

Усі 4 стартові задачі + похідні: **браузери живих даних** (стор. 9/10 Контрагенти/
Користувачі); **генератор регістрів** (`gen_register_batch`, батч 005: 99 таблиць+
view); **§9** — чек-лист [`docs/section9-decisions.md`] + рішення власника →
батч 007 (OWNER_TYPE+backfill, типізовані VALUE_*); **фікси генераторів**
(gen_catalog_batch: PARENT/OWNER у field-map; gen_odata_loaders: $skip, owner_type/
ref-poly, ТЧ-проекція `section_block`, `enc` за типом, `--limit`); **документи**
(`gen_document_batch`, батч 008: 25 таблиць); **BP** — пілот+тираж (батчі 009/010:
13 процесів, Шар 1) + записка [`docs/businessprocess-workflow.md`]; **дані**
(батч 006: 17 НСІ; 011: ТЧ малих процесів; 012: 5 великих по 500+ТЧ); **UI процесів**
(стор. 11 браузер Согласование + стор. 12 Master-Detail шапка+погоджувачі).

## Наступні задачі (на вибір власника)

1. **Повний архів великих процесів** — Согласование 185k / КомплексныйПроцесс 108k
   / Ознакомление 50k тощо: партиційний завантажувач за префіксом `Number`
   (deep-$skip таймаутить >~3000), header × 4–7 ТЧ = мільйони рядків. Конвеєр
   готовий (`--limit` для семплу; для повного — Code/Number-prefix, як для КОНTRAGENTY).
2. **§9 група 4b** — ~19 нетипізованих ПОСИЛАНЬ (не «Значение»): по-атрибутний
   розбір — одиночний FK де ціль однозначна (Подразделение→Структура,
   ФизическоеЛицо→ФізОсоби), інакше REF_TYPE/REF_ID. Дрібний батч ALTER'ів+backfill.
3. **BP Шар 2 — Workflow у Designer**: зібрати APEX Workflow «Согласование» за
   специфікацією (README батча 009) в App Builder (потрібен логін), провалідувати
   на 1 процесі, тиражувати шаблон на 12 інших. Опц.: редагований IG погоджувачів.
4. **ERP-контур `/Riverside`** — інше джерело OData (BAS ERP, 41 підсистема,
   реф-корпус `../BAS new/reference-erp/`): свій кластер/маппінг, більший обсяг.
5. **Blueprint-track наскрізь** для нового кластера (FR+метадані→blueprint→app 122):
   для регістрів/документів ще не проходили — поки DDL+дані+ручний APEXLang-UI.
6. **Дрібне**: УведомленияПрограммы (6478, без Code — Code-alt пагінація); ~30 не-
   ядрових НСІ поза OData-публікуванням; довантажити ТЧ документів/процесів решти.

## Пастки/факти сесії (доповнення до SKILL.md)

- **SQLcl цієї збірки**: `apex validate/import -workspaceId <id>` (не `-dir`/`-input`),
  `apex export -applicationid N -exptype APEXLANG -dir <d>`. Пароль **BAS_REVERSE** —
  `/root/apex-credentials.txt` рядок `^schema BAS_REVERSE` (поле 4); SYS export/session
  ловить `ORA-06598` → гнати під схемою. `import` існуючого app зберігає ACL.
- **OData**: документи ДО порожні (404); ключ **поліморфного** посилання — поле без
  суфікса (`Owner`, `Исполнитель` = готовий UUID + `<Поле>_Type`), **однотипного** —
  `<Поле>_Key`. `$skip` надійний ≤~3000; >3000 — prefix-партиціювання. ТЧ вкладені
  в фід (без `$expand`). `sql%rowcount` після `commit` = 0 (лог до commit).
- **APEXLang**: движок Workflow і повна `interactiveGrid`-`savedReport`/`view`
  структура **не задокументовані у скілі** (для read-only — IR замість IG). Re-export
  нормалізує (алфавіт колонок, `savedReportMappingIdentifier`, порядок записів);
  після import завжди переекспортувати під BAS_REVERSE → репо=стенд.
- **Поліморфізм**: композитні реквізити/виміри/ТЧ-поля (Предмет/Исполнитель/владелец)
  лишаються §9 (REF_TYPE/REF_ID) і **не вантажаться авто** section_block'ом —
  дорезолв цільовим UPDATE з RAW (`_Type`+UUID), як для погоджувачів у стор. 12.
- **Передача macOS→стенд**: `COPYFILE_DISABLE=1 tar` (не scp/docker cp — AppleDouble).

## Команди для швидкого старту (деталі — docs/stand.md)

```bash
ssh apex-vps "docker ps"                        # стан стека
# app 200: https://apex.173-242-60-109.sslip.io/ords/f?p=200  (CLAUDE / див. /root/apex-credentials.txt)
# APEXLang app 200 — джерело правди: applications/budynky/
#   перенос: COPYFILE_DISABLE=1 tar -cf - budynky | ssh apex-vps 'docker exec -i apex-ords tar -xf - -C /tmp/imp'
#   валід/імпорт (LANG=C.utf8): apex validate|import -workspaceId 5350230995185067  (в контейнері apex-ords, як sys)
#   re-export (репо=стенд): apex export -applicationid 200 -exptype APEXLANG -dir  (під схемою BAS_REVERSE)
```
