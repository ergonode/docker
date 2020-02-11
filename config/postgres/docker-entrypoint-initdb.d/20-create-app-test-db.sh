#!/usr/bin/env bash

set -e
if [[ -z "${APP_TEST_DB}" ]] ; then
  exit 0
fi

psql -v ON_ERROR_STOP=1 \
    --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE DATABASE ${APP_TEST_DB} OWNER ${APP_USER};
EOSQL
