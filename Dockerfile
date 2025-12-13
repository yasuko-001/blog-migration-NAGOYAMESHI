FROM php:8.2-fpm

WORKDIR /app

# OS packages
RUN apt-get update \
 && apt-get install -y \
    git zip unzip vim \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libfontconfig1 \
    libxrender1 \
 && rm -rf /var/lib/apt/lists/*

# PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
 && docker-php-ext-install gd bcmath pdo_mysql mysqli exif

# Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Application source
COPY . .

# Laravel dependencies（★ここでやる）
RUN composer install --no-dev --optimize-autoloader

# Permission
RUN mkdir -p storage bootstrap/cache \
 && chown -R www-data:www-data storage bootstrap/cache \
 && chmod -R 775 storage bootstrap/cache

# Expose port
EXPOSE 80

# Start php-fpm（ECS向け）
CMD ["php-fpm"]
