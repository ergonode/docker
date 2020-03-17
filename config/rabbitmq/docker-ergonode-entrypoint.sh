#!/bin/bash


set -e

envsubst < /etc/rabbitmq/rabbitmq.conf.template > /etc/rabbitmq/rabbitmq.conf

if [[ ! -z "${CONSUL_ACL_TOKEN}" ]] ;
then
    echo "cluster_formation.consul.acl_token = ${CONSUL_ACL_TOKEN}" >>  /etc/rabbitmq/rabbitmq.conf
fi

exec docker-entrypoint.sh "$@"
