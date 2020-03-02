#!/bin/bash

exec docker-entrypoint.sh "$@"
#set -e
#hostname=$(hostname)
#
#RABBITMQ_NODENAME=${RABBITMQ_NODENAME:-rabbit}
#
#runUntil()
#{
#  startTime=$SECONDS
#  until "$@" ; do
#      exitCode=$?
#      sleep 1
#      elapsedTime=$(($SECONDS - $startTime))
#      if (( $elapsedTime > ${START_PERIOD:-300} )); then
#          exit ${exitCode}
#      fi
#  done
#}
#
#if [[ "$1" = 'rabbitmq-server' ]] ; then
#
#  if [[ -z "$CLUSTER_WITH" || "$CLUSTER_WITH" == "$hostname" ]]; then
#    >&2 echo "starting as main server"
#    exec docker-entrypoint.sh "$@"
#  else
#  sleep 600
#    function finish {
#      jobs=$(jobs -p)
#      if [[ -n ${jobs} ]] ; then
#        kill $(jobs -p)
#      fi
#    }
#    trap finish EXIT
#
#    #export RABBITMQ_LOGS="/var/log/rabbitmq/rabbitmq.log"
#    docker-entrypoint.sh "$@" &
#    rabbitmqctl stop_app
#    >&2 echo  "Joining to cluster $CLUSTER_WITH"
#    runUntil rabbitmqctl join_cluster ${ENABLE_RAM:+--ram} ${RABBITMQ_NODENAME}@${CLUSTER_WITH}
#    rabbitmqctl start_app
#  fi
#fi
#
#
