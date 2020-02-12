#!/bin/bash

set -e

function disableXdebug() {
  if [ -f "/usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini" ] ; then
    mv /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini /usr/local/etc/docker-php-ext-xdebug.ini
  fi
}

function enableXdebug() {
  if [ -f "/usr/local/etc/docker-php-ext-xdebug.ini" ] ; then
    mv /usr/local/etc/docker-php-ext-xdebug.ini /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
  fi
}

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
  chmod 640  "${publicPath}"
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

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- php-fpm "$@"
fi

if [ "$1" = 'php-fpm' ] || [[ "$1" =~ (vendor/)?bin/.* ]] || [ "$1" = 'composer' ]; then

	PHP_INI_RECOMMENDED="$PHP_INI_DIR/php.ini-production"
	if [ "$APP_ENV" != 'prod' ]; then
		PHP_INI_RECOMMENDED="$PHP_INI_DIR/php.ini-development"
	fi
	echo "Linking ${PHP_INI_RECOMMENDED} > ${PHP_INI_DIR}/php.ini"
	ln -sf "$PHP_INI_RECOMMENDED" "$PHP_INI_DIR/php.ini"

    disableXdebug
    genereJwtKeysIfInvalid "${JWT_PRIVATE_KEY_PATH}" "${JWT_PUBLIC_KEY_PATH}" env:JWT_PASSPHRASE
fi

if [ "$1" = 'php-fpm' ] ; then
    mkdir -p var/cache var/log public/multimedia
    >&2 echo "Setting file permissions..."
    setfacl -R -m u:www-data:rwX -m u:"$(whoami)":rwX var  >/dev/null 2>&1
    setfacl -dR -m u:www-data:rwX -m u:"$(whoami)":rwX var >/dev/null 2>&1
    setfacl -R -m u:www-data:rwX -m u:"$(whoami)":rwX public/multimedia  >/dev/null 2>&1
    setfacl -dR -m u:www-data:rwX -m u:"$(whoami)":rwX public/multimedia >/dev/null 2>&1



    if [ "$APP_ENV" != 'prod' ]; then
        composer install --prefer-dist --no-progress --no-suggest --no-interaction
    fi

    >&2 echo "Waiting for db to be ready..."
    counter=0
    waitUntil bin/console doctrine:query:sql "SELECT 1"

    if [ "$APP_ENV" != 'prod' ]; then
      bin/phing build
      enableXdebug
    fi

    bin/console ergonode:migrations:migrate --no-interaction --allow-no-migration

    if [ "$APP_ENV" != 'prod' ]; then
        echo -e "\e[30;48;5;82mergonode  api is available at http://localhost:${EXPOSED_NGINX_PORT} \e[0m"
    fi

    >&2 echo "app initialization finished"
fi

exec docker-php-entrypoint "$@"