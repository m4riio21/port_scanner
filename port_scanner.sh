#!/bin/bash

# Inspired by S4vitaar (https://github.com/s4vitar)

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
}

tput civis
if [[ $# == "1" || $# == "2" ]]; then
	scan_type=$1; ip=$2
	code="none"

	timeout 1 bash -c "ping -c 1 $1" &>/dev/null
	status=$?

        if [[ "$status" == 0 ]]; then code="ok"; ip=$1; scan_type="--full-scan"; fi

	timeout 1 bash -c "ping -c 1 $2" &>/dev/null
	status=$?

	if [[ "$status" -gt 0 && $code == "none" ]]; then echo "[*] Host unreachable"; tput cnorm; exit 1; fi
	
	if [ $scan_type == "--fast-scan" ]; then
		echo -e "[*] Scanning top $(cat top_ports.txt | wc -l) ports\n"
        	for port in $(cat top_ports.txt); do
                	timeout 1 bash -c "echo > /dev/tcp/$ip/$port" 2>/dev/null && echo "[!] PORT $port - OPEN" &
        	done; wait
		tput cnorm; exit 0
	fi
	if [ $scan_type == "--full-scan" ]; then
        	echo -e "[*] Scanning full range of ports (1-65535)\n"
	        for port in $(seq 1 65535); do
        	        timeout 1 bash -c "echo > /dev/tcp/$ip/$port" 2>/dev/null && echo "[!] PORT $port - OPEN" &
	        done; wait
		tput cnorm; exit 0
	fi
else
	helpPanel
fi
