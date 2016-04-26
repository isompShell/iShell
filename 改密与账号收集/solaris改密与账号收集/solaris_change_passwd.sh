#!/bin/bash
#-----------------------------------------------------------
#Filename:	solaris_change_password.sh
#Revision:	1.1
#Date: 		2015/07/04
#Author:	Bruce
#Description: 	Remote modify solaris password
#Notes: 	Please refer to the interface parameters
#------------------------------------------------------------

#Global Declarations
USER=$1
IP=$2
PW=$3
CHE_USER=$4
CHE_PW=$5
TIMEOUT=${6:-'15'}
USERFILE=/etc/passwd
U_FILE=`date '+%M%N'`

returns_the_result (){
	case $? in
	2)	
		echo "2,,User name password mistake, or no permissions.";exit 2
	;;
	3)
		echo "3,,SSH Service is not open" ;exit 3
	;;
	5)
		echo "5,,Password too short - must be at least 6 characters.";exit 5
	;;
	6)
		echo "6,,passwd: The password must contain at least 1 numeric or special character(s).";exit 6
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
        set timeout $IIMEOUT
        match_max 100000
        spawn ssh -o StrictHostKeyChecking=no -o VerifyHostKeyDNS=no -o CheckHostIP=no $USER@$IP
        expect { 
		assword {send \"${PW}\n\"}
		口令 {send \"${PW}\n\"}
                Connection\ refused {exit 3}}
        expect {
		口令 {exit 2}
		Permission\ denied {exit 2}
             	\# {
                        log_file ${U_FILE}
                        send \"cat ${USERFILE}\n\"
               		send exit\n}}
	expect \#
"> /dev/null
returns_the_result 

#The main body
#Determine whether a user exists.
if egrep "^$CHE_USER:" ${U_FILE} &> /dev/null ; then
expect -c "  
	set timeout $TIMEOUT
	match_max 100000
	spawn ssh -o StrictHostKeyChecking=no -o VerifyHostKeyDNS=no -o CheckHostIP=no $USER@$IP
	expect { 
		assword {send \"${PW}\n\"}
		口令 {send \"${PW}\n\"}}
		expect \# {send \"env LANG=C  passwd $CHE_USER\n\"}
		expect {
			\"*ew*assword: \" {send \"$CHE_PW\n\";exp_continue}
			\"*6*haracters*\"  {exit 5}
			\"*assw*he*assword*ontain*east*1*umeric*pecial*haracter\" {exit 6}
			\"*enter*ew*assword: \" {send \"$CHE_PW\n\"}
			\# {send exit\n}}
	expect \#
">/dev/null
returns_the_result
rm -f ${U_FILE}
else 
	rm -f ${U_FILE}
	echo "4,,The user does not exist.";exit 4
fi
#END
