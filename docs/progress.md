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
- `014-blueprint-soglasovanie` — **Blueprint-track наскрізь для master-detail
  кластера** (раніше лише для довідника, пілот 001). `BusinessProcess.Согласование`
  (Погодження) на живих даних: 3 reporting-view'и (резолв поліморфного виконавця
  Роль/Користувач + enum-підписи) → `schema-metadata.md`+`fr.md` (курований набір,
  5 LOV над RSD_ENUMS/RSD_POLZOVATELI) → `blueprint.md` (638 рядків, 0 Validation
  Findings) → `APEX_GENDEV.PROCESS_BLUEPRINT` (parsing log NULL) → apexlang.zip →
  **app 201 «ПОГОДЖЕННЯ»** (Дашборд 4 KPI+3 графіки / Faceted-список / модальна
  форма з 2 master-detail звітами). Перевірено: структура+дані течуть (KPI 500/
  500/333/20; master-detail proc 17/18/19), логін-сторінка рендериться. Ролі
  ADMIN→CLAUDE/VIKTOR. Джерело правди — `applications/pogodzhennya/`.
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
- `013-workflow-soglasovanie-build` — **Шар 2, рецепт складання** пілота в APEX Workflow Designer (спосіб — рішення власника: складає власник, я готую значення+SQL). Знахідка, що уточнює 009: код-first **можливий** — на стенді підтверджено повний app-import API `wwv_flow_imp_shared.create_workflow*` (+ `create_task_def*`) і словник типів активностей (`NATIVE_CREATE_TASK` Human Task, `NATIVE_WORKFLOW_SWITCH` Switch, `NATIVE_INVOKE_API` Execute Code, `NATIVE_WORKFLOW_END`), АЛЕ APEXLang його **не тримає** → workflow це окремий **SQL-трек** (фіксація експортом app 200 в SQL, не в `applications/budynky/`). Артефакт: `README.md` (чек-лист Designer: Task Definition `TASK_SOGLASOVANIE` + Workflow `SOGLASOVANIE` 5 активностей + переходи + активація), `sql/build-blocks.sql` (PL/SQL/запити для полів — **DML провалідовано проти живої схеми з rollback**; Task Definition тип **Approval Task** → 2 результати `APPROVED`/`REJECTED`, пише REZULTAT 747/746, стани 768–770; 748 «із зауваженнями» — наступний виток), `sql/pilot-test.sql` (наскрізний headless: `apex_workflow.start_workflow` p_detail_pk=94 → `apex_approval.complete_task` p_outcome=APPROVED → очікуємо REZULTAT=747 + рядок ТЧ). **Пастка:** APEX підставляє кириличний Static ID → перезаписати латиницею (`TASK_SOGLASOVANIE`, `SOGLASOVANIE`). Учасники — пілотна заглушка CLAUDE/VIKTOR (ПолныеРоли не мігровано, немає identity-bridge). **Статус: ✅ ЗІБРАНО в Designer власником (лінійний варіант: Start→Execute Code→Human Task→Execute Code→End, гілка рішення в коді за V_OUTCOME) + НАСКРІЗНИЙ ТЕСТ ПРОЙДЕНО** (ID=94: NULL→747, екземпляр COMPLETED). Три бойові уроки в pilot-test.sql: (1) завершує НЕ-ініціатор — CLAUDE-ініціатор заблокований `Initiator Can Complete=OFF`, погоджує VIKTOR; (2) задача створюється **асинхронно** після start → baseline+опит `task_id>baseline`; (3) продовження після complete теж async → опит екземпляра до `COMPLETED`. Активація версії вимагає учасника **Workflow Owner** (Static Value VIKTOR) + **Save** після Activate (стан у Designer до Save не комітиться). Профільний скіл — `.claude/skills/apex-workflow/`. **Зафіксовано** `export/workflow-soglasovanie.sql` (workflow+task-def з SQL-експорту app 200 — не тримається APEXLang'ом) + `export/README.md`; **закоммічено+запушено** (`a81fce8`). Стенд прибрано: рядок 94 відкочено до завантаженого стану (768/NULL/28.11.2019); тестові екземпляри workflow лишились у Monitor Activity (безпечна історія).
- `009-workflow-soglasovanie` — **пілот BP→Workflow (Согласование)**. Шар 1: 11 таблиць (RSD_SOGLASOVANIE +7 ТЧ, RSD_ZADACHAISPOLNITELYA +2 ТЧ; 279 таблиць RSD_*, 0 INVALID). Шар 2: маршрут реконструйовано (структура + РезультатыСогласования + BSL-імена — графічної карти в дампі немає) у **специфікацію APEX Workflow** (Старт→Human Task погодження→Switch за рішеннями→Погоджено/Ні; activities/transitions/participants у README + mermaid). APEX Workflow на стенді доступний (26.1). Межа: движок workflow не авториться APEXLang'ом (немає граматики) — складається у Workflow Designer за специфікацією (крок власника).
- `006-data-nsi-2` — **живі дані решти НСІ**: **17 довідників / 1642 рядки** з OData, лічильники точно = `$count` (Умови маршрутизації 664, Види вх. док. 513, Структура підприємства 155 з ієрархією 144, Приміщення 30, Посади 2 тощо). Виправлено `gen_odata_loaders` (**$skip** замість зламаного keyset Ref_Key — тихо обривав >500). Нове: `relax-constraints` (UNIQUE(CODE) seed↔live), `dedup-seed` (−9 seed-дублів), `reconcile-parent` (self-FK ієрархії — gap gen_catalog_batch). Пропущено: УведомленияПрограммы (6478, без Code); 51/78 довідників — 404 (не опубліковані).

## Стан стенду (BAS_REVERSE)

- app 100 MASTER (еталон), app 122 ERP (порожній цільовий), app 130 ВД, **app 200 BUDYNKY** (пілот; **13 сторінок**; браузери живих даних: Організації, Контрагенти, Користувачі, **Погодження** (стор. 11) + **Master-Detail стор. 12** (drill з стор.11: шапка процесу classic report + IR погоджувачів з резолвом Роль/Користувач)); **app 201 «ПОГОДЖЕННЯ»** — 2-й
  blueprint-track (Согласование master-detail на живих даних, app-builder-free:
  Дашборд 4 KPI+3 графіки / Faceted-список / модальна форма з 2 детальними звітами).
- **351 таблиця `RSD_*`** + **10 view** (батч 014: +3 reporting-view), **0 INVALID**: НСІ хвиль 1–4 (довідники) + **99 регістрів** + **8 документів** (25 табл.) + **13 BusinessProcess** (83 табл.).
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
2. ~~**§9 група 4b**~~ — **проаналізовано 2026-07-19, ВІДКЛАДЕНО** (рішення власника).
   Очевидні одиночні FK уже стоять (Подразделение→Структура, ФизЛицо→ФізОсоби —
   типізовані 003/005/008); решта untyped-`_ID` (514) вказують на ще не мігровані
   цілі → ані FK, ані backfill. Повертатись при міграції тих каталогів (зворотній
   reconcile). Деталі — `docs/section9-decisions.md` §4b.
3. **BP Шар 2 — Workflow у Designer**: ✅ **пілот «Согласование» ЗРОБЛЕНО** (батч 013):
   зібрано в Designer власником, наскрізний тест ID=94 (NULL→747, екземпляр COMPLETED),
   зафіксовано `export/`, закоммічено+запушено `a81fce8`. **Далі — тиражування** шаблоном
   на Утверждение/Рассмотрение/Ознакомление/Регистрація — **канонічним Switch зі скіла
   `apex-workflow`** (не лінійний fallback 013). Опц.: редагований IG погоджувачів;
   продакшн-учасники (identity-bridge BAS→APEX).
   **Новий скіл `apex-workflow`** (`.claude/skills/apex-workflow/`, 5 файлів): вивчено
   офіційний мануал APEX 26.1 (Workflows & Tasks, 22 сторінки + підсторінки) → концепції
   для новачка, каталог 13 активностей, зв'язки/стани, `APEX_HUMAN_TASK` API, рецепт
   Designer+код-first, міграція BAS-маршрутів. **Уточнення до рецепту 013**: нативне
   гілкування — активність `Switch` (`Check Workflow Variable`) по авто-змінній
   `TASK_OUTCOME` (+ `APPROVER`), які створює сама `Human Task - Create` активність, — а не
   «лінійно + вибір у коді».
4. **ERP-контур `/Riverside`** — інше джерело OData (BAS ERP, 41 підсистема,
   реф-корпус `../BAS new/reference-erp/`): свій кластер/маппінг, більший обсяг.
5. ✅ **Blueprint-track наскрізь — ЗРОБЛЕНО** (батч 014 → app 201 «ПОГОДЖЕННЯ»,
   Согласование master-detail на живих даних). Далі за бажанням: track для регістра
   (зріз-view) чи чистого документа; довести до app 122 як цільового, якщо треба.
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
- **APEX Workflow (26.1)** — уточнення межі 009: у APEXLang його НЕМАЄ (окремий
  SQL-трек, фіксувати експортом `-expType APPLICATION_SOURCE`), але **код-first
  можливий** через app-import `wwv_flow_imp_shared.create_workflow / _version /
  _activity / _transition / _branch / _participant / _variable / _comp_param` +
  `create_task_def*`. Типи активностей: `NATIVE_WORKFLOW_START/END`, `NATIVE_CREATE_TASK`
  (Human Task), `NATIVE_WORKFLOW_SWITCH` (гілки), `NATIVE_INVOKE_API` (Execute Code),
  `NATIVE_PARALLEL_WF`, `NATIVE_WORKFLOW_WAIT`, `NATIVE_SEND_EMAIL`. Рантайм:
  `apex_workflow.start_workflow(p_static_id,p_detail_pk)`→instance; задачі —
  `apex_approval.claim_task`/`complete_task(p_task_id,p_outcome,p_autoclaim)`; вью
  `APEX_WORKFLOWS`/`APEX_WORKFLOW_AUDIT`/`APEX_TASKS`. Прогін headless — під BAS_REVERSE
  з `apex_session.create_session(200,1,'CLAUDE')` (не sysdba: `ORA-06598`).
- **Поліморфізм**: композитні реквізити/виміри/ТЧ-поля (Предмет/Исполнитель/владелец)
  лишаються §9 (REF_TYPE/REF_ID) і **не вантажаться авто** section_block'ом —
  дорезолв цільовим UPDATE з RAW (`_Type`+UUID), як для погоджувачів у стор. 12.
- **Передача macOS→стенд**: `COPYFILE_DISABLE=1 tar` (не scp/docker cp — AppleDouble).
- **APEX Workflow — модель (мануал, скіл `apex-workflow`)**: маршрут = активності+зв'язки;
  каталог 13 типів (`Workflow Start/End`, `Execute Code`, `Human Task - Create`, `Switch`,
  `Parallel Flow`, `Wait`, `Invoke Workflow`, `Invoke API`, `Send Email/Push`, `Generate Text
  with AI`, `Custom Plug-in`). `Human Task - Create` авто-створює `TASK_OUTCOME`/`APPROVER`;
  гілкування — `Switch` (типи `True False`/`Check Workflow Variable`/`Case`/`If Elsif Else`), НЕ
  зв'язки. Зв'язки-транзиції: `Normal`/`Error`(по SQL-коду, інакше `Faulted`)/`Timeout`; окремо
  Branches (виходи Switch). Стани WF: `Active`/`Suspended`/`Completed`/`Terminated`/`Faulted`;
  активності: +`Waiting`. Активація потребує учасників маршруту (Owner/Admin) — вони ≠ виконавці
  задачі (Potential Owner). Ретенція: задачі 7/30 днів, WF-інстанси 30/100. Троблшутинг:
  `ORA-20987`=регістр імен (UPPER); scheduler-джоб=потрібна `apex_session.create_session`;
  `HANDLE_TASK_DEADLINES` форсує дедлайни; `APEX$TASK_ID` не працює в Actions SQL → `APEX$TASK_PK`.
- **Наскрізний огляд бібліотеки APEX 26.1 → 3 нові скіли** (6 агентів по кластерах; карта —
  [`docs/apex-doc-map.md`]). Заведено: **`apex-ui`** (вибір регіону/сторінки/item: IR vs IG,
  Faceted/Smart Filters, Cards, master-detail, 1C-поле→item), **`apex-plsql-apis`** (індекс 64
  пакетів `APEX_*` + сигнатури web_service/json/exec/session/acl/data_parser + headless-патерни;
  пастка `apex_acl.add_user_role` → тільки `p_role_static_id`), **`apex-security-deploy`** (auth/
  authz/ACL, Security Attributes, export/import, стенд-адмін; **корінь «злетілих ролей»**:
  призначення юзер→роль — дані в таблицях схеми, не експортуються → фікс = `apex_acl.add_user_role`
  у Supporting Objects Installation Script + `Yes and Install on Import Automatically`). Довесок у
  `bas2apex` — `references/ongoing-sync.md` (Web Credentials, Automations). Reference-only (свідомо
  без скілу): SQL Workshop, Quick SQL (грамотика не опублікована), Globalization (одна мова;
  актуальний термін `Dynamic Translation`, не легасі «Translation Repository»), Generative AI
  (не вживається; `APEX_AI` провайдери 26.1 включають Anthropic Claude). Разом покриття APEX:
  bas2apex · apexlang · apex-workflow · apex-ui · apex-plsql-apis · apex-security-deploy.
- `016-acl-grant-fix` — **ролі не злітають після `apex import` (app 200)**. Перевірено на стенді:
  призначення користувач→роль живуть у метаданих APEX (`apex_appl_acl_user_roles`), **не** в `.apx`
  → повний import їх втрачає. **Знахідка**: `apex_acl.add_user_role(p_role_static_id=>'admin')`
  падає `ORA-01403` (супереч доці Oracle) → робоча форма — lookup `role_id` за static_id +
  `p_role_id`. Артефакт: ідемпотентний `grant-roles.sql` (`@grant-roles.sql <app> <role> <users>`)
  + обгортка `regrant.sh` — **обов'язковий крок після кожного імпорту** (`regrant.sh 200 admin
  CLAUDE,VIKTOR`). Перевірено циклом зняти→0→grant→відновлено + ідемпотентність. Скіл
  `apex-security-deploy` виправлено (Supporting Objects — для SQL-формату, не APEXlang; форма
  гранта). Живий повний реімпорт не проганявся (команда `-workspaceId` у заметках суперечлива;
  фікс детермінований у будь-якому разі).

## Команди для швидкого старту (деталі — docs/stand.md)

```bash
ssh apex-vps "docker ps"                        # стан стека
# app 200: https://apex.173-242-60-109.sslip.io/ords/f?p=200  (CLAUDE / див. /root/apex-credentials.txt)
# APEXLang app 200 — джерело правди: applications/budynky/
#   перенос: COPYFILE_DISABLE=1 tar -cf - budynky | ssh apex-vps 'docker exec -i apex-ords tar -xf - -C /tmp/imp'
#   валід/імпорт (LANG=C.utf8): apex validate|import -workspaceId 5350230995185067  (в контейнері apex-ords, як sys)
#   re-export (репо=стенд): apex export -applicationid 200 -exptype APEXLANG -dir  (під схемою BAS_REVERSE)
```
