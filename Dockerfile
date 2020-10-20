FROM ubuntu:latest
# target latest lts

# environment setup
ENV TZ=UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# service dependencies
RUN apt-get update \
    && apt-get install -y cron curl zip unzip git supervisor mysql-client \
    && apt-get install -y nginx php7.4-fpm php7.4-cli \
       php7.4-gd php7.4-curl php7.4-imap \
       php7.4-mysql php7.4-mbstring php7.4-xml \
       php7.4-zip php7.4-bcmath php7.4-soap \
       php7.4-intl php7.4-readline php7.4-msgpack \
       php7.4-igbinary php-redis \
    && php -r "readfile('http://getcomposer.org/installer');" | php -- --install-dir=/usr/bin/ --filename=composer \
    && apt-get -y autoremove \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && echo "daemon off;" >> /etc/nginx/nginx.conf

# config
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

COPY ./config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY ./config/php-fpm.conf /etc/php/7.4/fpm/php-fpm.conf

EXPOSE 80

# entrypoint
COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]
