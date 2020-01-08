#!/bin/bash

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
fi

if [ "$1" = 'php-fpm' ] ; then
    mkdir -p var/cache var/log public/multimedia
    >&2 echo "Setting file permissions..."
    setfacl -R -m u:www-data:rwX -m u:"$(whoami)":rwX var  >/dev/null 2>&1
    setfacl -dR -m u:www-data:rwX -m u:"$(whoami)":rwX var >/dev/null 2>&1
    setfacl -R -m u:www-data:rwX -m u:"$(whoami)":rwX public/multimedia  >/dev/null 2>&1
    setfacl -dR -m u:www-data:rwX -m u:"$(whoami)":rwX public/multimedia >/dev/null 2>&1




    if [ -f "/usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini" ] ; then
        mv /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini /usr/local/etc/docker-php-ext-xdebug.ini
    fi

    if [ "$APP_ENV" != 'prod' ]; then
        composer install --prefer-dist --no-progress --no-suggest --no-interaction
    fi

    bin/console ergonode:jwt:generate-keys
    bin/console ergonode:jwt:fix-permissions --private-key-group www-data

     >&2 echo "Waiting for db to be ready..."
    until bin/console doctrine:query:sql "SELECT 1" > /dev/null 2>&1; do
      sleep 1
	  done

    bin/phing build


    if [ "$APP_ENV" != 'prod' ]; then
        echo -e "\e[30;48;5;82mergonode  api is available at http://localhost:${EXPOSED_NGINX_PORT} \e[0m"
    fi
fi

if [ -f "/usr/local/etc/docker-php-ext-xdebug.ini" ] ; then
    mv /usr/local/etc/docker-php-ext-xdebug.ini /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
fi

exec docker-php-entrypoint "$@"