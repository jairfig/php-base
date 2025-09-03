
# App container com PHP 8.2 e Composer
FROM php:8.2-cli

# Dependências de sistema e extensões PHP usadas pelo Laravel
RUN apt-get update && apt-get install -y \
    libzip-dev \
    zip \
    unzip \
    git \
    curl \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo_mysql zip gd

RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Composer (do container oficial)
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

ENV LANG=pt_BR.UTF-8 \
    LC_ALL=pt_BR.UTF-8 \
    LANGUAGE=pt_BR:pt \
    TZ=America/Rio_Branco \
    APP_LOCALE=pt_BR \
    APP_FALLBACK_LOCALE=pt_BR \
    APP_FAKER_LOCALE=pt_BR

RUN echo "date.timezone=${TZ}" > /usr/local/etc/php/conf.d/zz-timezone.ini

WORKDIR /var/www/html

# Entrypoint
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 8000

ENTRYPOINT ["entrypoint.sh"]
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
