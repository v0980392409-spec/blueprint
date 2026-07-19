#!/usr/bin/env bash
# Перевидати ACL-ролі на стенді після `apex import` (APEXlang не тримає призначень).
# Обов'язковий крок після кожного імпорту застосунку. Ідемпотентно.
#   Usage: ./regrant.sh [APP_ID] [ROLE_STATIC_ID] [USERS_CSV]
#   Default: ./regrant.sh 200 admin CLAUDE,VIKTOR
set -euo pipefail
APP="${1:-200}"; ROLE="${2:-admin}"; USERS="${3:-CLAUDE,VIKTOR}"
DIR="$(cd "$(dirname "$0")" && pwd)"
cat "$DIR/grant-roles.sql" | ssh apex-vps 'cat >/tmp/grant-roles.sql; docker cp /tmp/grant-roles.sql apex-ords:/tmp/grant-roles.sql >/dev/null 2>&1'
ssh apex-vps "PW=\$(grep '^schema BAS_REVERSE' /root/apex-credentials.txt | awk '{print \$4}'); \
  docker exec apex-ords /opt/oracle/sqlcl/bin/sql -s BAS_REVERSE/\$PW@//db:1521/FREEPDB1 @/tmp/grant-roles.sql $APP $ROLE $USERS"
