#!/usr/bin/env bash

set -eo pipefail

. /usr/local/bin/ergonode-common-functions.sh

psql -v ON_ERROR_STOP=1 \
    --dbname "template1" \
    --username="$user" <<-EOSQL
    CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
    CREATE EXTENSION IF NOT EXISTS "ltree";
EOSQL
