#!/bin/bash
#-------------------------------------------------------------------
#FileName:      hs_change_anonymous.sh
#Revision:      1.1
#Date:          2015/08/24
#Author:        Bruce
#Description:   Switch the user access to the script
#Notes:         Parameter Settings please refer to the document
#-------------------------------------------------------------------

#Global Declarations
IP=$1
PW=$2
CH_PW=$3
RI_PW=$4
TIMEOUT=${5:-'15'}

returns_the_result ()
        case $? in
        2)
                echo "2,,wrong password.";exit 2
        ;;
        3)
                echo "3,,The login form mistake." ;exit 3
esac

#Sanity checks
ping -c 3 ${IP} > /dev/null
if [ $? -ge 1 ] ;then
        echo "1,,WARNNING:The network impassability"
        exit 1
fi

expect -c " 
	set timeout $TIMEOUT
        match_max 100000
	spawn telnet ${IP} 
	expect {
		sername {exit 3}
		assword {send \"${PW}\n\"}}
	expect { 
		\"he*assword*is*invali*\" {exit 2}
		\> {send sys\n}}
	expect {
		Error {
			expect \> {send super\n}
			exp_continue}
		Password {send \"${RI_PW}\n\";exp_continue}
		\> {send sys\n;exp_continue}
		\] {send aaa\n}}
	expect \] {
		send \"user-interface vty 0 4\n\"
		send \"set authentication password cipher $CH_PW\n\"
		send return\n}
	expect \> {send save\n}
	expect to\ continue {
			send y\n
			send q\n}
	expect \#
">/dev/nill
returns_the_result
#END
