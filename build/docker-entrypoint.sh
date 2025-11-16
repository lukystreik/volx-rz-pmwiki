#!/usr/bin/env bash
set -e

# PHP-FPM starten
php-fpm7.4 --nodaemonize --fpm-config /etc/php/7.4/fpm/php-fpm.conf &
PHP_PID=$!

# nginx im Vordergrund
nginx -g "daemon off;"

