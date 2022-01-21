#!/bin/bash


RED="\e[31m"
GREEN="\e[32m"
ENDCOLOR="\e[0m"
BOLD="\e[1m"

print_help(){
   # Display Help
   echo "Syntax: dnsenum.sh [-d|h|f|a|t]"
   echo "options:"
   echo "-d     Domain to query."
   echo "-h     Print this Help."
   echo "-f     File for DNS enumeration"
   echo "-s     DNS server used for quyering, defaults to resolv.conf"
   echo "-t		Max background jobs to run."
}

dns_enum(){
	host $1 $2 | grep -i -E "has address|is an"
}

while getopts "d:s:f:h:t:" flag
do
    case "${flag}" in
        d) DOMAIN=${OPTARG};;
        s) DNS=${OPTARG};;
        f) FILE=${OPTARG};;
		t) CONCURR=${OPTARG};;
		h) print_help
		   exit;;
    esac
done

# This is the concurrency limit
MAX_POOL_SIZE=$CONCURR
# This is used within the program. Do not change.
CURRENT_POOL_SIZE=0

if [ $# -lt 2 ]
then
	print_help
	exit
fi

if [ -z $DNS ]
then
	DNS=$(cat /etc/resolv.conf |grep -i '^nameserver'|head -n1|cut -d ' ' -f2)
fi

echo "======= TXT records ======="
host -t txt $DOMAIN
 
echo
echo "======= MX records ======="
host -t mx $DOMAIN
 
echo
echo "======= Name Servers ======="
NS=$(host -t ns $DOMAIN | cut -d " " -f4)
for i in $NS
do 
	echo -e "${BOLD}$i${ENDCOLOR}"
done

echo
echo "======= Attempting Zone Transfer ======="
for i in $NS
do
	ZONE=$(host -l $DOMAIN $i | grep "has address")
	if [ $? -eq 1 ]
	then
		echo -e "${RED}[-] Zone Transfer not successful on $i${ENDCOLOR}"
	else
		echo -e "${GREEN}[+] Zone Transfer successful on $i !!${ENDCOLOR}"
		host -l $DOMAIN $i
		echo -e "${GREEN}[+] ======= No NEED for Further Busting! =======${ENDCOLOR}" 
		exit 0
	fi
done
echo
echo "======= DNS Busting ======="
if [ ! -z $FILE ]
then

	if [ ! -f "$FILE" ]
	then
    	echo "File not found: $FILE"
    	exit 1
	fi

	for i in $(cat $FILE)
	do
		  # This is the blocking loop where it makes the program to wait if the job pool is full
  		while [ $CURRENT_POOL_SIZE -ge $MAX_POOL_SIZE ]; do
    		CURRENT_POOL_SIZE=$(jobs | wc -l)
  		done

		dns_enum $i.$DOMAIN $DNS &

		CURRENT_POOL_SIZE=$(jobs | wc -l)
	done
fi

wait
