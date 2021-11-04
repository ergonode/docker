# the different stages of this Dockerfile are meant to be built into separate images
# https://docs.docker.com/develop/develop-images/multistage-build/#stop-at-a-specific-build-stage
# https://docs.docker.com/compose/compose-file/#target
# https://docs.docker.com/compose/environment-variables/

# https://docs.docker.com/engine/reference/builder/#understand-how-arg-and-from-interact

FROM php:7.4-fpm-alpine as php

ENV COMPOSER_ALLOW_SUPERUSER 1
ENV COMPOSER_HOME /tmp
ENV COMPOSER_MEMORY_LIMIT -1
ARG NEWRELIC_URL=https://download.newrelic.com/php_agent/archive/9.14.0.290/newrelic-php5-9.14.0.290-linux-musl.tar.gz
ARG NEWRELIC_SHA256SUM=9842f06c0834e02b2bb31e6349893532384c836a6cddccb57e827b7670e487a8

COPY --from=composer /usr/bin/composer /usr/bin/composer

# required packages and PHP extensionns
RUN set -eux ; \
    # Non dev packages
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
        libcurl \
        gettext \
        gnu-libiconv \
        libpng \
        libjpeg \
        freetype \
        libwebp \
        imagemagick \
        libxpm \
        libzip  \
        busybox-suid ; \
    # dev packages
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
        curl-dev \
        libpng-dev \
        jpeg-dev \
        freetype-dev \
        libwebp-dev \
        libzip-dev \
        imagemagick-dev \
        libxpm-dev ; \
    docker-php-ext-configure gd   \
    --with-webp \
    --with-jpeg \
    --with-xpm \
    --with-freetype ; \
    docker-php-ext-install -j$(nproc) \
    pdo  \
    pdo_pgsql \
    intl \
    pcntl  \
    gd \
    exif  \
    zip  \
    opcache ; \
    pecl install amqp ; \
    pecl install xdebug; \
    pecl install imagick ; \
    docker-php-ext-enable amqp ; \
    docker-php-ext-enable xdebug ; \
    docker-php-ext-enable imagick ; \
    # newrelic
    mkdir -p /tmp/newrelic ; \
    cd /tmp/newrelic ; \
    curl -L "${NEWRELIC_URL}" -o newrelic.tar.gz ;  \
    sha256sum newrelic.tar.gz  | grep "${NEWRELIC_SHA256SUM}" ; \
    tar -xf newrelic.tar.gz ; \
    NR_INSTALL_USE_CP_NOT_LN=1  NR_INSTALL_SILENT=1 ./newrelic-php5-*/newrelic-install install ; \
    rm -rf /tmp/newrelic ; \
    php --version ; \
    rm -rf /tmp/* ; \
    update-ca-certificates
    # newrelic

ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so php

COPY ./config/php/docker-entrypoint.sh /usr/local/bin/docker-entrypoint
COPY ./config/php/php-fpm.d/zzz-01-healthcheck.conf /usr/local/etc/php-fpm.d/zzz-01-healthcheck.conf
COPY ./config/php/php-fpm-healthcheck.sh /usr/local/bin/php-fpm-healthcheck
COPY ./config/php/php-ini-directives.ini.template /usr/local/etc/php/php-ini-directives.ini.template

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
    backend/build.xml \
      ./

RUN set -eux; \
	composer install --prefer-dist --no-autoloader --no-scripts --no-progress --no-suggest; \
	mkdir -p config/jwt var/cache var/log import export public/multimedia public/thumbnail public/avatar; \
	composer clear-cache

COPY backend/bin bin/
COPY backend/config config/
COPY backend/module module/
COPY backend/public public/
COPY backend/src src/
COPY backend/templates templates/
COPY backend/translations translations/


#clean up
RUN set -eux; \
    chmod +x bin/console; \
	composer dump-autoload --optimize; \
	composer dump-env prod; \
	php -d memory_limit=-1 bin/console cache:clear --env=prod --no-debug ; \
	php -d memory_limit=-1 bin/console cache:clear --env=dev; \
	bin/console assets:install

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
     config/jwt/*.pem \
     tests \
     features

#copy app version if exists
COPY backend/.env backend/app.versio[n]  ./

FROM nginx:1.17-alpine AS nginx

RUN  set -eux; \
    apk add  --no-cache \
    curl \
    bash ; \
    rm -rf /tmp/*

COPY ./config/nginx/conf.d/http-directives.conf.template /etc/nginx/conf.d/http-directives.conf.template
COPY ./config/nginx/conf.d/symfony-development.conf.template /etc/nginx/conf.d/symfony-development.conf.template
COPY ./config/nginx/conf.d/symfony-production.conf.template /etc/nginx/conf.d/symfony-production.conf.template
COPY ./config/nginx/nginx.conf /etc/nginx/nginx.conf
COPY ./config/nginx/docker-entrypoint.sh /usr/local/bin/docker-entrypoint
COPY --from=php /srv/app/public /srv/app/public

RUN chmod +x /usr/local/bin/docker-entrypoint

HEALTHCHECK --start-period=5m CMD curl --fail http://localhost/healthcheck.json || exit 1

ENV NGINX_HTTP_DIRECTIVES="client_max_body_size 250m;"

ENTRYPOINT ["docker-entrypoint"]
CMD ["nginx", "-g", "daemon off;"]

FROM node:12.6-alpine as node

COPY config/node/docker-entrypoint.sh /usr/local/bin/docker-entrypoint
RUN  set -eux; \
    chmod +x /usr/local/bin/docker-entrypoint ; \
    apk add  --no-cache \
    curl \
    bash \
    git


ENTRYPOINT ["docker-entrypoint"]

FROM node as nuxtjs

WORKDIR /srv/app

HEALTHCHECK --start-period=5m CMD curl --fail http://localhost || exit 1

ENV HOST=0.0.0.0
ENV PORT=80

WORKDIR /srv/app

COPY frontend /srv/app/

RUN  set -eux; \
    npm install ; \
    npm run modules:all ; \
    NODE_ENV=production API_BASE_URL=http://localhost:8000/api/v1/ npm run build ; \
    #clean up
    npm cache clean -f ; \
    rm -f .env

CMD ["npm", "run", "dev"]

FROM nuxtjs as nuxtjs_production

WORKDIR /srv/app

#copy app version if exists
COPY frontend/.env.dist frontend/app.versio[n]  ./

CMD ["npm", "run", "start"]

FROM node as docsify

RUN  set -eux; \
    npm install docsify-cli -g ; \
    npm cache clean -f

HEALTHCHECK --start-period=5m CMD curl --fail http://localhost:3000 || exit 1

CMD ["docsify", "serve" ,"docs"]

FROM postgres:10-alpine as postgres

COPY ./config/postgres/docker-entrypoint-initdb.d /docker-entrypoint-initdb.d
COPY ./config/postgres/postgres-healthcheck.sh  /usr/local/bin/postgres-healthcheck.sh
COPY ./config/postgres/ergonode-common-functions.sh /usr/local/bin/ergonode-common-functions.sh

RUN chmod +x /usr/local/bin/postgres-healthcheck.sh

HEALTHCHECK --start-period=5m CMD bash -c /usr/local/bin/postgres-healthcheck.sh

FROM rabbitmq:3.8-management-alpine as rabbitmq-management

COPY config/rabbitmq/rabbitmq-healthcheck.sh  /usr/local/bin/rabbitmq-healthcheck.sh
COPY config/rabbitmq/rabbitmq.conf.template /etc/rabbitmq/rabbitmq.conf.template
COPY config/rabbitmq/docker-ergonode-entrypoint.sh /usr/local/bin/docker-ergonode-entrypoint

RUN  set -eux; \
    chmod +x /usr/local/bin/rabbitmq-healthcheck.sh ; \
    chmod +x /usr/local/bin/docker-ergonode-entrypoint ; \
    rabbitmq-plugins enable --offline rabbitmq_peer_discovery_consul  ; \
    apk add --no-cache gettext


HEALTHCHECK --start-period=2m CMD bash -c /usr/local/bin/rabbitmq-healthcheck.sh


ENTRYPOINT ["docker-ergonode-entrypoint"]
CMD ["rabbitmq-server"]

FROM haproxy:2.1-alpine as haproxy
RUN set -eux ; \
    apk add  --no-cache curl

COPY config/haproxy/haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg
