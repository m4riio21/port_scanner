#!/bin/bash

# Inspired by S4vitaar (https://github.com/s4vitar)

#Colours

green="\e[0;32m\033[1m"
end="\033[0m\e[0m"
red="\e[0;31m\033[1m"
blue="\e[0;34m\033[1m"
yellow="\e[0;33m\033[1m"
purple="\e[0;35m\033[1m"
turquoise="\e[0;36m\033[1m"
gray="\e[0;37m\033[1m"

trap ctrl_c INT

function ctrl_c() {
	tput cnorm
	echo -e "[x] Exiting.. \n"
	exit 1
}

function helpPanel(){
	echo -e "[*] port_scanner\n"
	echo -e "\t Options:"
	echo -e "\t\t --fast-scan: scans top $(cat top_ports.txt | wc -l) ports, based on most common open ports found in several Linux and Windows machines."
	echo -e "\t\t --full-scan: scans the full range of ports (1-65535). May take a while (3 - 6 min).\n"
	echo -e "\t Usage:"
	echo -e "\t\t $0 [scan type] {IP_TO_SCAN}"
	tput cnorm
}

tput civis
scan_type="none"
ip="none"
ports=""

for arg in "$@"; do 	#Iterate args to search IP and scan type

	if [[ $arg == "--fast-scan" || $arg == "--full-scan" && $scan_type == "none" ]]; then
		scan_type=$arg
	fi
	if [[ $arg == "localhost" || arg=$(echo $arg | grep -oP '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}') && $ip == "none" ]]; then
		ip=$arg
	fi
done

if [[ $# == "1" || $# == "2" ]]; then
	if [ $scan_type == "none" ]; then scan_type="--full-scan"; fi

	if [ $scan_type == "--fast-scan" ]; then	# Fast scan
		echo -e "[*] Scanning top $(wget -O- -q https://raw.githubusercontent.com/m4riio21/port_scanner/main/top_ports.txt | wc -l) ports\n"
        	for port in $(wget -O- -q https://raw.githubusercontent.com/m4riio21/port_scanner/main/top_ports.txt); do
                	timeout 1 bash -c "echo > /dev/tcp/$ip/$port" 2>/dev/null && echo -e "[!] PORT ${red}$port${end} - OPEN" &
        	done; wait
		tput cnorm; exit 0
	fi
	if [ $scan_type == "--full-scan" ]; then	# Full scan
        	echo -e "[*] Scanning full range of ports (1-65535)\n"
	        for port in $(seq 1 65535); do
        	        timeout 1 bash -c "echo > /dev/tcp/$ip/$port" 2>/dev/null && echo -e "[!] PORT ${red}$port${end} - OPEN" &
	        done; wait
		tput cnorm; exit 0
	fi
else
	helpPanel
fi
