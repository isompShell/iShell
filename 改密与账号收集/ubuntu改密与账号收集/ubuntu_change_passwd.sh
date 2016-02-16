#!/bin/bash
#-----------------------------------------------------------
#Filename:	ubuntu_change_password.sh
#Revision:	1.1
#Date: 		2015/07/02
#Author:	Bruce
#Description: 	Remote modify ubuntu password
#Notes: 	Please refer to the interface parameters
#------------------------------------------------------------

#Global Declarations
USER=$1
IP=$2
PW=$3
ROOT_PW=$4
CHE_USER=$5
CHE_PW=$6
TIMEOUT=${7:-'15'}
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
[ "${USER}" = "root" ]&& exit 5
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
		assword {send \"${PW}\n\"}
		Connection\ refused {exit 3}}
	expect {
		Permission\ denied {exit 2}
		\"~$ \" {
			log_file ${U_FILE}
                      	send \"cat ${USERFILE}\n\"}
			\"~$ \" {send \"exit\n\"}}
	expect \"~$ \"
">/dev/null
returns_the_result 

#The main body
#Determine whether a user exists
if egrep "^$CHE_USER:" ${U_FILE} &> /dev/null ; then
expect -c "  
	set timeout $TIMEOUT
	match_max 100000
	spawn ssh -o StrictHostKeyChecking=no -o VerifyHostKeyDNS=no -o CheckHostIP=no $USER@$IP
		expect assword {send \"${PW}\n\"} 
		expect \"~$ \" {send su\n}
		expect Password {send \"${ROOT_PW}\n\"}
		expect {
			\"su: Authentication failure\" {exit 6}
			\# {send \"env LANG=C passwd $CHE_USER\n\"}}
		expect {
			\"*assword*or*${USER}:*\" {send \"$PW\n\";exp_continue}
			\"*nter*ew*NIX*assword:*\" {send \"$CHE_PW\n\";exp_continue}
			\"*etype*ew*NIX*assword:*\" {send \"$CHE_PW\n\"}}
		expect	\# {send \"exit\n\"}
	expect \"~$ \"
">/dev/null
rm -f ${U_FILE}
else 
	rm -f ${U_FILE}
	echo "4,,The user does not exist.";exit 4
fi
#END
