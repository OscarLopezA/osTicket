#!/bin/bash

# Configura permisos
chown -R www-data:www-data /var/www/html/osticket
find /var/www/html/osticket -type d -exec chmod 755 {} \;
find /var/www/html/osticket -type f -exec chmod 644 {} \;

# Prepara directorios para logs y sesiones
mkdir -p /var/log/php-fpm
mkdir -p /tmp/php-sessions
chown www-data:www-data /tmp/php-sessions

# Inicia servicios
php-fpm --daemonize
nginx -g "daemon off;"
