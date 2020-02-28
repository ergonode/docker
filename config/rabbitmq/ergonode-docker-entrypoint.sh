#!/bin/bash

set -e

if [[ "$1" = 'rabbitmq-server' ]] ; then
  hostname -i
  longHostName=$(dig -x $(hostname -i) +short)
   apk add bind-tools
  envsubst < /etc/rabbitmq/rabbitmq.conf.template >  /etc/rabbitmq/rabbitmq.conf
  exec docker-entrypoint.sh "$@"
fi


