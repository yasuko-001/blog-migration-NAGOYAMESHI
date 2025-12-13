FROM public.ecr.aws/docker/library/php:8.2-fpm

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
    libxrender1

# ---------------------------------------------
# PHP extensions
# ---------------------------------------------
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
 && docker-php-ext-install gd bcmath pdo_mysql mysqli exif

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

# ★ Laravel 権限
RUN mkdir -p storage bootstrap/cache \
 && chown -R www-data:www-data storage bootstrap/cache \
 && chmod -R 775 storage bootstrap/cache

# ★ Composer はビルド時に実行
RUN composer install --no-dev --optimize-autoloader

# ---------------------------------------------
# Start application
# ---------------------------------------------
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=80"]
