FROM php:7.0-fpm

LABEL maintainer="Max Carvalho <max.carvalho@cloverbox.com.br>"
LABEL version="1.0.0"
LABEL description="PHP 7.0 FPM for Magento based on Hypernode"

RUN apt-get update -qq && apt-get install -y --no-install-recommends curl git pv mysql-client wget unzip zip \
    openssh-server unzip \
    && docker-php-ext-install -j$(nproc) bcmath calendar

EXPOSE 9000