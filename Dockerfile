FROM php:8.2-apache

# PHP extensions
RUN apt-get update && apt-get install -y \
    zip unzip git vim \
    libpng-dev libjpeg-dev libfreetype6-dev \
 && docker-php-ext-configure gd --with-freetype --with-jpeg \
 && docker-php-ext-install pdo_mysql gd

# Apache mod_rewrite 有効化（Laravel必須）
RUN a2enmod rewrite

# Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# アプリ配置
WORKDIR /var/www/html
COPY . .

# Laravel 必須ディレクトリ作成＆権限
RUN mkdir -p storage bootstrap/cache \
 && chown -R www-data:www-data /var/www/html \
 && chmod -R 755 storage bootstrap/cache

# Apache DocumentRoot を public に変更
RUN sed -i 's|/var/www/html|/var/www/html/public|g' \
    /etc/apache2/sites-available/000-default.conf

EXPOSE 80
