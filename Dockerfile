FROM ubuntu:latest
# target latest lts

# environment setup
ENV TZ=UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# add ondrej/php ppa
RUN apt-get update \
    && apt-get install -y software-properties-common \
    && add-apt-repository ppa:ondrej/php

# service dependencies
RUN apt-get update \
    && apt-get install -y cron curl zip unzip git supervisor mysql-client \
    && apt-get install -y nginx php8.1-fpm php8.1-cli \
       php8.1-gd php8.1-curl php8.1-imap \
       php8.1-mysql php8.1-mbstring php8.1-xml \
       php8.1-zip php8.1-bcmath php8.1-soap \
       php8.1-intl php8.1-readline php8.1-msgpack \
       php8.1-igbinary php8.1-redis \
    && php -r "readfile('http://getcomposer.org/installer');" | php -- --install-dir=/usr/bin/ --filename=composer \
    && apt-get -y autoremove \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && echo "daemon off;" >> /etc/nginx/nginx.conf

# config
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

COPY ./config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY ./config/php-fpm.conf /etc/php/8.1/fpm/php-fpm.conf

# help php to open its socket
RUN mkdir -p /var/run/php

EXPOSE 80

# entrypoint
COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]
