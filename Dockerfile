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
    libpng-dev \
    libfontconfig1 \
    libxrender1 \
    curl \
    && rm -rf /var/lib/apt/lists/*

# ---------------------------------------------
# PHP extensions
# ---------------------------------------------
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
 && docker-php-ext-install gd bcmath pdo_mysql mysqli exif

# ---------------------------------------------
# Composer（公式インストーラ方式）
# 👉 Docker Hub を使わない！
# ---------------------------------------------
RUN curl -sS https://getcomposer.org/installer | php -- \
    --install-dir=/usr/local/bin \
    --filename=composer

ENV COMPOSER_ALLOW_SUPERUSER=1
ENV COMPOSER_HOME=/composer

# ---------------------------------------------
# Application source
# ---------------------------------------------
COPY . .

# Laravel 権限
RUN mkdir -p storage bootstrap/cache \
 && chown -R www-data:www-data storage bootstrap/cache \
 && chmod -R 775 storage bootstrap/cache

# ---------------------------------------------
# Start application
# ---------------------------------------------
CMD cd /app \
 && composer install --no-dev --optimize-autoloader \
 && php artisan serve --host 0.0.0.0 --port=80
