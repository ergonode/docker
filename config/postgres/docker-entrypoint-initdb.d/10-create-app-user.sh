#!/usr/bin/env bash

set -eo pipefail

. /usr/local/bin/ergonode-common-functions.sh

#escape string with double quotes
app_password=${app_password/\'/\'\'}


psql -v ON_ERROR_STOP=1 \
    --dbname "$db" \
    --username="$user" <<-EOSQL
    CREATE ROLE ${app_user} LOGIN  PASSWORD '${app_password}' CREATEDB;
EOSQL
