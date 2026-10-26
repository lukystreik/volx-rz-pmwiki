#!/usr/bin/env bash
set -eu

PHPV=$(cat /etc/php/current-version)

mkdir -p /run/php

# Kompatibilitaet fuer bestehende nginx-Site-Configs, die noch den alten Socket-Namen nutzen
ln -sf /run/php/php-fpm.sock /run/php/php7.4-fpm.sock

php-fpm"$PHPV" --nodaemonize --fpm-config "/etc/php/$PHPV/fpm/php-fpm.conf" &
PHP_PID=$!

nginx -g "daemon off;" &
NGINX_PID=$!

# SIGTERM/SIGINT an beide Dienste weiterreichen
trap 'kill -TERM "$PHP_PID" "$NGINX_PID" 2>/dev/null || true' TERM INT

# Stirbt einer der beiden Dienste, beendet sich der Container (Restart-Policy greift)
wait -n "$PHP_PID" "$NGINX_PID" || true
kill -TERM "$PHP_PID" "$NGINX_PID" 2>/dev/null || true
wait || true
exit 1
