#!/usr/bin/env bash

set -eo pipefail

. /usr/local/bin/ergonode-common-functions.sh

psql -v ON_ERROR_STOP=1 \
    --dbname "$db" \
    --username="$user" <<-EOSQL
    CREATE DATABASE ${app_db} OWNER ${app_user};
EOSQL
