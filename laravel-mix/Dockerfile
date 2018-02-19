FROM ubuntu:16.04

LABEL maintainer="Max Carvalho <max.carvalho@cloverbox.com.br>"

ARG uid=999

RUN groupadd --gid 1000 node \
  && useradd --uid 1000 --gid node --shell /bin/bash --create-home node

COPY install-node /tmp

RUN apt-get update -qq && apt-get install -y --no-install-recommends curl git pv mysql-client wget unzip zip \
    openssh-server unzip vim libpng-dev autoconf automake
RUN chmod +x /tmp/install-node && ./tmp/install-node
RUN apt-get install -y nodejs
RUN apt-get -y autoremove && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN usermod -u $uid node

WORKDIR /var/www/html

CMD [ "node" ]