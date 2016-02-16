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
ADDUSER=$5
CREATE_PW=${6:-"${ADDUSER}"}
TIMEOUT=${7:-"15"}
#Sanity checks
returns_the_result (){
     case $? in
     2) 
       echo "2,,User name password mistake,or no permissions.";exit 2
     ;;
     3)
       echo "3,,SSH Service is not open "; exit 3
     ;;
     4)
        echo "4,,Users already exist"; exit 4
     ;;
     6) 
        echo  "6,,No authority"; exit 6
     ;;
esac
}
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
			\# {send \"env LANG=C useradd -m -s /bin/bash ${ADDUSER}\n\"}}

		expect	{
			already\ exists {exit 4}
			\# {send \"env LANG=C passwd ${ADDUSER}\n\"}}
		expect {
			Enter\ new\ UNIX\ password {send \"${CREATE_PW}\n\" ;exp_continue}
			Retype\ new\ UNIX\ password {send \"${CREATE_PW}\n\"}}
               expect  \# {send \"exit\n\"}
">/dev/null
returns_the_result
#END
