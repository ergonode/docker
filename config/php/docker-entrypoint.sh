#!/bin/bash

set -e

function jwtKeysAreCorrect() {
  local privatePath=$1
  local publicPath=$2
  local passArg=$3

  echo 1234 > /tmp/to-sign.txt
  openssl dgst -sha256 -sign   "${privatePath}" -passin "${passArg}"  -out /tmp/sign.sha256 /tmp/to-sign.txt 2>/dev/null
  openssl dgst -sha256 -verify "${publicPath}" -signature /tmp/sign.sha256 /tmp/to-sign.txt 2>/dev/null
}

function genereJwtKeys() {
  local privatePath=$1
  local publicPath=$2
  local passArg=$3

  openssl genrsa -aes256 -passout "${passArg}" -out "${privatePath}" 4096
  openssl rsa -pubout -in  "${privatePath}"  -passin "${passArg}" -out "${publicPath}"
}

function fixPermissionForJwtKeys() {
  local privatePath=$1
  local publicPath=$2

  chown root:www-data "${privatePath}"
  chmod 640 "${privatePath}"
  chmod 640 "${publicPath}"
}

function genereJwtKeysIfInvalid() {
  local privatePath=$1
  local publicPath=$2
  local passArg=$3

  if ! jwtKeysAreCorrect  "${privatePath}" "${publicPath}" "${passArg}"; then
    >&2 echo "Generating jwt keys..."
    genereJwtKeys "${privatePath}" "${publicPath}" "${passArg}"
  fi

  fixPermissionForJwtKeys "${privatePath}" "${publicPath}"
}

function waitUntil() {
  until "$@"  > /dev/null 2>&1 ; do
    sleep 1
  done
}

function createApplicationDirs() {
  mkdir -p var/cache var/log public/multimedia public/thumbnail public/avatar import export
  >&2 echo "Setting file permissions..."
  if setfacl -m u:www-data:rwX -m u:"$(whoami)":rwX var ; then
    setfacl -R -m u:www-data:rwX -m u:"$(whoami)":rwX var
    setfacl -dR -m u:www-data:rwX -m u:"$(whoami)":rwX var
    setfacl -R -m u:www-data:rwX -m u:"$(whoami)":rwX public/multimedia
    setfacl -dR -m u:www-data:rwX -m u:"$(whoami)":rwX public/multimedia
    setfacl -R -m u:www-data:rwX -m u:"$(whoami)":rwX public/thumbnail
    setfacl -dR -m u:www-data:rwX -m u:"$(whoami)":rwX public/thumbnail
    setfacl -R -m u:www-data:rwX -m u:"$(whoami)":rwX public/avatar
    setfacl -dR -m u:www-data:rwX -m u:"$(whoami)":rwX public/avatar
    setfacl -R -m u:www-data:rwX -m u:"$(whoami)":rwX import
    setfacl -dR -m u:www-data:rwX -m u:"$(whoami)":rwX import
    setfacl -R -m u:www-data:rwX -m u:"$(whoami)":rwX export
    setfacl -dR -m u:www-data:rwX -m u:"$(whoami)":rwX export
  else
    chown -R www-data var
    chown -R www-data public/multimedia
    chown -R www-data public/thumbnail
    chown -R www-data public/avatar
    chown -R www-data import
    chown -R www-data export
   fi
}

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- php-fpm "$@"
fi

>&2 echo "Create directories..."
createApplicationDirs

#>&2 echo "Generate JWT keys..."
#genereJwtKeysIfInvalid "config/jwt/private.pem" "config/jwt/public.pem" 1234

>&2 echo "Composer install..."
composer install --prefer-dist --no-progress --no-suggest --no-interaction
composer dump-autoload --optimize
composer dump-env dev

>&2 echo "Waiting for db to be ready..."
waitUntil bin/console doctrine:query:sql "SELECT 1"

>&2 echo "Build application..."
bin/phing build

>&2 echo "Database migrations..."
bin/console ergonode:migrations:migrate --no-interaction --allow-no-migration

>&2 echo "Starting workers..."
service supervisor start

>&2 echo "Initialization finished"
exec "$@"
