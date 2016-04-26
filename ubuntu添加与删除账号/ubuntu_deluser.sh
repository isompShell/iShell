#!/bin/bash
#-----------------------------------------------------------
#Filename:	ubuntu_adduser.sh
#Revision:	1.1
#Date: 		2015/09/01
#Author:	Bruce
#Description:  	Add a user for unix
#Notes: 	
#------------------------------------------------------------

#Global Declarations
USER=$1
IP=$2
PW=$3
ROOT_PW=$4
DELUSER=$5
TIMEOUT=${6:-"15"}
#Sanity checks
#Test network connectivity
[ "${USER}" = "root" ]&& exit 5
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
                       	assword {send \"${PW}\n\"}
         	        Connection\ refused {exit 3}}
		expect {
			\"~$ \" {send su\n}
			\"Permission denied, please try again.\" {exit 2}}
		expect Password {send \"${ROOT_PW}\n\"}
		expect {
			\"su: Authentication failure\" {exit 6}
			\# {send \"env LANG=C userdel -r ${DELUSER}\n\"}}
		expect	{
			\"does not exist\" {exit 4}
              		\# {send \"exit\n\"}}
">/dev/null
#END
