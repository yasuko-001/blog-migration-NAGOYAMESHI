FROM php:8.2-fpm

WORKDIR /app

# ---------------------------------------------
# OS packages
# ---------------------------------------------
RUN apt-get update \
    && apt-get install -y \
    git \
    zip \
    unzip \
    vim \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libpng-dev \
    libfontconfig1 \
    libxrender1

# ---------------------------------------------
# PHP extensions
# ---------------------------------------------
RUN docker-php-ext-configure gd --with-freetype --with-jpeg
RUN docker-php-ext-install gd
RUN docker-php-ext-install bcmath
RUN docker-php-ext-install pdo_mysql mysqli exif

# ---------------------------------------------
# Composer
# ---------------------------------------------
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
ENV COMPOSER_ALLOW_SUPERUSER=1
ENV COMPOSER_HOME=/composer

# ---------------------------------------------
# Application source
# ---------------------------------------------
COPY . .

# ★★★ ここがコーチ助言の追記ポイント ★★★
RUN chown -R www-data:www-data storage bootstrap/cache \
 && chmod -R 775 storage bootstrap/cache

# ---------------------------------------------
# Start application
# ---------------------------------------------
CMD cd /app \
 && composer config allow-plugins.composer/installers true \
 && composer update \
 && php ./artisan serve --host 0.0.0.0 --port=80
