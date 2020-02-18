##!/usr/bin/env bash

host="$(hostname -i || echo '127.0.0.1')"

password=${POSTGRES_PASSWORD}
if [ -n "${POSTGRES_PASSWORD_FILE}" ] ; then
 password=$(cat "${POSTGRES_PASSWORD_FILE}")
fi

PGPASSWORD=${password} psql \
    --host="$host" \
    --username="$POSTGRES_USER" \
    --dbname="$POSTGRES_DB" \
    --quiet --no-align --tuples-only \
    --command "SELECT 1"
