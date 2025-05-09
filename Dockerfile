FROM php:8.0-apache

# Copiar los archivos del proyecto al contenedor
COPY src/ /var/www/html/

# Configurar permisos
RUN chown -R www-data:www-data /var/www/html

# Exponer el puerto 80
EXPOSE 80

# Habilitar el módulo de reescritura de Apache
RUN a2enmod rewrite

# Configurar el documento raíz
ENV APACHE_DOCUMENT_ROOT /var/www/html

# Reemplazar la configuración de DocumentRoot
RUN sed -ri -e 's!^DocumentRoot.*!DocumentRoot ${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/000-default.conf

# Reiniciar Apache
CMD ["apache2-foreground"]
