#!/bin/bash
#-----------------------------------------------------------
#Filename:	centos_adduser.sh
#Revision:	1.1
#Date: 		2015/08/27
#Author:	Bruce
#Description:  	Del a user for unix
#Notes: 	
#------------------------------------------------------------

#Global Declarations
USER=$1
IP=$2
PW=$3
DELUSER=$4
TIMEOUT=${5:-"15"}
#Sanity checks
#Test network connectivity
ping -c 3 ${IP} >/dev/null
if [ "$?" -ge "1" ] ;then
	echo "1";exit 1
fi

#The main body

expect -c "
        set timeout ${TIMEOUT}
        match_max 100000
        spawn ssh -o StrictHostKeyChecking=no -o VerifyHostKeyDNS=no -o CheckHostIP=no $USER@$IP
                expect {
                       	assword {send ${PW}\n}
         	        Connection\ refused {exit 3}}
           	expect {
			\# {send \"env LANG=C userdel -r ${DELUSER}\n\"}
			Permission\ denied,\ please\ try\ again. {exit 2}}
		expect {
			does\ not\ exist {exit 4}
			\# {send \"exit\n\"}}
">/dev/null
#END
