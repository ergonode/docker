# the different stages of this Dockerfile are meant to be built into separate images
# https://docs.docker.com/develop/develop-images/multistage-build/#stop-at-a-specific-build-stage
# https://docs.docker.com/compose/compose-file/#target
# https://docs.docker.com/compose/environment-variables/

# https://docs.docker.com/engine/reference/builder/#understand-how-arg-and-from-interact

FROM php:7.4-fpm-alpine as php

ENV COMPOSER_ALLOW_SUPERUSER=1
COPY --from=composer /usr/bin/composer /usr/bin/composer

# required packages and PHP extensionns
RUN set -eux ; \
    apk add  --no-cache git  \
        zip \
        unzip \
        curl \
        rabbitmq-c \
        libpq \
        icu-libs \
        graphviz \
        acl \
        fcgi  \
        bash \
        libcurl ; \
    apk add --no-cache --virtual .fetch-deps \
        icu-dev \
        postgresql-dev \
        rabbitmq-c-dev \
        autoconf \
        musl-dev \
        gcc \
        g++ \
        make \
        pkgconf \
        file \
        curl-dev; \
    docker-php-ext-install -j$(nproc) \
    pdo  \
    pdo_pgsql \
    intl \
    pcntl  \
    curl ; \
    pecl install amqp ; \
    pecl install xdebug; \
    docker-php-ext-enable amqp ; \
    docker-php-ext-enable opcache ; \
    docker-php-ext-enable xdebug ; \
    docker-php-ext-enable curl ; \
    echo "xdebug.remote_enable = 1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini; \
    echo "xdebug.remote_connect_back = 1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

COPY ./config/php/docker-entrypoint.sh /usr/local/bin/docker-entrypoint
COPY ./config/php/php-fpm.d/zzz-01-healthcheck.conf /usr/local/etc/php-fpm.d/zzz-01-healthcheck.conf
COPY ./config/php/php-fpm-healthcheck.sh /usr/local/bin/php-fpm-healthcheck
COPY ./config/php/override.ini /usr/local/etc/php/conf.d/override.ini

# install Symfony Flex globally to speed up download of Composer packages (parallelized prefetching) \
RUN set -eux ; \
    chmod +x /usr/local/bin/docker-entrypoint; \
    chmod 755 /usr/local/bin/php-fpm-healthcheck ; \
    composer --ansi --version --no-interaction; \
    composer global require "symfony/flex" --prefer-dist --no-progress --no-suggest --classmap-authoritative; \
	composer clear-cache;

HEALTHCHECK --start-period=5m  CMD php-fpm-healthcheck
ENTRYPOINT ["docker-entrypoint"]
CMD ["php-fpm"]

WORKDIR /srv/app

COPY  backend/composer.json \
    backend/composer.lock \
    backend/symfony.lock \
    backend/.env \
    backend/.env.test \
    backend/phpunit.xml.dist \
    backend/phpstan.neon.dist \
    backend/phpcs.xml.dist \
    backend/behat.yml.dist \
    backend/depfile.yml \
    backend/.travis.yml \
    backend/build.xml \
      ./

RUN set -eux; \
	composer install --prefer-dist --no-autoloader --no-scripts --no-progress --no-suggest; \
	mkdir -p config/jwt var/cache var/log import public/multimedia; \
	composer clear-cache

COPY backend/bin bin/
COPY backend/config config/
COPY backend/module module/
COPY backend/public public/
COPY backend/src src/
COPY backend/templates templates/
COPY backend/translations translations/
#copy app version if exists
COPY backend/.env backend/app.versio[n]  ./

#clean up
RUN set -eux; \
    chmod +x bin/console; \
	composer dump-autoload --optimize; \
	composer dump-env prod; \
    composer run-script post-install-cmd; \
	bin/console cache:clear --env=prod --no-debug ; \
	bin/console cache:clear --env=dev

FROM php as php_production
	# do not use .env  in production
RUN set -eux; \
    pecl uninstall xdebug ; \
    rm -f /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini; \
    # remove unnecessary dev packages
    apk del --no-network .fetch-deps ; \
    php --version ; \
	rm -f .env \
     .env.test \
     *.dist \
     *.md \
     .travis.yml  \
     depfile.yml \
     config/jwt/*.pem \
     tests \
     features

FROM nginx:1.17-alpine AS nginx

RUN  set -eux; \
    apk add  --no-cache \
    curl \
    bash \
    iputils; \
    rm -rf /tmp/*

COPY ./config/nginx/conf.d/symfony-development.conf.template /etc/nginx/conf.d/symfony-development.conf.template
COPY ./config/nginx/conf.d/symfony-production.conf.template /etc/nginx/conf.d/symfony-production.conf.template
COPY ./config/nginx/nginx.conf /etc/nginx/nginx.conf
COPY ./config/nginx/docker-entrypoint.sh /usr/local/bin/docker-entrypoint
COPY --from=php /srv/app/public /srv/app/public

RUN chmod +x /usr/local/bin/docker-entrypoint

HEALTHCHECK --start-period=5m CMD curl --fail http://localhost/api/doc || exit 1

ENTRYPOINT ["docker-entrypoint"]
CMD ["nginx", "-g", "daemon off;"]

FROM node:12.6-alpine as node

COPY config/node/docker-entrypoint.sh /usr/local/bin/docker-entrypoint
RUN  set -eux; \
    chmod +x /usr/local/bin/docker-entrypoint ; \
    apk add  --no-cache \
    curl \
    bash


ENTRYPOINT ["docker-entrypoint"]

FROM node as nuxtjs

WORKDIR /srv/app

HEALTHCHECK --start-period=5m CMD curl --fail http://localhost || exit 1

ENV HOST=0.0.0.0
ENV PORT=80

WORKDIR /srv/app

COPY frontend /srv/app/
#copy app version if exists
COPY frontend/.env.dist frontend/app.versio[n]  ./

RUN  set -eux; \
    npm install ; \
    npm run build ; \
    #clean up
    rm -f .env

CMD ["npm", "run", "dev"]

FROM nuxtjs as nuxtjs_production

WORKDIR /srv/app

CMD ["npm", "run", "start"]

FROM node as docsify

RUN npm install docsify-cli -g

HEALTHCHECK --start-period=5m CMD curl --fail http://localhost:3000 || exit 1

CMD ["docsify", "serve" ,"docs"]

FROM postgres:10-alpine as postgres

COPY ./config/postgres/docker-entrypoint-initdb.d /docker-entrypoint-initdb.d
COPY ./config/postgres/postgres-healthcheck.sh  /usr/local/bin/postgres-healthcheck.sh
COPY ./config/postgres/ergonode-common-functions.sh /usr/local/bin/ergonode-common-functions.sh

RUN chmod +x /usr/local/bin/postgres-healthcheck.sh

HEALTHCHECK --start-period=5m CMD bash -c /usr/local/bin/postgres-healthcheck.sh