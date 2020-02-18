#!/usr/bin/env bash

set -eo pipefail

. /usr/local/bin/ergonode-common-functions.sh

if [[ -z "${app_test_db}" ]] ; then
  exit 0
fi

psql -v ON_ERROR_STOP=1 \
    --dbname "$db" \
    --username="$user" <<-EOSQL
    CREATE DATABASE ${app_test_db} OWNER ${app_user};
EOSQL
