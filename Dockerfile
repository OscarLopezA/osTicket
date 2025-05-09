# Usa una imagen base con PHP-FPM
FROM php:8.1-fpm

# Instala dependencias del sistema primero
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libzip-dev \
    libicu-dev \
    libxml2-dev \
    libc-client-dev \
    libkrb5-dev \
    libxslt-dev \
    libonig-dev \
    libwebp-dev \
    unzip \
    nginx \
    && rm -rf /var/lib/apt/lists/*

# Configura las extensiones PHP en pasos separados para mejor manejo de errores
RUN docker-php-ext-configure gd --with-jpeg --with-webp \
    && docker-php-ext-install -j$(nproc) gd

RUN docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install -j$(nproc) imap

RUN docker-php-ext-install -j$(nproc) \
    mysqli \
    pdo_mysql \
    zip \
    intl \
    opcache \
    iconv \
    ctype \
    xml \
    dom \
    json \
    mbstring \
    phar \
    xsl

RUN pecl install apcu \
    && docker-php-ext-enable apcu

# Configura Nginx y PHP-FPM
COPY nginx.conf /etc/nginx/nginx.conf
COPY php-fpm.conf /usr/local/etc/php-fpm.d/www.conf

# Optimizaciones para PHP
COPY php.ini /usr/local/etc/php/conf.d/osticket.ini

# Descarga e instala osTicket
ENV OSTICKET_VERSION=1.18
RUN curl -SL https://github.com/osTicket/osTicket/releases/download/v${OSTICKET_VERSION}/osTicket-v${OSTICKET_VERSION}.zip -o /tmp/osTicket.zip \
    && unzip /tmp/osTicket.zip -d /var/www/html/ \
    && rm /tmp/osTicket.zip \
    && mv /var/www/html/upload /var/www/html/osticket

# Configura permisos
RUN chown -R www-data:www-data /var/www/html/osticket \
    && chmod -R 755 /var/www/html/osticket

# Puerto expuesto
EXPOSE 8088

# Script de inicio personalizado
COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]
