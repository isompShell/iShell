#!/bin/bash
#-----------------------------------------------------------
#Filename:	freebsd_deluser.sh
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
returns_the_result (){
       case $? in
       2)
         echo "2,,User name password mistake,or no permissions.";exit 2
       ;;
       3)
         echo  "3,,SSH Service is not open" ; exit 3
       ;;
       4)
         echo  "4,,Users already exist" ; exit 4
       ;;
esac


}
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
                       	\"assword for*\" {send ${PW}\n}
         	        Connection\ refused {exit 3}}
		sleep .05
           	expect {
			\# {send \"env LANG=C rmuser -y ${DELUSER}\n\"}
			\"assword for*\" {exit 2}}
		sleep 1
		expect {
			\"rmuser: user*does not exist in the password database\" {exit 4}
			\# {send \"exit\n\"}}
">/dev/null
returns_the_result
#END
