# Docker nginx-phpmyadmin-node
This image is derived from [alpine-s6-nginx-php-fpm](https://github.com/moonbuggy/docker-base-images/tree/master/alpine-s6-nginx-php-fpm) and [jbergstroem/mariadb-alpine](https://github.com/jbergstroem/mariadb-alpine) project.

## What's Inside in This Image
1. nano text editor
2. nginx Web Server
3. PHP 7-FPM with modules: `php7-bz2`, `php7-ctype`, `php7-curl`, `php7-dom`, `php7-gd`, `php7-imagick`, `php7-intl`, `php7-json`, `php7-mbstring`, `php7-mysqli`, `php7-openssl`, `php7-phar`, `php7-session`, `php7-xml`, `php7-xmlreader`, `php7-zip`, `php7-zlib`, `php7-phalcon`
4. MariaDB
5. phpMyAdmin (installed on document root: /var/www/html)
6. node.js with npm

## Environment Variables
There are several environment variables you can use:
- MYSQL_ROOT_PASSWORD = define your own root password for MariaDB/MySQL
- MYSQL_DATABASE =  create your own database
- MYSQL_USER = user for your own database
- MYSQL_PASSWORD = user password for your own database

Or you can read on [jbergstroem/mariadb-alpine](https://github.com/jbergstroem/mariadb-alpine) github page.

## License

[APL-2](./LICENSE).