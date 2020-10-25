FROM php:7.4-fpm

# composer settings
ENV COMPOSER_ALLOW_SUPERUSER 1
ENV COMPOSER_HOME /tmp
ENV COMPOSER_MEMORY_LIMIT -1

# required packages and PHP extensionns
RUN apt-get update \
    && apt-get install -y \
        git  \
        nano \
        zip \
        unzip \
        curl \
        graphviz \
        acl \
        imagemagick \
        make \
        libwebp-dev \
        libzip-dev \
        libxpm-dev \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libpq-dev \
        libicu-dev \
        librabbitmq-dev \
        libmagickwand-dev \
    && docker-php-ext-configure gd --with-webp --with-jpeg --with-xpm --with-freetype \
    && docker-php-ext-install -j$(nproc) pdo pdo_pgsql intl pcntl gd exif zip opcache \
    && pecl install amqp \
    && pecl install xdebug \
    && pecl install imagick \
    && docker-php-ext-enable amqp \
    && docker-php-ext-enable xdebug \
    && docker-php-ext-enable imagick

# install CRON
RUN apt-get install -y cron

# install Supervisor
RUN apt-get install -y supervisor python-pip \
    && pip install supervisor-stdout

# copy PHP settings
RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"

# install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

CMD ["php-fpm"]
