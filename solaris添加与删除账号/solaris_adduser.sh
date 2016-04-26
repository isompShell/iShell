#!/bin/bash
#-----------------------------------------------------------
#Filename:	solaris_adduser.sh
#Revision:	1.1
#Date: 		2015/08/27
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
                       	assword { send ${PW}\n }
			口令 {send \"${PW}\n\"}
         	        Connection\ refused {exit 3}}
           	expect {
			\# {send \"env LANG=C useradd ${ADDUSER}\n\" }
			口令 {exit 2}
                       	assword {exit 2}}
		expect {
			\"Choose another.\" {exit 4}
			\# {send \"env LANG=C mkdir -p /export/home/${ADDUSER}\n\"}}
		expect  \# {
			send \"chown ${ADDUSER} /export/home/${ADDUSER}\n\"
			send \"env LANG=C perl -p -i -e 's#/home/${ADDUSER}#/export/home/${ADDUSER}#g' /etc/passwd\n\"}
		expect \# {send \"env LANG=C passwd ${ADDUSER}\n\"}
		expect {
			\"New Password:\" {send \"$CREATE_PW\n\";exp_continue}
			\"*6*haracters*\"  {exit 5}
			\"2 alphabetic character(s)\" {exit 6}
			\"Re-enter new Password:\" {send \"$CREATE_PW\n\"}}
               expect  \# {send \"exit\n\"}
"#>/dev/null
#END
