#FROM php:7.3.8-cli
FROM php:7.2.21-cli

WORKDIR "."

# Basic tools
RUN apt-get -y update \
    && apt-get -y install git curl htop nano zip unzip librabbitmq-dev libpq-dev \
    && pecl install amqp-1.9.4

# PHP extensionns
RUN docker-php-ext-install -j$(nproc) pdo pdo_pgsql \
    && docker-php-ext-enable amqp \
    && docker-php-ext-enable opcache

# Composer
ENV COMPOSER_ALLOW_SUPERUSER=1
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
