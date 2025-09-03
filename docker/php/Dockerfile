
# App container com PHP 8.2 e Composer
FROM php:8.2-cli-bookworm

# Dependências de sistema e extensões PHP usadas pelo Laravel
RUN apt-get update && apt-get install -y \
    libzip-dev zip unzip git curl \
    libpng-dev libjpeg-dev libfreetype6-dev \
    libaio1 libnsl2 \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo_mysql zip gd

RUN apt-get clean && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

ENV ORACLE_IC_VERSION=21_13
RUN mkdir -p /opt/oracle && \
    curl -L -o /opt/oracle/instantclient-basiclite.zip \
      https://download.oracle.com/otn_software/linux/instantclient/2113000/instantclient-basiclite-linux.x64-21.13.0.0.0dbru.zip && \
    curl -L -o /opt/oracle/instantclient-sdk.zip \
      https://download.oracle.com/otn_software/linux/instantclient/2113000/instantclient-sdk-linux.x64-21.13.0.0.0dbru.zip && \
    unzip /opt/oracle/instantclient-basiclite.zip -d /opt/oracle && \
    unzip /opt/oracle/instantclient-sdk.zip -d /opt/oracle && \
    rm -f /opt/oracle/instantclient-*.zip && \
    ln -s /opt/oracle/instantclient_21_13 /opt/oracle/instantclient && \
    echo "/opt/oracle/instantclient" > /etc/ld.so.conf.d/oracle-instantclient.conf && ldconfig
# COPY docker/oracle/* /opt/oracle/
# RUN unzip /opt/oracle/instantclient-basic-linux.x64-12.2.0.1.0.zip -d /opt/oracle/ && \
#     unzip /opt/oracle/instantclient-sdk-linux.x64-12.2.0.1.0.zip -d /opt/oracle/ && \
#     rm -f /opt/oracle/instantclient-*.zip && \
#     ln -s /opt/oracle/instantclient_12_2 /opt/oracle/instantclient && \
#     echo "/opt/oracle/instantclient" > /etc/ld.so.conf.d/oracle-instantclient.conf && ldconfig

ENV LD_LIBRARY_PATH=/opt/oracle/instantclient

RUN printf "instantclient,/opt/oracle/instantclient\n" | pecl install oci8 \
    && docker-php-ext-enable oci8

WORKDIR /var/www/html

# Entrypoint
COPY docker/php/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 8000

ENTRYPOINT ["entrypoint.sh"]
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
