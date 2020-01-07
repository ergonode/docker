# the different stages of this Dockerfile are meant to be built into separate images
# https://docs.docker.com/develop/develop-images/multistage-build/#stop-at-a-specific-build-stage
# https://docs.docker.com/compose/compose-file/#target
# https://docs.docker.com/compose/environment-variables/

# https://docs.docker.com/engine/reference/builder/#understand-how-arg-and-from-interact

FROM php:7.2-fpm as php

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

FROM php as php_final

FROM php_final as php_final_with_xdebug

RUN pecl install xdebug && docker-php-ext-enable xdebug
RUN echo "xdebug.remote_enable = 1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN echo "xdebug.remote_connect_back = 1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini


FROM nginx:1.17 AS nginx

RUN apt-get update && apt-get install -y \
    curl

HEALTHCHECK --interval=30s --timeout=5s --retries=5 CMD curl --fail http://localhost/api/doc || exit 1

FROM nginx as nginx_final

FROM node:12.6 as node

COPY config/node/docker-entrypoint.sh /usr/local/bin/docker-entrypoint
RUN chmod +x /usr/local/bin/docker-entrypoint

ENV HOST=0.0.0.0
ENV PORT=80
HEALTHCHECK --interval=30s --timeout=5s --retries=5 CMD curl --fail http://localhost || exit 1

ENTRYPOINT ["docker-entrypoint"]
CMD ["npm", "run", "dev"]

FROM node as node_final

FROM node as docs
RUN npm install docsify-cli -g

HEALTHCHECK --interval=30s --timeout=5s --retries=5 CMD curl --fail http://localhost:3000 || exit 1

CMD ["docsify", "serve" ,"docs"]

FROM docs as docs_final

