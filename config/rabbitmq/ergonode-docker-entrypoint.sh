#!/bin/bash

echo "$@"
if [ "$1" = 'rabbitmq-server' ] ; then
    #RABBITMQ_NODENAME=$(dig -x $(hostname -i) +short)
    #RABBITMQ_NODENAME=${RABBITMQ_NODENAME%.*}
    RABBITMQ_NODENAME="rabbit@$(dig -x $(hostname -i) +short)"
    export RABBITMQ_NODENAME
    echo "looooooooong name"
    echo $RABBITMQ_NODENAME
    docker-entrypoint.sh "$@"
sleep 500
#    rabbitmqctl cluster_status
#    rabbitmqctl stop
#    rabbitmqctl join_cluster rabbit@rabbitmq1
#    dig +short rabbitmq
#

    export RABBITMQ_NODENAME="rabbit@$(dig -x $(hostname -i) +short)"
    rabbitmqctl stop_app
    rabbitmqctl reset
    for nodeIp in $(dig +short rabbitmq)
    do
       echo $nodeIp
       nodeName="rabbit@$(dig -x $nodeIp +short)"
       if [[ ${nodeName} != ${RABBITMQ_NODENAME} ]] ; then
        echo ${nodeName}
        echo ${RABBITMQ_NODENAME}
        echo 1
        rabbitmqctl join_cluster ${nodeName}
       fi
     done
     rabbitmqctl start_app
#    sleep 500
#
#
#    kill $(jobs -p)

    tail -f /var/log/rabbitmq/*

fi


#ergonode_rabbit1_1.ergonode_test.

rabbitmqctl stop_app
rabbitmqctl reset

#rabbitmqctl join_cluster rabbit@ergonode_rabbit1_1


#rabbitmqctl join_cluster rabbit@ergonode_rabbit1_1.ergonode_test.