#!/bin/bash
function stopvms()
{
	for vm in 'maxwell-mysql-slave' 'maxwell-mysql-master' 'maxwell-zookeeper' 'maxwell-kafka'; do
		docker stop "$vm"
	done
}

function rmvms()
{
	for vm in 'maxwell-mysql-slave' 'maxwell-mysql-master' 'maxwell-zookeeper' 'maxwell-kafka'; do
		docker rm "$vm"
	done
}

function rmnet()
{
	docker network rm maxwell-net
}

function printusage()
{
	echo 'Usage: del-pcluster.sh [ ARG [ ARG [ ... ] ] ]'
	echo
	echo 'where'
	echo '  ARG  "network", "containers", or "all"'
	echo
}

if [[ $# -eq 0 ]]; then
	set -- containers
fi

for arg in "$@"; do
	case $arg in
		--help | -h)
			printusage
			;;
		network)
			rmnet
			;;
		containers)
			stopvms
			rmvms
			;;
		all)
			stopvms
			rmvms
			rmnet
			;;
		*)
			echo "Invalid argument \"$arg\"."
			echo
			printusage
			exit 1
			;;
	esac
done
