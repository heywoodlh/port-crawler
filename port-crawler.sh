#!/usr/bin/env bash

## Wrapper for masscan to easily upload reports to elasticsearch

elasticsearch_index="portcrawler-$(date '+%Y-%m-%d')"

usage () {
	cat <<__EOF__
usage: $0 [OPTIONS] [--help]

    OPTIONS
        --ip                 IP(s) to scan
	--port               Port(s) to scan
        --rate               masscan rate
	--elasticsearch      Elasticsearch URL to upload to
__EOF__
	exit 0
}

while [[ $# -gt 0 ]]
do
	option="$1"
	case "${option}" in
		--ip)
			ip=$2
		;;
		--port) 
			port=$2
		;;
		--rate) 
			rate=$2
		;;
		--elasticsearch) 
			elasticsearch_url=$2
		;;
		--help) 
			usage
		;;
	esac
	shift
done

if [[ -z ${ip} ]]
then
	echo "Please provide IP address(es) to scan"
	usage
fi

if [[ -z ${port} ]]
then
	port="22 80 443 445 8080"
	echo "Default ports selected: ${port}"
fi

if [[ -z ${rate} ]]
then
	echo "Default rate selected: 1000"
	rate="1000"
fi


tmp_file="/tmp/$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 13 ; echo '').json"

check_ips () {
	ip_range=$1
	local invalid="false"
	for ip_addr in ${ip_range}
	do
		if ! echo ${ip_addr} | grep -Eq "?([0-9]*\.){3}[0-9]*"
		then
			echo "${ip_addr}: invalid"
			invalid="true"
		fi
	done
	if [[ ${invalid} == "true" ]]
	then
		echo "Invalid IP address. Exiting."
		exit 1
	fi
}

scan () {
	ip_range=$1
	ports="$(echo $2 | tr ' ' ',')"
	rate="$3"

	masscan ${ip_range} -p "${ports}" --banners -oJ "${tmp_file}" --rate "${rate}"
}

elasticsearch_upload () {
	elasticsearch_url=$1
	sed -i '1d; $d' ${tmp_file}
	sed -i ':a;N;$!ba;s/\n,/ /g' ${tmp_file}
	jsonpyes --data "${tmp_file}" --bulk "${elasticsearch_url}" --import --index "${elasticsearch_index}" --type scan --check --thread 8
}

main () {
	check_ips "${ip}"

	scan "${ip}" "${port}" "${rate}"

	if [[ -n ${elasticsearch_url} ]]
	then
		elasticsearch_upload "${elasticsearch_url}"
	fi
}

main
