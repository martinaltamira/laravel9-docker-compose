# Partimos de la imagen php en su versión 7.4
FROM php:8.1-fpm

# Instalamos las dependencias necesarias
RUN apt-get update && apt-get install -y \
    build-essential \
    libzip-dev \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libonig-dev \
    locales \
    zip \
    jpegoptim optipng pngquant gifsicle \
    vim \
    git \
    curl

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Instalamos extensiones de PHP
RUN docker-php-ext-install pdo_mysql zip exif pcntl
RUN docker-php-ext-configure gd --with-freetype --with-jpeg
RUN docker-php-ext-install gd

# Instalamos composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer 

# Copiamos todos los archivos de la carpeta actual de nuestra 
# computadora (los archivos de laravel) a /var/www/
COPY ./api_modulos /var/www

# Copiamos los archivos package.json composer.json y composer-lock.json a /var/www/
WORKDIR /var/www

#COPY composer*.json /var/www

#--no-ansi --no-dev --no-interaction --no-progress --optimize-autoloader --no-scripts
RUN chmod -R 777 storage bootstrap/cache
RUN chown -R $USER:www-data storage
RUN chmod -R 775 storage

# Instalamos dependendencias de composer
#RUN composer update
RUN composer config -g -- disable-tls false
RUN composer config -g secure-http false

#RUN ssh-keyscan -t rsa my_server_name >> ~/.ssh/known_hosts 

#RUN composer update

# Set working directory
WORKDIR /var/www

# Exponemos el puerto 9000 a la network
EXPOSE 8001

# Corremos el comando php-fpm para ejecutar PHP
#CMD ["php-fpm"]
