# Стенд, доступи, цільовий застосунок

## Стенд Oracle APEX 26.1 (VPS)

| Що | Значення |
|---|---|
| VPS | 173.242.60.109 (Хостинг Україна, Ubuntu 24.04) |
| SSH | `ssh apex-vps` — алиас у `~/.ssh/config` (root, ключ `id_ed25519_vps_saga`) |
| APEX / ORDS | <https://apex.173-242-60-109.sslip.io/ords/> |
| Стек | Docker Compose у `/opt/apex-stand`: `apex-db` (Oracle Database Free 26ai), `apex-ords` (ORDS 26.1 + APEX 26.1), `apex-caddy` (HTTPS), `apex-minio` (файлове сховище) |
| Секрети | **лише** на VPS у `/root/apex-credentials.txt` та `/opt/apex-stand/.env` — у репо не комітяться |
| SQLcl | всередині контейнера ORDS: `docker exec -it apex-ords /opt/oracle/sqlcl/bin/sql` |

Інфраструктурні скрипти стенду (docker-compose, Caddyfile, jetty-http.xml, minio-init) живуть у сусідньому репо
[`../revers/infra/apex-vps/`](https://github.com/v0980392409-spec/revers) — тут не дублюються, щоб не розходились.

## Workspace і застосунки

| App ID | Назва | Призначення |
|---|---|---|
| 100 | MASTER | еталонний майстер-застосунок BAS MASTER (конвенції UI, фреймворк синхронізації `bas_sync_pkg`) |
| **122** | **ERP** | **цільовий застосунок цього експерименту** — міграція BAS ERP |

- Workspace / схема БД: `BAS_REVERSE`.
- Прямий лінк на App Builder застосунку 122:
  `https://apex.173-242-60-109.sslip.io/ords/r/apex/app-builder/home?fb_flow_id=122`

## Джерело даних BAS (OData)

- Сервер: `https://rv.entercom.ua:5683/`, Basic auth (логін/пароль — у `/root/apex-credentials.txt` на VPS).
- Бази: ERP — `/Riverside/odata/standard.odata/`, Документообіг — `/bas_doc/odata/standard.odata/`.
- Пастки: `404` = «сутність не опублікована», кирилиця в URL — тільки через екранування,
  Web Credential в APEX створювати з Allowed URLs = хост OData.

## Корисні команди

```bash
# стан стека
ssh apex-vps "docker ps"

# SQL*Plus до БД (кирилиця — обовʼязково NLS_LANG)
ssh apex-vps 'source /opt/apex-stand/.env && docker exec -i -e NLS_LANG=.AL32UTF8 apex-db sqlplus sys/$ORACLE_PWD@FREEPDB1 as sysdba'

# SQLcl (для apex export / apex validate — APEXLang)
ssh apex-vps 'docker exec -it apex-ords /opt/oracle/sqlcl/bin/sql BAS_REVERSE@//db:1521/FREEPDB1'

# експорт застосунку 122 у APEXLang (.apx), з SQLcl:
#   apex export -applicationid 122 -as-apexlang
# валідація APEXLang-каталогу:
#   apex validate -dir <каталог>
```

## Суміжні локальні репозиторії

| Шлях | Що це |
|---|---|
| `../revers` | перший експеримент: реверс BAS Документообіг на APEX (SDD-конвеєр, ui-conventions, apex-master, infra стенду) |
| `../BAS new` | as-is корпус BAS: `reference/` (Документообіг) і `reference-erp/` (BAS ERP, 41 підсистема) — згенеровані з XML-дампів конфігурацій |
