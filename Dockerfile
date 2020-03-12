ARG PHP_VERSION=7.3
ARG PMA_VERSION=5.0.1

ARG PMA_CONFIG_PATH=/etc/phpmyadmin/
#
FROM moonbuggy2000/alpine-s6-nginx-php-fpm:php${PHP_VERSION}

# https://github.com/opencontainers/image-spec/blob/master/annotations.md
ARG BUILD_DATE
ARG VCS_REF
LABEL org.opencontainers.image.created=$BUILD_DATE \
      org.opencontainers.image.title="nginx-phpmyadmin-node" \
      org.opencontainers.image.description="A phpMyAdmin nginx and node.js in one container" \
      org.opencontainers.image.authors="Irwan Darmawan <ir1keren@gmail.com>" \
      org.opencontainers.image.revision=$VCS_REF \
      org.opencontainers.image.source="https://github.com/ir1keren/nginx-phpmyadmin-node" \
      org.opencontainers.image.url="https://github.com/ir1keren/nginx-phpmyadmin-node" \
      org.opencontainers.image.schema-version="1.0.0-rc.1" \
      org.opencontainers.image.license="Apache-2.0"

ARG PHP_VERSION
ARG PMA_VERSION
ARG PMA_CONFIG_PATH
ARG PMA_HOST
ARG PMA_PORT
ARG MYSQL_ROOT_PASSWORD

RUN apk --update add curl unzip mariadb mariadb-client
COPY init_db.sh /tmp/init_db.sh 
RUN chmod 0755 /tmp/init_db.sh
COPY ./etc/my.cnf /tmp/my.cnf

RUN rm -rf /etc/my.cnf.d/* /usr/data/test/db.opt /usr/share/mariadb/README* /usr/share/mariadb/COPYING* /usr/share/mariadb/*.cnf /usr/share/terminfo \
    && sed -i -e 's/127.0.0.1/%/' /usr/share/mariadb/mysql_system_tables_data.sql && mkdir /run/mysqld \
    && chown mysql:mysql /etc/my.cnf.d/ /run/mysqld /usr/share/mariadb/mysql_system_tables_data.sql

RUN mv /tmp/my.cnf /etc/my.cnf.d/
RUN /tmp/init_db.sh

#USER root
COPY ./etc/services.d/mysqld/ /etc/services.d/mysqld/
RUN chmod 0755 /etc/services.d/mysqld && chmod 0755 /etc/services.d/mysqld/run

WORKDIR /build

RUN curl -o phpMyAdmin.tar.xz -L https://files.phpmyadmin.net/phpMyAdmin/${PMA_VERSION}/phpMyAdmin-${PMA_VERSION}-all-languages.tar.xz
RUN tar -xf phpMyAdmin.tar.xz --strip 1 \
    && rm -f phpMyAdmin.tar.xz \
    && rm -rf \
		composer.json \
		examples/ \
		po/ \
		RELEASE-DATE-${PMA_VERSION} \
		setup/ \
		test/
	# use /etc/phpmyadmin for config files so we can mount a volume easily.
RUN sed -e "s|(CONFIG_DIR',\s*)(.*)\)|\1'${PMA_CONFIG_PATH}')|" -E -i libraries/vendor_config.php \
    && chown -R 1000:1000 /build
WORKDIR /
RUN cp -R /build/* ${WEB_ROOT} && cd / && rm -rf /build

COPY ./etc/phpmyadmin/ /etc/phpmyadmin/
COPY ./etc/cont-init.d/* /etc/cont-init.d/

RUN apk add \
		libzip \
        imagemagick \
		php7-bz2 \
		php7-ctype \
		php7-curl \
		php7-dom \
		php7-gd \
        php7-imagick \
		php7-intl \
		php7-json \
		php7-mbstring \
		php7-mysqli \
		php7-openssl \
		php7-phar \
		php7-session \
		php7-xml \
		php7-xmlreader \
		php7-zip \
		php7-zlib \
        php7-phalcon \
		mariadb-client \
        nodejs \
        npm \
		git \
		nano

RUN add-contenv \
		PMA_VERSION=${PMA_VERSION} \
		PMA_CONFIG_PATH=${PMA_CONFIG_PATH} \
    && sed -i "s/BLOWFISH_SECRET/$(tr -dc 'a-zA-Z0-9~!@#%^&*_()+}{?><;.,[]=-' < /dev/urandom | fold -w 32 | head -n 1)/" /etc/phpmyadmin/config.secret.inc.php \
	&& touch /etc/phpmyadmin/config.user.inc.php \
    && echo -e "<?php\nfor(\$i=1;isset(\$cfg['Servers'][\$i]);\$i++)\n{    \$cfg['Servers'][\$i]['auth_type']='cookie';\n    \$cfg['Servers'][\$i]['AllowNoPassword']=false;\n}\n" >> /etc/phpmyadmin/config.user.inc.php \
	&& mkdir -p /var/nginx/client_body_temp \
	&& mkdir /sessions

ENTRYPOINT ["/init"]

EXPOSE 3306
EXPOSE 8080
EXPOSE 83