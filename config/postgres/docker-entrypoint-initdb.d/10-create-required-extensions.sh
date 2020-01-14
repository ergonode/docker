#!/usr/bin/env bash

set -e

psql -v ON_ERROR_STOP=1 \
    --dbname "template1" <<-EOSQL
    CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
    CREATE EXTENSION IF NOT EXISTS "ltree";
EOSQL
