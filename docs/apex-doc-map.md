# Карта документації Oracle APEX 26.1 → скіли

Підсумок наскрізного огляду **всієї** бібліотеки APEX 26.1
(<https://docs.oracle.com/en/database/oracle/apex/26.1/>). Мета — не переказати тисячі сторінок, а
зафіксувати: **де що лежить** і **чим у репо покрито** (скіл vs reference-only). Огляд зроблено 6
агентами по кластерах; глибоко читалося те, що релевантне міграції BAS→APEX.

## 1. Каталог бібліотеки (books.html)

| Код | Книга | Релевантність проекту |
|---|---|---|
| `htmdb` | **App Builder User's Guide** (Develop Apps) | ★★★ головна: регіони/форми, безпека, деплой, workflow, дані |
| `aeapi` | **PL/SQL API Reference** | ★★★ 64 пакети `APEX_*` |
| `aeadm` | **Administration Guide** | ★★ інстанс-адмін (вузький зріз для стенду) |
| `apxln` | **APEXlang API Reference** | ★★ генерована схема `.apx` (+ `apexlang.ebnf`) — джерело правди синтаксису |
| `htmrn` | **Release Notes 26.1** | ★★ нові фічі (Blueprints, APEXlang, Workflow, AI) |
| `apxdc` | **Developer's Companion** | ★★ кукбук-патерни (сюди влилися колишні Best Practices) |
| `aeutl` | **SQL Workshop Guide** | ★ Object Browser/SQL/Quick SQL — проект жене SQLcl напряму |
| `aexjs` | **JavaScript API Reference** | ★ клієнтський JS (поза поточним обсягом) |
| `apxdr` | **Data Reporter Guide** / `aeeug` End User's / `aeacc` Accessibility / `aelim` Licensing / `htmig` Installation | низька для внутрішнього ERP-інструменту |

**Best Practices як окремої книги в 26.1 немає** — розчинена в `apxdc` + главах `htmdb` (Security,
Performance, Debugging, Deployment).

## 2. Карта покриття скілами

| Тема | Скіл / місце | Джерело (книга) |
|---|---|---|
| XML-дамп 1С → таблиці/blueprint (конвеєр) | **`bas2apex`** | — |
| `.apx` синтаксис/компіляція | **`apexlang`** (офіц. Oracle) | `apxln` |
| Маршрути/Workflow + Human Task | **`apex-workflow`** | `htmdb` гл. 20 |
| Вибір регіону/сторінки/item (BAS-об'єкт → UI) | **`apex-ui`** ✨ | `htmdb` гл. 8, регіони, форми |
| Сигнатури пакетів `APEX_*` + headless-патерни | **`apex-plsql-apis`** ✨ | `aeapi` |
| Auth/authz/ACL, Security Attributes, export/import, стенд-адмін | **`apex-security-deploy`** ✨ | `htmdb` гл. 21/25, `aeadm` |
| Web Credentials + Automations + REST Sync (довесок до даних) | **`bas2apex/references/ongoing-sync.md`** ✨ | `htmdb` гл. 18/19 |
| Live OData → RSD_ (ручний двофазний завантажувач) | **`bas2apex`** (data track) | — |

✨ — додано цією сесією.

## 3. Reference-only (скіл не заводили — чому)

- **SQL Workshop / Quick SQL** — проект жене SQLcl/sqlplus напряму; **грамотика Quick SQL не
  опублікована онлайн** (лише in-product Help) → скіл галюцинував би синтаксис. Плюс конвенції репо
  (`RSD_`, `DELETION_MARK`, без GUID) не збігаються з дефолтами Quick SQL — derive-стадія `bas2apex`
  точніша.
- **Globalization (гл. 22)** — сьогодні одна фіксована мова (українська дослівно з BAS), живого
  workflow перекладу немає; `apex_lang` уже в scope `apex-plsql-apis`. **Термінологія (уточнення):**
  актуальні терміни 26.1 — **`Dynamic Translation`** (для LOV/рядків, через `APEX_LANG.LANG`),
  **`Text Message-Based`** переклад (рядки в Shared Components → Text Messages, `&{NAME}.`,
  експорт/імпорт XLIFF/CSV — нове в 26.1), **`Application Primary Language`**. Легасі-назви
  «Character Value» / «Translation Repository» у 26.1 **не вживаються** — не шукати їх у доці.
- **Generative AI (§18.9)** — у репо не використовується. Але: пакет **`APEX_AI`** (`GENERATE`/`CHAT`
  + attachments, нове 26.1) логічно доповнює `apex-plsql-apis` (він уже в індексі пакетів). Провайдери
  26.1 включають **Anthropic Claude**. Активності/процеси `Generate Text with AI` — див. `apex-ui`/
  `apex-workflow` каталоги. Заводити скіл — лише коли з'явиться реальна AI-фіча в мігрованому app.
- **Accessibility** — низька релевантність (внутрішній інструмент); базлайн — Universal Theme (уже є).

## 4. Нові фічі 26.1, дотичні до проекту (Release Notes)

- **Blueprints** (§2.30) — Markdown-blueprint для Spec-Driven Development — **це і є трек цього репо**
  (`blueprints/`), тепер first-class фіча, не бета.
- **APEXlang** (§2.1) — `.apx` як джерело правди у VCS; 4 типи експорту; **runtime-дані для APEXlang
  не експортуються**; імпорт APEXlang лише цілим app (не постранично) через UI (ORDS 26.1.1+) → SQLcl.
- **Workflow** (§2.4) — Parallel Flow, мультитенант/Tenant ID, `APEX_WORKFLOW.SET_ACTIVITY_DUE_DATE`
  (перевірити в `apex-workflow` при нагоді).
- **AI** (§2.2) — NL2IR, Create Page via NL, AI Agent Tools + guardrails, structured JSON output,
  додаткові провайдери.

## 5. Висновок

Наскрізний огляд бібліотеки → **3 нові скіли** (`apex-ui`, `apex-plsql-apis`, `apex-security-deploy`)
+ довесок у `bas2apex` (`ongoing-sync.md`). Решта книг — reference-only (свідомо, щоб не плодити
скіли-порожняки): рішення обґрунтовано в §3. Разом покриття APEX для цього проекту тепер: **конвеєр
(bas2apex) · синтаксис (apexlang) · маршрути (apex-workflow) · UI (apex-ui) · API (apex-plsql-apis) ·
безпека+деплой+стенд (apex-security-deploy)**.
