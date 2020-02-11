#!/usr/bin/env bash

set -e

if [ "$1" = 'nginx' ] ; then

    envsubst < /etc/nginx/conf.d/symfony-development.conf.template > /etc/nginx/conf.d/default.conf
    if [ "$APP_ENV" == 'prod' ]; then
        envsubst < /etc/nginx/conf.d/symfony-production.conf.template > /etc/nginx/conf.d/default.conf
    fi

     >&2 echo "Waiting for php host to be ready..."
     until ping -c 1 ${PHP_UPSTREAM_HOST} > /dev/null 2>&1; do
      sleep 1
	   done

	   >&2 echo "Waiting for node host to be ready..."
	   until ping -c 1 node > /dev/null 2>&1; do
	     sleep 1
     done

     >&2 echo "nginx initialization finished"
fi

exec "$@"
