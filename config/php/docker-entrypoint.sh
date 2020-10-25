#!/bin/bash

set -e

function genereJwtKeys() {
  local privatePath=$1
  local publicPath=$2
  local passArg=$3

  openssl genrsa -aes256 -passout "${passArg}" -out "${privatePath}" 4096
  openssl rsa -pubout -in  "${privatePath}"  -passin "${passArg}" -out "${publicPath}"
  chown root:www-data "${privatePath}"
  chmod 640 "${privatePath}" "${publicPath}"
}

function waitUntil() {
  until "$@"  > /dev/null 2>&1 ; do
    sleep 1
  done
}

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- php-fpm "$@"
fi

>&2 echo "Create directories"
mkdir -p var/cache var/log public/multimedia public/thumbnail public/avatar import export
chown -R www-data var public/multimedia public/thumbnail public/avatar import export

>&2 echo "Generate JWT keys"
genereJwtKeys "config/jwt/private.pem" "config/jwt/public.pem" 1234

>&2 echo "Composer install"
#composer install --prefer-dist --no-progress --no-suggest --no-interaction
#composer dump-autoload --optimize
#composer dump-env dev

>&2 echo "Waiting for db to be ready"
waitUntil bin/console doctrine:query:sql "SELECT 1"

>&2 echo "Build application"
bin/phing build

>&2 echo "Database migrations"
bin/console ergonode:migrations:migrate --no-interaction --allow-no-migration

>&2 echo "Setup CRON"
service cron start &

>&2 echo "Setup Supervisor"
service supervisor start &

>&2 echo "Initialization finished"
exec "php-fpm"
