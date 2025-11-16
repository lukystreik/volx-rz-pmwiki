FROM ubuntu:20.04

ENV TZ=Europe/Berlin LANG=C.UTF-8 DEBIAN_FRONTEND=noninteractive

# Basis + PHP + Module + Tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates wget apt-transport-https tzdata \
    nginx-extras dumb-init vim unzip gosu fonts-dejavu-core curl \
    jq mtr-tiny dnsutils psmisc \
    cron logrotate rsyslog gosu bsdiff libtcnative-1 \
    php7.4-fpm php7.4-cli php7.4-mbstring php7.4-curl php7.4-xml php7.4-gd php7.4-mysql php7.4-zip php7.4-intl \
    && rm -rf /var/lib/apt/lists/*

# Verzeichnisse für Dienste
RUN mkdir -p /run/php /var/www/html/wiki.d \
    && mkdir -p /etc/service/cron /etc/service/syslog /etc/service/php /etc/service/nginx

# Supervisord-Style Run-Skripte
RUN bash -c 'echo -e "#!/bin/bash\nexec /usr/sbin/rsyslogd -n" > /etc/service/syslog/run' \
    && bash -c 'echo -e "#!/bin/bash\nexec /usr/sbin/cron -f" > /etc/service/cron/run' \
    && bash -c 'echo -e "#!/bin/bash\nexec /usr/sbin/php-fpm7.4 --nodaemonize --fpm-config /etc/php/7.4/fpm/php-fpm.conf" > /etc/service/php/run' \
    && bash -c 'echo -e "#!/bin/bash\nexec /usr/sbin/nginx -g \"daemon off;\"" > /etc/service/nginx/run' \
    && chmod 755 /etc/service/*/run

# Install PmWiki
RUN wget -O /tmp/pmwiki.tgz http://www.pmwiki.org/pub/pmwiki/pmwiki-latest.tgz \
    && tar zxfv /tmp/pmwiki.tgz -C /var/www/html/ --strip-components 1 \
    && echo "<?php include_once('pmwiki.php');" > /var/www/html/index.php \
    && chown -R www-data:www-data /var/www/html \
    && rm -rf /tmp/*

# Logs forwarden
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

ADD nginx-site-default.conf /etc/nginx/sites-enabled/default
ADD nginx-realip.conf /etc/nginx/conf.d/nginx-realip.conf

EXPOSE 80 443

VOLUME ["/var/www/html/wiki.d/","/var/www/html/local/","/var/www/html/cookbook/", "/var/www/html/pub", "/var/www/html/uploads"]

#CMD ["runsvdir", "/etc/service"]

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

CMD ["/usr/local/bin/docker-entrypoint.sh"]


