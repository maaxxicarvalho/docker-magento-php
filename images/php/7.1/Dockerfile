FROM php:7.1-fpm

LABEL maintainer="Max Carvalho <max.carvalho@cloverbox.com.br>"

# Global
RUN apt-get update -qq && apt-get install -y --no-install-recommends gosu curl git pv mysql-client wget unzip zip \
    openssh-server unzip vim rsync

# PHP
ENV DEV_LIBS libfreetype6-dev libjpeg62-turbo-dev libpng-dev libgd-dev libmagickwand-dev libc-client-dev libkrb5-dev \
    libicu-dev libldap2-dev libmcrypt-dev openssl unixodbc-dev libxml2-dev freetds-dev libssl-dev libpspell-dev libtidy-dev \
    libxslt-dev libmemcached-dev
RUN apt-get install -y --no-install-recommends $DEV_LIBS \
    && pecl install igbinary && pecl install imagick && pecl install redis && pecl install memcached \
    && pecl install xdebug && pecl install lzf \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-configure intl \
    && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ \
    && docker-php-ext-configure pdo_dblib --with-libdir=/lib/x86_64-linux-gnu \
    && docker-php-ext-install -j$(nproc) bcmath calendar exif gd gettext imap intl ldap mcrypt mysqli pcntl pdo_dblib \
        pdo_mysql pspell shmop soap sockets sysvmsg sysvsem sysvshm tidy wddx xmlrpc xsl zip opcache \
    && git clone --recursive --depth=1 https://github.com/kjdev/php-ext-snappy.git && cd php-ext-snappy \
    && phpize && ./configure && make && make install \
    && docker-php-ext-enable igbinary imagick redis snappy memcached \
    && echo "extension=lzf.so" > /usr/local/etc/php/conf.d/ext-lzfs.ini \
    && rm -rf php-ext-snappy \
    && curl -O https://files.magerun.net/n98-magerun.phar && mv n98-magerun.phar /usr/bin/magerun && chmod +x /usr/bin/magerun \
    && curl -O https://files.magerun.net/n98-magerun2.phar && mv n98-magerun2.phar /usr/bin/magerun2 && chmod +x /usr/bin/magerun2 \
    && mkdir -p /usr/local/var/log && touch /usr/local/var/log/php-fpm.log && chmod 777 /usr/local/var/log/php-fpm.log

# Composer
ENV COMPOSER_ALLOW_SUPERUSER 1
ENV COMPOSER_HOME /tmp
ENV COMPOSER_VERSION 1.7.2

RUN export EXPECTED_SIGNATURE="$(wget -q -O - https://composer.github.io/installer.sig)"; \
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"; \
    export ACTUAL_SIGNATURE="$(php -r "echo hash_file('SHA384', 'composer-setup.php');")"; \
    if [ "$EXPECTED_SIGNATURE" != "$ACTUAL_SIGNATURE" ]; then \
        >&2 echo 'ERROR: Invalid installer signature'; \
        rm composer-setup.php; \
        exit 1; \
    fi; \
    php composer-setup.php --quiet --install-dir=/usr/bin --filename=composer --version=${COMPOSER_VERSION}; \
    RESULT=$?; \
    rm composer-setup.php; \
    echo ${RESULT}

RUN set -ex \
    && cd /usr/local/etc \
    && { \
        echo '[www]'; \
        echo 'clear_env = no'; \
        echo 'catch_workers_output = yes'; \
    } | tee php-fpm.d/docker.conf

# Cleanup
RUN apt-get -y autoremove && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir -p /usr/local/share/n98-magerun/modules && cd /usr/local/share/n98-magerun/modules \
    && git clone https://github.com/peterjaap/magerun-addons.git pj-addons

COPY conf.d/php.ini /usr/local/etc/php/php.ini
COPY conf.d/xdebug.ini /usr/local/etc/php/conf.d/docker-php-ext-zxdebug.ini
COPY bin/toggle-xdebug /usr/local/bin/toggle-xdebug
