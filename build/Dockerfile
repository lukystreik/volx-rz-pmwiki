FROM ubuntu:26.04

# PmWiki-Release, die ins Image kommt (Pflicht, siehe .github/scripts/detect-version.sh)
ARG PMWIKI_VERSION
# optional: SHA-256 des Tarballs; wenn gesetzt, bricht der Build bei Abweichung ab
ARG PMWIKI_SHA256=

ENV TZ=Europe/Berlin LANG=C.UTF-8 DEBIAN_FRONTEND=noninteractive

# Basis + nginx + PHP (Distro-Version, aktuell PHP 8.5) + Module
RUN apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends \
    ca-certificates curl wget tzdata tini unzip fonts-dejavu-core \
    nginx-extras \
    php-fpm php-cli php-mbstring php-curl php-xml php-gd php-mysql php-zip php-intl \
    && rm -rf /var/lib/apt/lists/*

# PHP-FPM versionsunabhaengig machen: fester Socket-Pfad und /etc/php/current als Symlink,
# damit Bind-Mounts (php.ini, nginx-Site) nicht an die PHP-Minor-Version gekoppelt sind.
RUN set -eu; \
    PHPV=$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;'); \
    ln -s "/etc/php/$PHPV" /etc/php/current; \
    sed -i "s#^listen = .*#listen = /run/php/php-fpm.sock#" "/etc/php/$PHPV/fpm/pool.d/www.conf"; \
    sed -i "s#^;\?catch_workers_output = .*#catch_workers_output = yes#" "/etc/php/$PHPV/fpm/pool.d/www.conf"; \
    sed -i "s#^;\?error_log = .*#error_log = /proc/self/fd/2#" "/etc/php/$PHPV/fpm/php-fpm.conf"; \
    printf 'expose_php = Off\n' > "/etc/php/$PHPV/fpm/conf.d/99-pmwiki.ini"; \
    echo "$PHPV" > /etc/php/current-version; \
    mkdir -p /run/php

# Install PmWiki (feste Version, HTTPS, optionale Pruefsumme)
RUN set -eu; \
    test -n "$PMWIKI_VERSION" || { echo "ERROR: --build-arg PMWIKI_VERSION fehlt" >&2; exit 1; }; \
    curl -fsSL --retry 3 -o /tmp/pmwiki.tgz "https://www.pmwiki.org/pub/pmwiki/pmwiki-${PMWIKI_VERSION}.tgz"; \
    if [ -n "$PMWIKI_SHA256" ]; then echo "$PMWIKI_SHA256  /tmp/pmwiki.tgz" | sha256sum -c -; fi; \
    mkdir -p /var/www/html/wiki.d; \
    tar zxf /tmp/pmwiki.tgz -C /var/www/html/ --strip-components 1; \
    echo "<?php include_once('pmwiki.php');" > /var/www/html/index.php; \
    chown -R www-data:www-data /var/www/html; \
    rm -rf /tmp/*

# Logs forwarden
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

COPY nginx-site-default.conf /etc/nginx/sites-enabled/default
COPY nginx-realip.conf /etc/nginx/conf.d/nginx-realip.conf
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

LABEL org.opencontainers.image.title="volx-rz-pmwiki" \
      org.opencontainers.image.source="https://github.com/lukystreik/volx-rz-pmwiki" \
      org.opencontainers.image.version="${PMWIKI_VERSION}"

EXPOSE 80

VOLUME ["/var/www/html/wiki.d/","/var/www/html/local/","/var/www/html/cookbook/", "/var/www/html/pub", "/var/www/html/uploads"]

HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
    CMD wget --spider -q http://127.0.0.1/ || exit 1

ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/docker-entrypoint.sh"]
