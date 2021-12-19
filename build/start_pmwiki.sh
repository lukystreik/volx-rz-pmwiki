#!/bin/bash
#09.09.2020 lehnert BASEDIR eingefuehrt, da docker Container einheitlich nach /opt/docker verschoben wurden
export PATH=$PATH:/usr/bin:/usr/local/bin
BASEDIR=.

source .env

case $1 in 

start)
	cd ${BASEDIR}
	echo "starting $IMAGENAME environment container...."
	docker-compose pull
	docker-compose up -d 
	echo ""
	sleep 5
	docker ps|grep $COMPOSE_PROJECT_NAME
	;;
stop)
        cd ${BASEDIR}
        echo "stopping environment container...."
        docker-compose down
        echo ""
        ;;
restart)
	echo "stopping ..."
	$0 stop
	echo ""
	echo "starting ..."
	$0 start
	;;
pull)
	docker-compose pull
	$0 stop
	$0 start
	;;
status)
	docker ps
	echo "Logs actions: -----------------------"
	docker-compose logs  -t
	;;
*)
	echo "$1 start / stop / status"
	;;
esac


