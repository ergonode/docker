#!/bin/bash

set -e

if [ "$1" = 'nginx' ] ; then

    envsubst < /etc/nginx/conf.d/symfony-development.conf.template > /etc/nginx/conf.d/default.conf
    if [ "$APP_ENV" == 'prod' ]; then
        envsubst < /etc/nginx/conf.d/symfony-production.conf.template > /etc/nginx/conf.d/default.conf
    fi

     >&2 echo "nginx initialization finished"
    function finish {
        jobs=$(jobs -p)
        if [[ -n ${jobs} ]] ; then
            kill $(jobs -p)
        fi
    }
    trap finish EXIT

    startTime=$SECONDS
    until "$@" ; do
        exitCode=$?
        sleep 5
        elapsedTime=$(($SECONDS - $startTime))
        if (( $elapsedTime > ${START_PERIOD:-300} )); then
            exit ${exitCode}
        fi
    done
else
    exec "$@"
fi
