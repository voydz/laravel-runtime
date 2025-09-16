ARG VARIANT="noble"
FROM buildpack-deps:${VARIANT}-curl

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
    && apt-get install -y nginx php8.4-fpm php8.4-cli \
       php8.4-gd php8.4-curl php8.4-imap \
       php8.4-mysql php8.4-mbstring php8.4-xml \
       php8.4-zip php8.4-bcmath php8.4-soap \
       php8.4-intl php8.4-readline php8.4-msgpack \
       php8.4-igbinary php8.4-redis \
    && php -r "readfile('http://getcomposer.org/installer');" | php -- --install-dir=/usr/bin/ --filename=composer \
    && apt-get -y autoremove \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && echo "daemon off;" >> /etc/nginx/nginx.conf

# config
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

COPY ./config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY ./config/php-fpm.conf /etc/php/8.4/fpm/php-fpm.conf
COPY ./config/default /etc/nginx/sites-available/default
COPY ./config/crontab /etc/cron.d/crontab

# help crontab to get started
RUN chmod 0644 /etc/cron.d/crontab
RUN crontab /etc/cron.d/crontab

# help php to open its socket
RUN mkdir -p /var/run/php

EXPOSE 80

# entrypoint
COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]
