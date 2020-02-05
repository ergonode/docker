#!/usr/bin/env bash

set -e

#escape string with double quotes
password=${APP_USER_PASSWORD/\'/\'\'}

psql -v ON_ERROR_STOP=1 \
    --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE ROLE ${APP_USER} LOGIN  PASSWORD '${password}' CREATEDB;
EOSQL
