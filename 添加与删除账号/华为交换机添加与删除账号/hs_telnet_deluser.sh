#!/bin/bash
#-------------------------------------------------------------------
#FileName:      hs_telnet_deluser.sh
#Revision:      1.1
#Date:          2015/09/08
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
returns_the_result (){
         case $? in
       2) 
          echo "2,,Login name wrong.";exit 2
       ;;
       3)
          echo "3,,User password mistake, or no permissions." ; exit 3
       ;;
       4) 
          echo "4,,Loding user name does not exist."; exit 4
       ;;
       5) 
          echo "5,,Password authentication failed." ; exit 5
       ;;
       6)
          echo "6,,Connection timeout.";exit 6
       ;;
       7)
          echo "7,,Users do not exist.";exit 7
       ;;
       8)
          echo "8,,User has logged."; exit 8
       ;;
esac
     




}
ping -c 3 ${IP} > /dev/null
if [ $? -ge 1 ] ;then
        echo "1";exit 1
fi

expect -c " 

	set timeout $TIMEOUT
        match_max 100000
	spawn telnet ${IP}
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
	expect \] {send \"undo local-user $CH_USER\n\"}
	expect {
		\"Have user*online, can not be deleted.\" {exit 8}
		\"User does not exist.\" {exit 7}
		a\] {send return\n}}
	expect \> {send save\n}
	expect continue {
                        send y\n 
                	send q\n 
			}
         expect \#
">/dev/null
returns_the_result
#END
