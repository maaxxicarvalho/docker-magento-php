FROM php:7.0-fpm

LABEL maintainer="Max Carvalho <max.carvalho@cloverbox.com.br>"

# Gosu
RUN useradd -ms /bin/bash -u 1337 magedocker
ENV GOSU_VERSION 1.7
RUN set -x \
    && apt-get update && apt-get install -y --no-install-recommends ca-certificates wget && rm -rf /var/lib/apt/lists/* \
    && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
    && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
    && rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu \
    && gosu nobody true

# Global
RUN apt-get update -qq && apt-get install -y --no-install-recommends curl git pv mysql-client wget unzip zip \
    openssh-server unzip vim

# PHP
ENV DEV_LIBS libfreetype6-dev libjpeg62-turbo-dev libpng12-dev libgd-dev libmagickwand-dev libc-client-dev libkrb5-dev \
    libicu-dev libldap2-dev libmcrypt-dev openssl unixodbc-dev libxml2-dev freetds-dev libssl-dev libpspell-dev \
    libtidy-dev libxslt-dev libmemcached-dev
RUN apt-get install -y --no-install-recommends $DEV_LIBS \
    && pecl install igbinary && pecl install imagick && pecl install && pecl install redis \
    && pecl install memcached && pecl install xdebug && pecl install lzf \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl && docker-php-ext-configure intl \
    && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ \
    && docker-php-ext-configure pdo_dblib --with-libdir=/lib/x86_64-linux-gnu \
    && docker-php-ext-install -j$(nproc) bcmath calendar exif gd gettext imap intl ldap mcrypt mysqli pcntl pdo_dblib \
        pdo_mysql pspell shmop soap sockets sysvmsg sysvsem sysvshm tidy wddx xmlrpc xsl zip opcache \
    && git clone --recursive --depth=1 https://github.com/kjdev/php-ext-snappy.git && cd php-ext-snappy \
    && phpize && ./configure && make && make install \
    && docker-php-ext-enable igbinary imagick redis snappy memcached \
    && curl -sSL -o php7.zip https://github.com/websupport-sk/pecl-memcache/archive/php7.zip \
    && unzip php7 && cd pecl-memcache-php7 && /usr/local/bin/phpize \
    && ./configure --with-php-config=/usr/local/bin/php-config && make && make install \
    && echo "extension=memcache.so" > /usr/local/etc/php/conf.d/ext-memcache.ini \
    && echo "extension=lzf.so" > /usr/local/etc/php/conf.d/ext-lzfs.ini \
    && rm -rf /tmp/pecl-memcache-php7 php7.zip php-ext-snappy \
    && php -r "readfile('http://getcomposer.org/installer');" | php -- --install-dir=/usr/local/bin/ --filename=composer \
    && curl -O https://files.magerun.net/n98-magerun.phar && mv n98-magerun.phar /usr/local/bin/magerun \
    && chmod +x /usr/local/bin/magerun

# Cleanup
RUN apt-get -y autoremove && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir -p /usr/local/share/n98-magerun/modules && cd /usr/local/share/n98-magerun/modules \
    && git clone https://github.com/peterjaap/magerun-addons.git pj-addons

ENV COMPOSER_ALLOW_SUPERUSER 1

COPY xdebug.ini /usr/local/etc/php/conf.d/docker-php-ext-zxdebug.ini
COPY toggle-xdebug /usr/local/bin/toggle-xdebug

COPY docker-php-entrypoint /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-php-entrypoint

ENTRYPOINT ["docker-php-entrypoint"]

RUN set -ex \
	&& cd /usr/local/etc \
	&& if [ -d php-fpm.d ]; then \
		# for some reason, upstream's php-fpm.conf.default has "include=NONE/etc/php-fpm.d/*.conf"
		sed 's!=NONE/!=!g' php-fpm.conf.default | tee php-fpm.conf > /dev/null; \
		cp php-fpm.d/www.conf.default php-fpm.d/www.conf; \
	else \
		# PHP 5.x doesn't use "include=" by default, so we'll create our own simple config that mimics PHP 7+ for consistency
		mkdir php-fpm.d; \
		cp php-fpm.conf.default php-fpm.d/www.conf; \
		{ \
			echo '[global]'; \
			echo 'include=etc/php-fpm.d/*.conf'; \
		} | tee php-fpm.conf; \
	fi \
	&& { \
		echo '[www]'; \
		echo 'clear_env = no'; \
		echo; \
		echo '; Ensure worker stdout and stderr are sent to the main error log.'; \
		echo 'catch_workers_output = yes'; \
	} | tee php-fpm.d/docker.conf \
	&& { \
		echo '[global]'; \
		echo 'daemonize = no'; \
		echo; \
		echo '[www]'; \
		echo 'listen = 9000'; \
	} | tee php-fpm.d/zz-docker.conf

EXPOSE 9000
CMD ["php-fpm"]