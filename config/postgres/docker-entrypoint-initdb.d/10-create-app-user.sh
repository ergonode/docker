#!/usr/bin/env bash

set -e

psql -v ON_ERROR_STOP=1 \
    --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE ROLE ${APP_USER} LOGIN  PASSWORD '${APP_USER_PASSWORD}';
EOSQL
