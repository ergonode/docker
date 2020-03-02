#!/bin/bash

set -e

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- nginx "$@"
fi

if [ "$1" = 'nginx' ] ; then

    DOLLAR="\$" envsubst < /etc/nginx/conf.d/http-directives.conf.template | sed "s~;\s*~;\n~g"  | sed "s~^\s*;~~g" > /etc/nginx/conf.d/default.conf
    if [ "$APP_ENV" == 'prod' ]; then
      DOLLAR="\$"  envsubst < /etc/nginx/conf.d/symfony-production.conf.template >> /etc/nginx/conf.d/default.conf
    else
      DOLLAR="\$"  envsubst < /etc/nginx/conf.d/symfony-development.conf.template >> /etc/nginx/conf.d/default.conf
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
