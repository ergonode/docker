#!/usr/bin/env bash

set -e

psql -v ON_ERROR_STOP=1 \
    --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE DATABASE ${APP_DB};
    GRANT ALL PRIVILEGES ON DATABASE ${APP_DB} TO ${APP_USER};
EOSQL
