#!/bin/bash
#09.09.2020 lehnert BASEDIR eingefuehrt, da docker Container einheitlich nach /opt/docker verschoben wurden
export PATH=$PATH:/usr/bin:/usr/local/bin
BASEDIR=.

source .env

DOCKERCOMPOSE=/usr/local/bin/docker-compose

case $1 in 

start)
	cd ${BASEDIR}
	echo "starting $IMAGENAME environment container...."
	$DOCKERCOMPOSE up -d 
	echo ""
	sleep 5
	docker ps|grep $COMPOSE_PROJECT_NAME
	;;
stop)
        cd ${BASEDIR}
        echo "stopping environment container...."
        $DOCKERCOMPOSE down
        echo ""
        ;;
restart)
	$0 stop
	echo ""
	echo "starting ..."
	$0 start
	;;
pull)
        echo "pulling new image..."
	$DOCKERCOMPOSE pull
	$0 stop
	$0 start
	;;
status)
	docker ps
	echo "Logs actions: -----------------------"
	$DOCKERCOMPOSE logs  -t
	;;
*)
	echo "$1 start / stop / status / pull / restart"
	;;
esac


