#!/usr/bin/env bash

set -e


password=${APP_USER_PASSWORD}
if [ -n "${APP_USER_PASSWORD_FILE}" ] ; then
 password=$(cat "${APP_USER_PASSWORD_FILE}")
fi

#escape string with double quotes
password=${password/\'/\'\'}


psql -v ON_ERROR_STOP=1 \
    --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE ROLE ${APP_USER} LOGIN  PASSWORD '${password}' CREATEDB;
EOSQL
