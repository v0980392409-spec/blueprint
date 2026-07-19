# Ядровые пакеты APEX_* — сигнатуры и паттерны

Дословные сигнатуры высокочастотных пакетов + headless-паттерны. Индекс всех 64 — в
[package-index.md](package-index.md). Границы (workflow/OData/.apx) — в [SKILL.md](../SKILL.md).

## APEX_WEB_SERVICE — REST/SOAP

```sql
apex_web_service.make_rest_request(
  p_url                  in varchar2,
  p_http_method          in varchar2,
  p_username             in varchar2 default null,
  p_password             in varchar2 default null,
  p_scheme               in varchar2 default 'Basic',   -- Basic|AWS|Digest|OAUTH_CLIENT_CRED
  p_body                 in clob     default empty_clob(),
  p_body_blob            in blob     default empty_blob(),
  p_parm_name            in apex_application_global.vc_arr2 default empty_vc_arr,
  p_parm_value           in apex_application_global.vc_arr2 default empty_vc_arr,
  p_transfer_timeout     in number   default 180,
  p_wallet_path          in varchar2 default null,
  p_https_host           in varchar2 default null,
  p_credential_static_id in varchar2 default null,      -- имя Web Credential (Shared Components)
  p_token_url            in varchar2 default null,       -- OAuth2 token endpoint
  p_oauth_scope          in varchar2 default null) return clob;
-- make_rest_request_b — идентична, но return BLOB (бинарный payload/скачивание файла)
```
Заголовки/cookies — package-глобалы: `set_request_headers(p_name_01, p_value_01, …, p_reset =>
true, p_skip_if_exists => false)`. Ответ: `g_status_code` (pls_integer, 200/400…), `g_reason_phrase`,
`g_headers` (header_table). OAuth по хранимому креденшелу: `oauth_authenticate_credential(p_token_url,
p_credential_static_id, p_scope…)` → токен кэшируется в глобале для следующих запросов.

> **Вне браузера** (SQLcl/scheduler): Web Credentials работают, если DB-юзер сопоставлен с
> workspace. Если с несколькими — сначала `apex_util.set_workspace('BAS_REVERSE')` или
> `apex_util.set_security_group_id(<id из apex_applications.workspace_id>)`.

## APEX_JSON — парсинг/генерация

```sql
apex_json.parse(p_values in out nocopy t_values, p_source in clob, p_strict in boolean default true);
apex_json.get_varchar2(p_path in varchar2, p0..p4 default null, p_values in t_values default g_values) return varchar2;
apex_json.get_count   (p_path in varchar2, p0..p4 default null, p_values default g_values) return number;   -- размер массива/объекта
apex_json.get_members (p_path in varchar2, …) return apex_t_varchar2;   -- ключи объекта
-- ещё: get_number/get_date/get_clob/get_boolean, does_exist, find_paths_like, stringify (экранировать скаляр)
```
Пример: `apex_json.parse(j, l_clob); v := apex_json.get_varchar2('items[%d].foo', p0=>3, p_values=>j);`
Свой `p_values` — чтобы не затирать глобал `g_values` параллельными парсингами.

## APEX_DATA_PARSER — CSV/XLSX/XML/JSON → строки

```sql
select line_number, col001, col002 /* … col300 */
from table(apex_data_parser.parse(
       p_content   => l_blob,
       p_file_name => 'x.xlsx',        -- ИЛИ p_file_type / p_file_profile (одно обязательно)
       p_row_selector => null,          -- JSON/XML: путь к массиву строк
       p_xlsx_sheet_name => null,
       p_max_rows => null,
       p_file_charset => 'AL32UTF8'));
-- константы t_file_type: 1 xlsx, 2 csv, 3 xml, 4 json, 5 ics
-- спутники: discover (профиль без полного парса), get_columns, get_xlsx_worksheets
```

## APEX_EXEC — единая абстракция запросов (local/remote/REST source)

Нужна APEX-сессия. **Всегда** `close` в обработчике исключений (иначе течёт курсор/temp LOB).
```sql
declare l_ctx apex_exec.t_context; l_i pls_integer;
begin
  l_ctx := apex_exec.open_query_context(
             p_location  => apex_exec.c_location_local_db,  -- | c_location_remote_db | c_location_rest_source
             p_sql_query => 'select * from emp');
  l_i := apex_exec.get_column_position(l_ctx, 'ENAME');
  while apex_exec.next_row(l_ctx) loop
    dbms_output.put_line(apex_exec.get_varchar2(l_ctx, l_i));
  end loop;
  apex_exec.close(l_ctx);
exception when others then apex_exec.close(l_ctx); raise;
end;
-- REST Data Source как rowset (без ручного JSON):
--   l_ctx := apex_exec.open_rest_source_query(p_static_id => 'ODATA_CATALOG', p_max_rows => 1000);
```

## APEX_SESSION — сессия для headless

```sql
apex_session.create_session(p_app_id in number, p_page_id in number, p_username in varchar2,
                            p_call_post_authentication in boolean default false);
apex_session.attach(p_app_id, p_page_id, p_session_id);   -- к существующей сессии
apex_session.detach;                                       -- сброс env + Cleanup PL/SQL
```

## APEX_ACL — роли (пастка p_role_id)

```sql
-- ✅ в скриптах/при реимпортах — static id (портируемый, регистронезависимый):
apex_acl.add_user_role(p_application_id => 122, p_user_name => 'CLAUDE', p_role_static_id => 'admin');
-- ❌ p_role_id — суррогат из APEX_APPL_ACL_ROLES, пересоздаётся при импорте → не та роль/ошибка:
--    apex_acl.add_user_role(p_application_id => 122, p_user_name => 'CLAUDE', p_role_id => 12345);
apex_acl.has_user_role(p_application_id => 122, p_user_name => 'CLAUDE', p_role_static_id => 'admin') return boolean;
```
Это и есть «ACL wiped after import» из `bas2apex`/`apex-workflow`: после `apex import` роли назначить
заново, static id-перегрузкой.

## APEX_STRING / APEX_UTIL — хелперы

```sql
apex_string.split(p_str, p_sep default apex_application.lf, p_limit) return apex_t_varchar2;
--   p_sep: null=посимвольно; 1 символ=литерал; >1=regexp (≤512). split('1:2:3',':') -> ('1','2','3')
apex_string.join(p_table, p_sep default lf) return varchar2;
-- ещё: string_to_table/table_to_string/table_to_clob, push, grep, format, plist_*

apex_util.set_security_group_id(p_security_group_id in number);   -- workspace для батча/джоба
apex_util.get_session_state(p_item) return varchar2;              -- = функция V()
```
Deprecated (не брать): `apex_util.string_to_table/table_to_string` → `apex_string`.
`APEX_STRING_UTIL` — другой пакет (regex-извлечение emails/links/slug/diff), не путать.

## APEX_APPLICATION_INSTALL — скриптовый импорт

```sql
declare l_src apex_t_export_files;
begin
  l_src := apex_t_export_files(apex_t_export_file(
             name => 'f100.sql',
             contents => apex_web_service.make_rest_request(p_url=>'https://…/f100.sql', p_http_method=>'GET')));
  apex_util.set_workspace('BAS_REVERSE');
  apex_application_install.generate_application_id;   -- или set_application_id(p_application_id)
  apex_application_install.generate_offset;            -- или set_offset для детерминированного remap
  apex_application_install.install(p_source => l_src);
end;
-- ещё set_*: set_schema/set_application_alias/set_application_name/set_authentication_scheme/set_workspace_id; clear_all
```

## APEX_LANG — перевод сообщений (нет APEX_L10N!)

```sql
apex_lang.get_message(p_name in varchar2, p_params in apex_t_varchar2 default apex_t_varchar2(),
                      p_lang in varchar2 default null, p_application_id in number default null) return varchar2;
--   'GREETING' = 'Good morning %name' → apex_lang.get_message('GREETING', apex_t_varchar2('name', :P1_NAME))
-- workflow перевода: create/update/delete_message, seed_translations, apply_xliff_document, publish_application
-- локаль сессии (не сообщения) — apex_util.set_session_lang/territory/time_zone
```

## APEX_CREDENTIAL — Web Credentials кодом

```sql
apex_credential.create_credential(p_credential_name, p_credential_static_id, p_authentication_type,
  -- p_authentication_type: apex_credential.c_type_basic | c_type_oauth_client_cred | c_type_jwt | c_type_oci | c_type_http_header | c_type_http_query_string
  p_allowed_urls => apex_t_varchar2('https://rv.entercom.ua:5683/'), p_prompt_on_install => false);
apex_credential.set_persistent_credentials(p_credential_static_id => 'BAS_DOC_CRED',
  p_client_id => '…', p_client_secret => '…');   -- собственно секрет
```

---

## Headless-паттерны

**1. Boilerplate (SQLcl / scheduler, без браузера):**
```sql
apex_util.set_workspace('BAS_REVERSE');
apex_session.create_session(p_app_id => 122, p_page_id => 1, p_username => 'CLAUDE');  -- для apex_exec/collection/session-вызовов
-- … работа …
apex_session.detach;
```

**2. REST → распарсить одиночный/нерегулярный JSON:**
```sql
l_clob := apex_web_service.make_rest_request(p_url=>l_url, p_http_method=>'GET', p_credential_static_id=>'BAS_DOC_CRED');
apex_json.parse(l_vals, l_clob);
for i in 1 .. apex_json.get_count('value', p_values=>l_vals) loop
  l_name := apex_json.get_varchar2('value[%d].Description', p0=>i, p_values=>l_vals);
end loop;
```

**3. Массовый REST-массив → таблица (нативный SQL, быстро):**
```sql
insert into stg
select * from json_table(l_clob, '$.value[*]' columns(ref_key varchar2(36) path '$.Ref_Key', doc clob format json path '$'));
```
Это ровно то, что генерит `bas2apex/tools/gen_odata_loaders.py` (make_rest_request + JSON_TABLE +
session). **Не переизобретать** — для BAS-OData загрузчика идти в `bas2apex`. `apex_json` parse-and-
walk — только для одиночного/глубоко-нерегулярного объекта.

**4. REST Data Source как rowset** (без ручного JSON — если источник уже shared-компонент):
```sql
l_ctx := apex_exec.open_rest_source_query(p_static_id => 'ODATA_CATALOG', p_max_rows => 1000);
while apex_exec.next_row(l_ctx) loop … apex_exec.get_varchar2(l_ctx, l_idx) … end loop;
apex_exec.close(l_ctx);
```

**5. Идемпотентная выдача ролей в миграционных скриптах** — только static id:
```sql
apex_acl.add_user_role(p_application_id => 122, p_user_name => l_user, p_role_static_id => 'admin');
```

**6. Скриптовая установка приложения** — см. `APEX_APPLICATION_INSTALL` выше
(`set_workspace` → `generate_application_id`/`set_application_id` → `generate_offset` → `install`).

> **Спайк:** `APEX_REST_SOURCE_SYNC.synchronize_data` — встроенный merge REST-источника в таблицу
> (scheduled/on-demand), возможная лёгкая альтернатива ручным загрузчикам для малых сущностей. Но
> для больших сущностей BAS нужна пагинация по Code-префиксу (не `$skip`/GUID) — проверить, тянет
> ли встроенная пагинация, прежде чем полагаться.
