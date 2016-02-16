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
returns_the_result (){
       case $? in
       2)
         echo "2,,User name password mistake,or no permissions.";exit 2
       ;;
       3)
         echo "3,,SSH Service is not open" ; exit 3
       ;;
       4)
          echo "4,,Users already exist" ; exit 4
       ;;
       5)
           echo "5,,Change password less than 6" ;exit 5
       ;;
       6)   
           echo "6,,At least one special character or number of the modified password.";exit 6
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
returns_the_result
#END
