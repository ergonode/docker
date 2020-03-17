#!/bin/bash


set -e

function waitUntil() {
    if  ! "$@" ; then
     sleep 1
     waitUntil "$@" ;
    fi
}

envsubst < /etc/rabbitmq/rabbitmq.conf.template >> /etc/rabbitmq/rabbitmq.conf

if [[ ! -z "${CONSUL_ACL_TOKEN}" ]] ;
then
    echo "cluster_formation.consul.acl_token = ${CONSUL_ACL_TOKEN}" >>  /etc/rabbitmq/rabbitmq.conf
fi



>&2 echo "Waiting for consul..."
waitUntil ping -c 1 "${CONSUL_HOST}"

if [[ ! -z "${WAIT_FOR}" ]] ;
then
    >&2 echo "Waiting for ${WAIT_FOR}..."
    waitUntil ping -c 1 "${WAIT_FOR}"
fi

exec docker-entrypoint.sh rabbitmq-server
