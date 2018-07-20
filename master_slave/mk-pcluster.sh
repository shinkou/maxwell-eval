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
	docker create --network maxwell-net --ip '172.19.0.2' -e MYSQL_ROOT_PASSWORD='secret' --name maxwell-mysql-master 'mysql:5.7.21'
	docker create --network maxwell-net --ip '172.19.0.3' -e MYSQL_ROOT_PASSWORD='secret' --name maxwell-mysql-slave 'mysql:5.7.21'
	docker create --network maxwell-net --ip '172.19.0.4' --name maxwell-zookeeper 'shinkou/zookeeper'
	docker create --network maxwell-net --ip '172.19.0.5' -e ZOOKEEPER=maxwell-zookeeper --name maxwell-kafka 'shinkou/kafka'
}

function initvms()
{
	docker start maxwell-zookeeper maxwell-kafka maxwell-mysql-master maxwell-mysql-slave

	sleep 10

	docker run -v "$DATADIR:$DATAMNT" --network 'maxwell-net' --rm -it 'mysql' bash -c 'mysql -h'"'"'maxwell-mysql-master'"'"' -uroot -psecret < /data/init_master.sql'
	docker run -v "$DATADIR:$DATAMNT" --network 'maxwell-net' --rm -it 'mysql' bash -c 'mysqldump -h'"'"'maxwell-mysql-master'"'"' -uroot -psecret --all-databases --master-data > /data/dbdump.db'

	docker exec maxwell-mysql-master bash -c 'echo "server_id=1" >> /etc/mysql/mysql.conf.d/mysqld.cnf'
	docker exec maxwell-mysql-master bash -c 'echo "log-bin=mysql-bin" >> /etc/mysql/mysql.conf.d/mysqld.cnf'
	docker exec maxwell-mysql-master bash -c 'echo "innodb_flush_log_at_trx_commit=1" >> /etc/mysql/mysql.conf.d/mysqld.cnf'
	docker exec maxwell-mysql-master bash -c 'echo "sync_binlog=1" >> /etc/mysql/mysql.conf.d/mysqld.cnf'
	docker restart maxwell-mysql-master

	docker exec maxwell-mysql-slave bash -c 'echo "server_id=2" >> /etc/mysql/mysql.conf.d/mysqld.cnf'
	docker exec maxwell-mysql-slave bash -c 'echo "log-bin=master" >> /etc/mysql/mysql.conf.d/mysqld.cnf'
	docker exec maxwell-mysql-slave bash -c 'echo "log-slave-updates" >> /etc/mysql/mysql.conf.d/mysqld.cnf'
	docker exec maxwell-mysql-slave bash -c 'echo "skip-slave-start" >> /etc/mysql/mysql.conf.d/mysqld.cnf'
	docker restart maxwell-mysql-slave

	docker run -v "$DATADIR:$DATAMNT" --network 'maxwell-net' --rm -it 'mysql' bash -c 'mysql -h'"'"'maxwell-mysql-slave'"'"' -uroot -psecret < /data/dbdump.db'
	docker run -v "$DATADIR:$DATAMNT" --network 'maxwell-net' --rm -it 'mysql' bash -c 'rm /data/dbdump.db'

	docker run -v "$DATADIR:$DATAMNT" --network 'maxwell-net' --rm -it 'mysql' bash -c 'mysql -h'"'"'maxwell-mysql-master'"'"' -uroot -psecret -e '"'"'SHOW MASTER STATUS;'"'"''

	echo
	cat ./init_slave.sql
	echo -n 'Should we go ahead and run the above query (Yes/no)? '
	read go_ahead

	case "${go_ahead,,}" in
		yes | y)
			docker run -v "$DATADIR:$DATAMNT" --network 'maxwell-net' --rm -it 'mysql' bash -c 'mysql -h'"'"'maxwell-mysql-slave'"'"' -uroot -psecret < /data/init_slave.sql'
			echo 'Finished setting up master-slave MySQL cluster.'
			;;
		*)
			echo 'Please make sure to run a SQL statement like the following to finish the setup:'
			echo
			cat "${BASEDIR}/init_slave.sql"
			echo
			echo 'Good luck!'
			echo
			;;
	esac
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
