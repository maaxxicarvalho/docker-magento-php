FROM maxacarvalho/docker-for-php:7.0-fpm

RUN useradd -ms /bin/bash -u 1337 crafter

COPY docker-php-entrypoint /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-php-entrypoint

ENTRYPOINT ["docker-php-entrypoint"]

EXPOSE 9000
CMD ["php-fpm"]