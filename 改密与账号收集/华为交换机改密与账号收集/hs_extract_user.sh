#!/bin/bash
#-------------------------------------------------------------------
#FileName:      hs_extract_user.sh 
#Revision:      1.1
#Date:          2015/08/28
#Author:        Bruce
#Description:   Switch the user access to the script
#Notes:         Parameter Settings please refer to the document
#-------------------------------------------------------------------

#Global Declarations
LODING_TYPE=$1
USER=$4
IP=$2
PW=$3
RI_PW=$5
TIMEOUT=${6:-'15'}
U_FILE=`date +'%M%N'`
#Returns the result
returns_the_result () {
        case $? in
        3)
                echo "3,,Login name wrong.";exit 3
        ;;
        4)
                echo "4,,User password mistake, or no permissions." ;exit 4
        ;;
        5)
                echo "5,,Loding user name does not exist." ;exit 5
        ;;
        6)
                echo "6,,Password authentication failed." ;exit 6
        ;;
	7)
		echo "7,,Connection timeout.";exit 7
esac
}

#Sanity checks
ping -c 3 ${IP} > /dev/null
if [ $? -ge 1 ] ;then
        echo "1,,WARNNING:The network impassability"
        exit 1
fi

case ${LODING_TYPE} in 
	ssh)
	CMD="${LODING_TYPE} -o StrictHostKeyChecking=no -o VerifyHostKeyDNS=no -o CheckHostIP=no ${USER}@${IP}"
	;;
	telnet)
	CMD="${LODING_TYPE} ${IP}"
	;;
	anonymous)
	echo "\$anonymous";exit 0
	;;
	*)
	echo "2,,Parameter input errors." 
	exit 2
esac

expect -c " 

	set timeout $TIMEOUT
        match_max 100000
	spawn ${CMD}
	expect {
		\"Connection refused\" {exit 7}
		\"*he*connection*is*closed*by*SH*server*\" {exit 3}
           	sername {send \"$USER\n\";exp_continue}
		assword {send \"${PW}\n\"}}
	expect {
		\"*ermission*enied\" {exit 4}
               	\"*ailed*to*send*authen-req\" {exit 5}
                \"*ocal*authentication*is*rejected\" {exit 6}
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
				More {send \ ;exp_continue}
				\> {send q\n}}}}}
	expect \#
"&>/dev/null
returns_the_result
cat ${U_FILE} |egrep "^ ?local" |sed 's/-/ /g'|awk '{print $3}'|sort|uniq|sed ':a;N;s/\n/,/;ta;'
rm -f ${U_FILE}
exit 0
#END
