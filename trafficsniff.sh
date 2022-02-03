#!/bin/bash

PACKETS=$1

#Find username and passwords in unencrypted protocols
tcpdump port http or port ftp or port smtp or port imap or port pop3 or port telnet -l -A -c $PACKETS | egrep -i -B5 'pass=|pwd=|log=|login=|user=|username=|pw=|passw=|passwd=|password=|pass:|user:|username:|password:|login:|pass|user|auth' | grep -v "User-Agent" >> passgrab.txt &

#Detectp ipv6
tcpdump -nn ip6 proto 6 -c 2 > ipv6_confirm.txt &

#Detecpt DHCP
tcpdump -v -n port 67 or 68 -c 2 > dhcp_comfirm.txt &

#Detect hosts and loudest host
tcpdump -nnn -t -c $PACKETS | cut -f 1,2,3,4 -d '.' | sort | uniq -c | sort -nr >> hosts.txt &

#Detect LLMNR
tcpdump -t port 5353 and udp -c 2 > llmnr_confirm.txt

sleep 10

#Find hostnames
IPADDR=$(grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' hosts.txt | sort | uniq)

for ip in $IPADDR
do
	host $ip | grep -v "not found" | awk -F " " '{print $NF}' >> hostnames.txt
done
