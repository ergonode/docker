#!/usr/bin/env bash

set -e

psql -v ON_ERROR_STOP=1 \
    --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE DATABASE ${APP_DB} OWNER ${APP_USER};
EOSQL
