# Usa una imagen base con PHP-FPM
FROM php:8.1-fpm

# Instala dependencias del sistema (sin MySQL/mariadb)
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libwebp-dev \
    libzip-dev \
    libicu-dev \
    libxml2-dev \
    libc-client-dev \
    libkrb5-dev \
    libxslt-dev \
    libonig-dev \
    unzip \
    nginx \
    && rm -rf /var/lib/apt/lists/*

# Instala extensiones PHP en pasos separados para mejor control
RUN docker-php-ext-configure gd --with-jpeg --with-webp \
    && docker-php-ext-install -j$(nproc) gd

RUN docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && apt-get install -y krb5-multidev \
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

# Configura Nginx (sin configuración de MySQL)
COPY nginx.conf /etc/nginx/nginx.conf
COPY php-fpm.conf /usr/local/etc/php-fpm.d/www.conf

# Descarga osTicket
ENV OSTICKET_VERSION=1.18
RUN curl -SL https://github.com/osTicket/osTicket/releases/download/v${OSTICKET_VERSION}/osTicket-v${OSTICKET_VERSION}.zip -o /tmp/osTicket.zip \
    && unzip /tmp/osTicket.zip -d /var/www/html/ \
    && rm /tmp/osTicket.zip \
    && mv /var/www/html/upload /var/www/html/osticket

# Configura permisos
RUN chown -R www-data:www-data /var/www/html/osticket \
    && chmod -R 755 /var/www/html/osticket

EXPOSE 8088

CMD service nginx start && php-fpm
