#!/usr/bin/env bash

set -e

function waitUntil() {
  until "$@"  > /dev/null 2>&1 ; do
    sleep 1
  done
}

if [ "$1" = 'nginx' ] ; then

    envsubst < /etc/nginx/conf.d/symfony-development.conf.template > /etc/nginx/conf.d/default.conf
    if [ "$APP_ENV" == 'prod' ]; then
        envsubst < /etc/nginx/conf.d/symfony-production.conf.template > /etc/nginx/conf.d/default.conf
    fi

     >&2 echo "Waiting for php host to be ready..."
     waitUntil ping -c 1 "${PHP_UPSTREAM_HOST}"

	   >&2 echo "Waiting for node host to be ready..."
	   waitUntil ping -c 1 node

     >&2 echo "nginx initialization finished"
fi

exec "$@"
