#!/usr/bin/env bash

## Wrapper for masscan to easily upload reports to grafana

usage () {
	cat <<__EOF__
usage: $0 [OPTIONS] [help]

    OPTIONS
        --ip                 IP(s) to scan
	--port               Port(s) to scan
        --rate               masscan rate
	--output [file.json] output json file
	--grafana            Grafana URL to upload to
	--user               Grafana username
	--password           Grafana password
__EOF__
}


if ! which masscan > /dev/null
then
	echo 'masscan not found in PATH, please install masscan'
	exit 1
fi

if ! which prips > /dev/null
then
	echo 'prips not found in PATH, please install prips'
	exit 1
fi

check_ips () {
	ip_range=$1
}

check_ports () {
	ports=$1
}

scan () {
	ip_range=$1
	ports=$2 
	rate=$3

	masscan ${ip_range} -p ${ports} --banners -J --rate ${rate}
}

main () {
	check_ips ${ip_range}
}

main
