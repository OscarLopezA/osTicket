#!/bin/bash

# Configura permisos
chown -R www-data:www-data /var/www/html/osticket
find /var/www/html/osticket -type d -exec chmod 755 {} \;
find /var/www/html/osticket -type f -exec chmod 644 {} \;

# Prepara directorios para logs y sesiones
mkdir -p /var/log/php-fpm
mkdir -p /tmp/php-sessions
chown www-data:www-data /tmp/php-sessions

# Establecer español como idioma predeterminado en la configuración si no existe
if ! grep -q "es_ES" /var/www/html/osticket/include/ost-config.php; then
    sed -i "/define('DEFAULT_LANGUAGE',/c\define('DEFAULT_LANGUAGE', 'es_ES');" /var/www/html/osticket/include/ost-config.php
fi

# Inicia servicios
php-fpm --daemonize
nginx -g "daemon off;"
