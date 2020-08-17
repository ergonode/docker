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

function createAmqpVhost() {
    local scheme=$(echo $1 | php -r "echo @parse_url(stream_get_contents(STDIN))['scheme'];")

    if [[ "${scheme}" != 'amqp' ]] ; then
        return 0
    fi

    local host=$(echo $1 | php -r "echo @parse_url(stream_get_contents(STDIN))['host'];")
    #local port=$(echo $1 | php -r "echo @parse_url(stream_get_contents(STDIN))['port'];")
    local port=15672
    local user=$(echo $1 | php -r "echo @parse_url(stream_get_contents(STDIN))['user'];")
    local pass=$(echo $1 | php -r "echo @parse_url(stream_get_contents(STDIN))['pass'];")
    local path=$(echo $1 | php -r "echo @parse_url(stream_get_contents(STDIN))['path'];")
    local vhost=$(echo $1 | php -r "echo (@explode('/', @parse_url(stream_get_contents(STDIN))['path']))[1];")

    local  url="http://${host}:${port}/api/vhosts/${vhost}"
    local  userPass="${user}:${pass}"
    curl -u "${userPass}" --fail "${url}" ||  curl  --silent  --show-error  -u "${userPass}" --fail -X PUT "${url}"
}

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- php-fpm "$@"
fi


envsubst < /usr/local/etc/php/php-ini-directives.ini.template | sed "s~;\s*~\n~g"  > /usr/local/etc/php/conf.d/php-ini-directives.ini

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

if [[ "$1" =~ bin/console ]] && [[ "$2" = 'messenger:consume' ]]; then

    createAmqpVhost "${MESSENGER_TRANSPORT_DSN}"
    createAmqpVhost "${MESSENGER_TRANSPORT_IMPORT_DSN}"
    createAmqpVhost "${MESSENGER_TRANSPORT_CORE_DSN}"
    createAmqpVhost "${MESSENGER_TRANSPORT_EXPORT_DSN}"
    createAmqpVhost "${MESSENGER_TRANSPORT_DOMAIN_DSN}"
    createAmqpVhost "${MESSENGER_TRANSPORT_CHANNEL_DSN}"
    createAmqpVhost "${MESSENGER_TRANSPORT_SEGMENT_DSN}"

    bin/console messenger:setup-transports --no-interaction import
    bin/console messenger:setup-transports --no-interaction channel
    bin/console messenger:setup-transports --no-interaction export
    bin/console messenger:setup-transports --no-interaction core
    bin/console messenger:setup-transports --no-interaction event
    bin/console messenger:setup-transports --no-interaction segment
    bin/console messenger:setup-transports --no-interaction completeness

    >&2 echo "messenger initialization finished"
fi

if [ "$1" = 'php-fpm' ] ; then
    mkdir -p var/cache var/log public/multimedia import
    >&2 echo "Setting file permissions..."
    setfacl -R -m u:www-data:rwX -m u:"$(whoami)":rwX var
    setfacl -dR -m u:www-data:rwX -m u:"$(whoami)":rwX var
    setfacl -R -m u:www-data:rwX -m u:"$(whoami)":rwX public/multimedia
    setfacl -dR -m u:www-data:rwX -m u:"$(whoami)":rwX public/multimedia
    setfacl -R -m u:www-data:rwX -m u:"$(whoami)":rwX import
    setfacl -dR -m u:www-data:rwX -m u:"$(whoami)":rwX import



    if [ "$APP_ENV" != 'prod' ]; then
        composer install --prefer-dist --no-progress --no-suggest --no-interaction
    fi

    >&2 echo "Waiting for db to be ready..."
    waitUntil bin/console doctrine:query:sql "SELECT 1"

    if [ "$APP_ENV" != 'prod' ]; then
      bin/phing build
    fi

    bin/console ergonode:migrations:migrate --no-interaction --allow-no-migration

    if [ "$APP_ENV" != 'prod' ]; then
        enableXdebug
        echo -e "\e[30;48;5;82mergonode  api is available at http://localhost:${EXPOSED_NGINX_PORT} \e[0m"
    fi

    >&2 echo "app initialization finished"
fi



exec docker-php-entrypoint "$@"