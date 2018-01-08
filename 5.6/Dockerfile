FROM php:5.6-fpm

LABEL maintainer="Max Carvalho <max.carvalho@cloverbox.com.br>"
LABEL version="1.0.0"
LABEL description="PHP 5.6 FPM for Magento based on Hypernode"

ENV DEV_LIBS libfreetype6-dev libjpeg62-turbo-dev libpng12-dev libgd-dev libmagickwand-dev libc-client-dev libkrb5-dev \
    libicu-dev libldap2-dev libmcrypt-dev openssl unixodbc-dev libxml2-dev freetds-dev libssl-dev libpspell-dev libtidy-dev \
    libxslt-dev libmemcached-dev

RUN apt-get update -qq && apt-get install -y --no-install-recommends curl git pv mysql-client wget unzip zip \
    openssh-server unzip vim $DEV_LIBS \
    && pecl install igbinary && pecl install imagick && pecl install && pecl install redis && pecl install memcached-2.2.0.tgz \
    && pecl install xdebug && pecl install lzf && pecl install memcache \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-configure intl \
    && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ \
    && docker-php-ext-configure pdo_dblib --with-libdir=/lib/x86_64-linux-gnu \
    && docker-php-ext-install -j$(nproc) bcmath calendar exif gd gettext imap intl ldap mcrypt mysqli pcntl pdo_dblib \
    pdo_mysql pspell shmop soap sockets sysvmsg sysvsem sysvshm tidy wddx xmlrpc xsl zip opcache \
    && git clone --recursive --depth=1 https://github.com/kjdev/php-ext-snappy.git && cd php-ext-snappy \
    && phpize && ./configure && make && make install \
    && docker-php-ext-enable igbinary imagick redis snappy memcache memcached \
    && echo "extension=lzf.so" > /usr/local/etc/php/conf.d/ext-lzfs.ini \
    && rm -rf php-ext-snappy \
    && php -r "readfile('http://getcomposer.org/installer');" | php -- --install-dir=/usr/bin/ --filename=composer \
    && curl -O https://files.magerun.net/n98-magerun.phar && mv n98-magerun.phar /usr/bin/magerun && chmod +x /usr/bin/magerun

COPY xdebug.ini /usr/local/etc/php/conf.d/docker-php-ext-zxdebug.ini
COPY toggle-xdebug /usr/bin/toggle-xdebug

EXPOSE 9000