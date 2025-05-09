# Usa una imagen base con PHP-FPM
FROM php:8.1-fpm

# Instala dependencias del sistema y extensiones de PHP requeridas por osTicket
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libzip-dev \
    libicu-dev \
    libc-client-dev \
    libkrb5-dev \
    unzip \
    nginx \
    && docker-php-ext-configure gd --with-jpeg \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install -j$(nproc) gd mysqli pdo_mysql zip intl opcache imap \
    && pecl install apcu \
    && docker-php-ext-enable apcu \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Configura Nginx y PHP-FPM
COPY nginx.conf /etc/nginx/nginx.conf
COPY php-fpm.conf /usr/local/etc/php-fpm.d/www.conf

# Descarga e instala osTicket
ENV OSTICKET_VERSION=1.18.2
RUN curl -SL https://github.com/osTicket/osTicket/releases/download/v${OSTICKET_VERSION}/osTicket-v${OSTICKET_VERSION}.zip -o /tmp/osTicket.zip \
    && unzip /tmp/osTicket.zip -d /var/www/html/ \
    && rm /tmp/osTicket.zip \
    && mv /var/www/html/upload /var/www/html/osticket \
    # Crea el archivo de configuración desde el archivo de muestra
    && cp /var/www/html/osticket/include/ost-sampleconfig.php /var/www/html/osticket/include/ost-config.php

# Descarga e instala los paquetes de idioma español
RUN curl -SL https://github.com/osTicket/osTicket-translations/archive/master.zip -o /tmp/translations.zip \
    && unzip /tmp/translations.zip -d /tmp \
    && mkdir -p /var/www/html/osticket/include/i18n \
    && cp -r /tmp/osTicket-translations-master/es_ES /var/www/html/osticket/include/i18n/ \
    && rm -rf /tmp/translations.zip /tmp/osTicket-translations-master

# Configura permisos
RUN chown -R www-data:www-data /var/www/html/osticket \
    && chmod -R 755 /var/www/html/osticket \
    # Asegura permisos correctos para el archivo de configuración
    && chmod 0666 /var/www/html/osticket/include/ost-config.php

# Puerto expuesto
EXPOSE 8088

# Script de inicio personalizado
COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]
