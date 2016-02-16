#!/bin/bash
#-------------------------------------------------------------------
#FileName:      hs_telnet_adduser.sh
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
CH_PW=$5
RI_PW=$6
LEVEL=${7:-'1'}
TIMEOUT=${8:-'15'}
U_FILE=`date +'%M%N'`
#Returns the result
returns_the_result () {
        case $? in
        2)
                echo "2,,Login name wrong.";exit 2
        ;;
        3)
                echo "3,,User password mistake, or no permissions." ;exit 3
        ;;
        4)
                echo "4,,Loding user name does not exist." ;exit 4
        ;;
        5)
                echo "5,,Password authentication failed." ;exit 5
        ;;
	6)
		echo "6,,Connection timeout.";exit 6
esac
}

#Sanity checks
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
		\> {send \"display current-configuration | include password\n\"}}
	expect {
		Error {
			expect \> {send super\n}
			exp_continue}
		Password {send \"${RI_PW}\n\";exp_continue}
		\> {
			send \"display current-configuration | include password\n\"
			log_file ${U_FILE}
			while {1} {
			sleep .05
			expect {
				More {send \ ;continue}
				\> {send q\n}}}}}
"&>/dev/null
returns_the_result
if egrep "\<$CH_USER\>" ${U_FILE} >/dev/null ;then
rm -f ${U_FILE}
echo "7";exit 7
else
rm -f ${U_FILE}
expect -c "
        set timeout $TIMEOUT
        match_max 100000
	spawn telnet ${IP}
        expect {
		sername {send \"$USER\n\";exp_continue}
		assword {send \"${PW}\n\";exp_continue}
		\> {send \"sys\n\"}}
	expect {
		Error {
			expect \> {send super\n}
			exp_continue}
		Password {send \"${RI_PW}\n\";exp_continue}
		\> {send sys\n;exp_continue}
		\] {send aaa\n}}
	expect \] {
			send \"local-user $CH_USER password cipher $CH_PW\n\"
			send \"local-user $CH_USER privilege level ${LEVEL}\n\"
			send \"local-user $CH_USER service-type telnet\n\"
                        send return\n}
	expect \> {send save\n}
	expect continue {
                        send y\n 
                	send q\n 
			}
         expect \#
">/dev/null
fi
exit 0
#END
