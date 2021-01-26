FROM ubuntu:latest
# target latest lts

# environment setup
ENV TZ=UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# add ondrej/php ppa
RUN apt-get update \
    && apt-get install -y apt-utils software-properties-common \
    && add-apt-repository ppa:ondrej/php

# service dependencies
RUN apt-get update \
    && apt-get install -y cron curl zip unzip git supervisor mysql-client \
    && apt-get install -y nginx php8.0-fpm php8.0-cli \
       php8.0-gd php8.0-curl php8.0-imap \
       php8.0-mysql php8.0-mbstring php8.0-xml \
       php8.0-zip php8.0-bcmath php8.0-soap \
       php8.0-intl php8.0-readline php8.0-msgpack \
       php8.0-igbinary php8.0-redis \
    && php -r "readfile('http://getcomposer.org/installer');" | php -- --install-dir=/usr/bin/ --filename=composer \
    && apt-get -y autoremove \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && echo "daemon off;" >> /etc/nginx/nginx.conf

# config
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

COPY ./config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY ./config/php-fpm.conf /etc/php/8.0/fpm/php-fpm.conf

EXPOSE 80

# entrypoint
COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]
