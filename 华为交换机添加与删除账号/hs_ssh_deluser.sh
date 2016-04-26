#!/bin/bash
#-------------------------------------------------------------------
#FileName:      hs_ssh_deluser.sh
#Revision:      1.1
#Date:          2015/09/07
#Author:        Bruce
#Description:   Switch add user.
#Notes:        
#-------------------------------------------------------------------

#Global Declarations
USER=$1
IP=$2
PW=$3
CH_USER=$4
RI_PW=$5
TIMEOUT=${6:-'15'}
U_FILE=`date +'%M%N'`

#Sanity checks
ping -c 3 ${IP} > /dev/null
if [ $? -ge 1 ] ;then
        echo "1";exit 1
fi

expect -c " 

	set timeout $TIMEOUT
        match_max 100000
	spawn ssh -o StrictHostKeyChecking=no -o VerifyHostKeyDNS=no -o CheckHostIP=no ${USER}@${IP}
	expect {
		\"Connection refused\" {exit 6}
		\"*he*connection*is*closed*by*SH*server*\" {exit 2}
           	sername {send \"$USER\n\";exp_continue}
		assword {send \"${PW}\n\"}}
	expect {
		\"*ermission*enied\" {exit 3}
               	\"*ailed*to*send*authen-req\" {exit 4}
                \"*ocal*authentication*is*rejected\" {exit 5}
		\> {send \"sys\n\"}}
	expect {
		Error {
			expect \> {send super\n}
			exp_continue}
		Password {send \"${RI_PW}\n\";exp_continue}
		\> {send sys\n;exp_continue}
		\] {send aaa\n}}
	expect a\] {send \"undo local-user $CH_USER\n\"}
	expect {
		\"Have user*online, can not be deleted.\" {exit 8}
		\"User does not exist.\" {exit 7}
		a\] {send q\n;exp_continue}
		i\] {
			send \"undo ssh user $CH_USER\n\"
			send q\n}}
	expect \> {send save\n}
	expect continue {
                        send y\n 
                	send q\n 
			}
         expect \#
">/dev/null
#END
