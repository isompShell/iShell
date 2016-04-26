#!/bin/bash
#-----------------------------------------------------------
#Filename:	freebsd_extract_user.sh
#Revision:	1.1
#Date: 		2015/07/04
#Author:	Bruce
#Description: 	Remote modify freebsd password
#Notes: 	Please refer to the interface parameters
#------------------------------------------------------------

#Global Declarations
USER=$1
IP=$2
PW=$3
TIMEOUT=${4:-'15'}
USERFILE=/etc/passwd
U_FILE=`date +'%M%N'`
returns_the_result (){
	case $? in
	2)	
		echo "2,,User name password mistake, or no permissions.";exit 2
	;;
	3)
		echo "3,,SSH Service is not open" ;exit 3
esac
}	

#Sanity checks
#Test network connectivity
ping -c 3 ${IP} >/dev/null
if [ "$?" -ge "1" ] ;then
	echo "1,,The network impassability"
	exit 1
fi

expect -c "  
	set timeout $TIMEOUT
	match_max 100000
	spawn ssh -o StrictHostKeyChecking=no -o VerifyHostKeyDNS=no -o CheckHostIP=no $USER@$IP
	expect { 
		\"assword*or*oot@:\" {send \"${PW}\n\"}
		Connection\ refused {exit 3}}
	expect {
		\"assword*or*oot@:\" {exit 2}
		Permission\ denied {exit 2}
		\# {
			log_file ${U_FILE}
			send \"cat ${USERFILE}\n\" 
			sleep 1
			send exit\n}}
			sleep 1
	expect \#
">/dev/null
returns_the_result
sed -rn '/^([a-zA-Z0-9_]+:\*?:[0-9]+:[0-9]+)/p' ${U_FILE} |awk -F: '{print $1}'|sed ':a;N;s/\n/,/;ta;'
rm -f ${U_FILE}
#END
