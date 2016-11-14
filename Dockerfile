FROM php:7.0-apache
ENV HOME /root
RUN echo -n "" >> /etc/apt/sources.list
RUN echo '\ndeb http://http.us.debian.org/debian/ testing non-free contrib main' >> /etc/apt/sources.list
RUN apt-get update -qq
RUN apt-get install -qq -y -qq git netcat curl wget bash zlib1g-dev sudo docker mariadb-client-10.0 imagemagick sassc nano npm
RUN apt-get upgrade -qq -y

RUN npm install -g bower \
&& ln -s /usr/bin/nodejs /usr/bin/node

RUN docker-php-ext-install -j$(nproc) zip pdo pdo_mysql mysqli
RUN echo "date.timezone = Europe/Berlin" >> /usr/local/etc/php/php.ini

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
