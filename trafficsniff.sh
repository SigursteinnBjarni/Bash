#!/bin/bash


#trap Ctrl + c
trap no_ctrlc_bak INT TERM ERR SIGINT

if [ "$(id -u)" -ne 0 ]; then
        echo -e '\e[91m[-] This script must be run as root\e[0m' >&2
        exit 1
fi

# This is the concurrency limit
MAX_POOL_SIZE=5
# This is used within the program. Do not change.
CURRENT_POOL_SIZE=0

function no_ctrlc_bak()
{
	sleep 3 
	echo -e "[+] ===== Packet Capture Ended =====\n"

	echo -e "\033[32;5;7m[+] ===== Starting Post Proccessing =====\033[0m\n"
	
	#process hosts_raw and find uniq hosts and loudest
	cat hosts_raw.txt | cut -f 1,2,3,4 -d '.' | sort | uniq -c | sort -nr > hosts.txt

	#Find hostnames
	IPADDR=$(grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' hosts.txt | sort | uniq)

	for ip in $IPADDR
	do
		while [ $CURRENT_POOL_SIZE -ge $MAX_POOL_SIZE ]; do
    			CURRENT_POOL_SIZE=$(jobs | wc -l)
		done

        	host $ip | grep -v "not found" | awk -F " " '{print $NF}' >> hostnames.txt &
		CURRENT_POOL_SIZE=$(jobs | wc -l)
	done

	echo "[+] ===== All Done! ====="
	exit
}

echo -e "\033[31;5;7m=========== Packet Capture Started ===========\033[0m\n"
echo -e "===== Press Ctrl + c to exit =====\n"

#Find username and passwords in unencrypted protocols
tcpdump port http or port ftp or port smtp or port imap or port pop3 or port telnet or port ldap -l -A | egrep -i -B5 'pass=|pwd=|log=|login=|user=|username=|pw=|passw=|passwd=|password=|pass:|user:|username:|password:|login:|pass|user|auth' 2>/dev/null | grep -v "User-Agent" >> passgrab.txt & 

#Detectp ipv6
tcpdump -nn ip6 proto 6 -c 2 > ipv6_confirm.txt 2>/dev/null &

#Detecpt DHCP
tcpdump -v -n port 67 or 68 -c 2 > dhcp_comfirm.txt 2>/dev/null &

#Detect hosts
tcpdump -nnn -t >> hosts_raw.txt 2>/dev/null &

#Detect LLMNR
tcpdump -t port 5353 and udp -c 2 > llmnr_confirm.txt 2>/dev/null &
wait
