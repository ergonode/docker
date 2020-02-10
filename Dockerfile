# the different stages of this Dockerfile are meant to be built into separate images
# https://docs.docker.com/develop/develop-images/multistage-build/#stop-at-a-specific-build-stage
# https://docs.docker.com/compose/compose-file/#target
# https://docs.docker.com/compose/environment-variables/

# https://docs.docker.com/engine/reference/builder/#understand-how-arg-and-from-interact

FROM postgres:10-alpine as postgres_development

COPY ./config/postgres/docker-entrypoint-initdb.d /docker-entrypoint-initdb.d
ADD ./config/postgres/postgres-healthcheck.sh  /usr/local/bin/postgres-healthcheck.sh
RUN chmod +x /usr/local/bin/postgres-healthcheck.sh

HEALTHCHECK --start-period=5s CMD bash -c /usr/local/bin/postgres-healthcheck.sh

FROM postgres_development as postgres_production

FROM php:7.4-fpm as php

# Basic tools
RUN apt-get -y update \
    && apt-get -y install git \
        curl \
        htop \
        nano \
        zip \
        unzip \
        librabbitmq-dev \
        libpq-dev \
        libicu-dev \
        graphviz \
        acl \
        libfcgi-bin \
    && apt-get clean \
    && pecl install amqp-1.9.4

ADD ./config/php/override.ini /usr/local/etc/php/conf.d/override.ini

# PHP extensionns
RUN docker-php-ext-install -j$(nproc) \
    pdo  \
    pdo_pgsql \
    intl \
    pcntl \
    && docker-php-ext-enable amqp \
    && docker-php-ext-enable opcache

# Composer
ENV COMPOSER_ALLOW_SUPERUSER=1
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
RUN composer --ansi --version --no-interaction

# install Symfony Flex globally to speed up download of Composer packages (parallelized prefetching)
RUN set -eux; \
	composer global require "symfony/flex" --prefer-dist --no-progress --no-suggest --classmap-authoritative; \
	composer clear-cache

COPY config/php/docker-entrypoint.sh /usr/local/bin/docker-entrypoint
RUN chmod +x /usr/local/bin/docker-entrypoint

#HEALTHCHECK
ADD ./config/php/php-fpm.d/zzz-01-healthcheck.conf /usr/local/etc/php-fpm.d/zzz-01-healthcheck.conf
ADD ./config/php/php-fpm-healthcheck.sh /usr/local/bin/php-fpm-healthcheck
RUN chmod 755 /usr/local/bin/php-fpm-healthcheck

HEALTHCHECK --interval=30s --timeout=5s --retries=5 CMD php-fpm-healthcheck


RUN rm -rf /tmp/*

ENTRYPOINT ["docker-entrypoint"]

CMD ["php-fpm"]

FROM php as php_development

RUN pecl install xdebug && docker-php-ext-enable xdebug
RUN echo "xdebug.remote_enable = 1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN echo "xdebug.remote_connect_back = 1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini


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
	composer clear-cache

COPY backend/bin bin/
COPY backend/config config/
COPY backend/module module/
COPY backend/public public/
COPY backend/src src/
COPY backend/templates templates/
COPY backend/translations translations/
COPY backend/tests/ tests/

RUN set -eux; \
	mkdir -p config/jwt var/cache var/log import public/multimedia; \
	composer dump-autoload --optimize; \
    composer run-script post-install-cmd; \
	chmod +x bin/console; sync

RUN bin/console cache:clear --env=prod --no-debug

FROM php_development as php_final_with_xdebug

FROM php_development as php_production

#clean up
# do not use .env /  test files in production
RUN rm -f .env* \
     *.dist \
     *.md \
     .travis.yml  \
     depfile.yml \
     config/jwt/*.pem

RUN pecl uninstall xdebug && rm -f /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

RUN echo '<?php return [];' > /srv/app/.env.local.php

FROM nginx:1.17 AS nginx

RUN apt-get update && apt-get install -y \
    curl

HEALTHCHECK --interval=30s --timeout=5s --retries=5 CMD curl --fail http://localhost/api/doc || exit 1

FROM nginx as nginx_development

ADD ./config/nginx/conf.d/symfony-development.conf.template /etc/nginx/conf.d/symfony-development.conf.template
ADD ./config/nginx/nginx.conf /etc/nginx/nginx.conf

ADD ./config/nginx/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT /usr/local/bin/docker-entrypoint.sh

FROM nginx_development as nginx_production

ADD ./config/nginx/conf.d/symfony-production.conf.template /etc/nginx/conf.d/symfony-production.conf.template

COPY --from=php_production /srv/app /srv/app

FROM node:12.6 as node

COPY config/node/docker-entrypoint.sh /usr/local/bin/docker-entrypoint
RUN chmod +x /usr/local/bin/docker-entrypoint

ENV HOST=0.0.0.0
ENV PORT=80
HEALTHCHECK --interval=30s --timeout=5s --retries=5 CMD curl --fail http://localhost || exit 1

ENTRYPOINT ["docker-entrypoint"]
CMD ["npm", "run", "dev"]

FROM node as node_development

WORKDIR /srv/app

COPY frontend /srv/app/
RUN npm install

FROM node_development as node_production
WORKDIR /srv/app
#clean up
# do not use .env /  test files in production
RUN rm -f .env*

CMD ["npm", "run", "start"]

FROM node as docs
RUN npm install docsify-cli -g

HEALTHCHECK --interval=30s --timeout=5s --retries=5 CMD curl --fail http://localhost:3000 || exit 1

CMD ["docsify", "serve" ,"docs"]

FROM docs as docs_final

