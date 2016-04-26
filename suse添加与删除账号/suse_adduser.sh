#!/bin/bash
#-----------------------------------------------------------
#Filename:	suse_adduser.sh
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
ADDUSER=$4
CREATE_PW=${5:-"${ADDUSER}"}
TIMEOUT=${6:-"15"}
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
			\# {send  \"env LANG=C useradd -m ${ADDUSER}\n\" }
			assword {exit 2}}
		expect {
			\# {send \"env LANG=C passwd ${ADDUSER}\n\"}
			already\ exists {exit 4}}
		expect {
			New\ password { send \"${CREATE_PW}\n\" ;exp_continue}
			Retype\ new\ password {send \"${CREATE_PW}\n\" }
			}
               expect  \# { send \"exit\n\" }
">/dev/null
#END
