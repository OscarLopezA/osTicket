# Usa una imagen base con PHP-FPM
FROM php:8.1-fpm

# Instala dependencias del sistema y extensiones de PHP requeridas por osTicket
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libzip-dev \
    libicu-dev \
    unzip \
    nginx \
    && docker-php-ext-configure gd --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd mysqli pdo_mysql zip intl opcache \
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
