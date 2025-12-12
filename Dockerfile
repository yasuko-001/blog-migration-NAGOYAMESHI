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

# 権限調整（重要）
RUN chown -R www-data:www-data /var/www/html \
 && chmod -R 755 /var/www/html/storage /var/www/html/bootstrap/cache

# Apache の DocumentRoot を public に変更
RUN sed -i 's|/var/www/html|/var/www/html/public|g' \
    /etc/apache2/sites-available/000-default.conf

EXPOSE 80
