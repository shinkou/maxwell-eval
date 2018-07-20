#!/bin/bash
SCRIPT=`readlink -f $0`
BASEDIR=`dirname "$SCRIPT"`

DATAVOL='data'
DATADIR="$BASEDIR"
DATAMNT="/$DATAVOL"

function mknet()
{
	docker network create --subnet '172.19.0.0/24' maxwell-net
}

function mkvms()
{
	docker create --network maxwell-net --ip '172.19.0.2' -e MYSQL_ROOT_PASSWORD='secret' --name maxwell-mysql 'mysql:5.7.21'
	docker create --network maxwell-net --ip '172.19.0.4' --name maxwell-zookeeper 'shinkou/zookeeper'
	docker create --network maxwell-net --ip '172.19.0.5' -e ZOOKEEPER=maxwell-zookeeper --name maxwell-kafka 'shinkou/kafka'
}

function initvms()
{
	docker start maxwell-zookeeper maxwell-kafka maxwell-mysql

	sleep 10
	docker run -v "$DATADIR:$DATAMNT" --network 'maxwell-net' --rm -it 'mysql' bash -c 'mysql -h'"'"'maxwell-mysql'"'"' -uroot -psecret < /data/init.sql'

	sleep 10
	docker exec maxwell-mysql bash -c 'echo "server_id=1" >> /etc/mysql/mysql.conf.d/mysqld.cnf'
	docker exec maxwell-mysql bash -c 'echo "log-bin=master" >> /etc/mysql/mysql.conf.d/mysqld.cnf'
	docker exec maxwell-mysql bash -c 'echo "binlog_format=row" >> /etc/mysql/mysql.conf.d/mysqld.cnf'
	docker stop maxwell-mysql
	docker start maxwell-mysql
}

function printusage()
{
	echo 'Usage: mk-pcluster.sh [ ARG [ ARG [ ... ] ] ]'
	echo
	echo 'where'
	echo '  ARG  "network", "containers", or "all"'
	echo
}

function getdatadir()
{
	echo "Please enter the path of your data folder (default: \"$DATADIR\"): "
	read datadir
	echo
	if [[ -n $datadir ]]; then
		DATADIR="$datadir"
	fi
}

getdatadir

if [[ $# -eq 0 ]]; then
	set -- containers
fi

for arg in "$@"; do
	case $arg in
		--help | -h)
			printusage
			;;
		network)
			mknet
			;;
		containers)
			mkvms
			initvms
			;;
		all)
			mknet
			mkvms
			initvms
			;;
		*)
			echo "Invalid argument \"$arg\"."
			echo
			printusage
			exit 1
			;;
	esac
done
