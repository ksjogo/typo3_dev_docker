FROM php:7.0-apache
ENV HOME /root

RUN echo -n "" >> /etc/apt/sources.list
RUN echo '\ndeb http://http.us.debian.org/debian/ testing non-free contrib main' >> /etc/apt/sources.list
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl https://packages.microsoft.com/config/ubuntu/16.04/prod.list | sed -e 's/https/http/' > /etc/apt/sources.list.d/mssql-release.list

RUN apt-get update -qq
RUN apt-get install -qq -y -qq git netcat curl wget bash zlib1g-dev sudo docker mariadb-client-10.0 imagemagick sassc nano npm php7.0-pgsql apt-utils
RUN apt-get upgrade -qq -y

RUN npm install -g bower \
&& ln -s /usr/bin/nodejs /usr/bin/node

RUN docker-php-ext-install -j$(nproc) zip pdo pdo_mysql mysqli

RUN ACCEPT_EULA=Y DEBIAN_FRONTEND=noninteractive apt-get install --fix-missing -y --yes php-dev msodbcsql php7.0-dev libssl-dev unixodbc-dev
RUN sudo pecl install sqlsrv-4.1.6.1 pdo_sqlsrv-4.1.6.1
RUN echo "date.timezone = Europe/Berlin"  >> /usr/local/etc/php/php.ini
RUN echo "extension=/usr/lib/php/20151012/pgsql.so"  >> /usr/local/etc/php/php.ini
RUN echo "extension=/usr/lib/php/20151012/pdo_pgsql.so"  >> /usr/local/etc/php/php.ini
RUN echo "extension=sqlsrv.so"  >> /usr/local/etc/php/php.ini
RUN echo "extension=pdo_sqlsrv.so"  >> /usr/local/etc/php/php.ini

# Install composer
RUN bash -c "php -r \"copy('https://getcomposer.org/installer', 'composer-setup.php');\""
RUN bash -c "php composer-setup.php --filename=composer --install-dir=/usr/local/bin"
RUN bash -c "php -r \"unlink('composer-setup.php');\""

#xdebug
RUN pecl install xdebug \
&& docker-php-ext-enable xdebug \
&& echo "xdebug.remote_enable=on" >> /usr/local/etc/php/conf.d/xdebug.ini \
&& echo "xdebug.remote_autostart=on" >> /usr/local/etc/php/conf.d/xdebug.ini

# App
ADD ./composer.json composer.json
ADD ./composer.lock composer.lock
RUN composer install
RUN chmod +x vendor/helhum/typo3-console/Scripts/typo3cms

ADD ./000-default.conf /etc/apache2/sites-enabled/000-default.conf
EXPOSE 80
RUN a2enmod rewrite

ADD ./AdditionalConfiguration.php typo3conf/AdditionalConfiguration.php
ADD ./run.sh /run.sh
CMD /run.sh
RUN ln -s typo3_src/components components
RUN sed -ie 's|extension=/usr/lib/php/20151012/pgsql.so||' /usr/local/etc/php/php.ini
