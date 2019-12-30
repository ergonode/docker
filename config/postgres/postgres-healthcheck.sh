##!/usr/bin/env bash

host="$(hostname -i || echo '127.0.0.1')"

PGPASSWORD=$POSTGRES_PASSWORD psql \
    --host="$host" \
    --username="$POSTGRES_USER" \
    --dbname="$POSTGRES_DB" \
    --quiet --no-align --tuples-only \
    --command "SELECT 1"
