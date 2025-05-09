# Usa una imagen base con PHP y Apache
FROM php:8.1-apache

# Instala dependencias del sistema y extensiones de PHP requeridas por osTicket
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libzip-dev \
    libicu-dev \
    unzip \
    && docker-php-ext-configure gd --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd mysqli pdo_mysql zip intl

# Habilita mod_rewrite de Apache
RUN a2enmod rewrite

# Descarga e instala osTicket
ENV OSTICKET_VERSION=1.18
RUN curl -SL https://github.com/osTicket/osTicket/releases/download/v${OSTICKET_VERSION}/osTicket-v${OSTICKET_VERSION}.zip -o /tmp/osTicket.zip \
    && unzip /tmp/osTicket.zip -d /var/www/html/ \
    && rm /tmp/osTicket.zip \
    && mv /var/www/html/upload /var/www/html/osticket \
    && chown -R www-data:www-data /var/www/html

# Copia el archivo de configuración (opcional, si tienes uno predefinido)
# COPY include/ost-config.php /var/www/html/osticket/include/ost-config.php

# Puerto expuesto
EXPOSE 80
