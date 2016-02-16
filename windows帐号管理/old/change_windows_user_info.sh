#!/bin/bash
#---------------------------------------------------------------------------------
#Filename:	change_windows_user_info.sh
#Revision:	1.0.0
#Author:	chunyunzeng@hotmail.com
#Date: 2015-10-10 09:00 CST
#Description: Change windows user password and get user list or create new account.
#---------------------------------------------------------------------------------

USER="`echo $1|awk -F':' '{print $1}'`"
TIMEOUT="`echo $1|awk -F':' '{print $2}'`"
IP=$2
PWD=$3
CHUSER=$4
CHPWD=$5
LOG_FILE="/tmp/log.`date +"%Y%m%d%S%N"`"
TMP_LIST="/tmp/tmp.list`date +"%Y%m%d%S%N"`"

if [ "${TIMEOUT}" = "" ];then
	TIMEOUT=14
fi

if [ "$1" = '-version' -o "$1" = '--version' ];then
	echo -e "version:\t1.0.0"
	exit 0
fi

rm -rf ~/.ssh/known_hosts

#change and create user info,and get user list
function execSSH() 
{
        case $1 in
                ssh)
			if [ "${USER}" = "" ];then
                        	CMD="ssh -o StrictHostKeyChecking=no ${IP}"
			else
                        	CMD="ssh -o StrictHostKeyChecking=no ${USER}@${IP}"
                        fi
			TEMP="$2"
                ;;
                scp)
                        FILE_NAME=$2
                        CMD="scp ${USER}@${IP}:"~${USER_LIST}" ${FILE_NAME}"
                ;;
        esac
	/usr/bin/env expect -c "
	set timeout ${TIMEOUT}
	spawn ${CMD}
	expect {
		\"Connection refused\" { exit 3 } 
		\"assword:\" { send \"${PWD}\r\"
			expect 	\"assword:\" { exit 4 }
		}
		\"closed\" { exit 3 }
	}
        if { ${TEMP} == 1 } {
                        	send \"net user\r\"
				send \"exit\r\"
				expect  timeout { exit 2 }
        } 
	if { ${TEMP} == 0 } {
				send \"net user ${CHUSER}\r\"
				expect {
					\"NET HELPMSG 2221\" {
						if { ${ACTION} == 0 } {
							send \"net user ${CHUSER} ${CHPWD} /add\r\"
							expect \"NET HELPMSG 2245\" { exit 6 }
							send \"exit\r\"
						}
						if { ${ACTION} == 1 } { exit 5 }
					}
					\"Yes\" {
						if { ${DEL_USER} == 1 } {
							send \"net user ${CHUSER} /del\r\"
							send \"exit\n\"
						}
						send \"net user ${CHUSER} ${CHPWD}\r\"
							expect \"NET HELPMSG 2245\" { exit 6 }
							exit 0
					}
				}	
				expect  timeout { exit 2 }
	}
	
">${LOG_FILE}
}

#check IP status and check software status
function checkIP()
{
	ping -c3 ${IP} >/dev/null 2>&1
	if [ $? != 0 ];then
		echo "1,,Network issue"
		exit 1
	fi
	which expect &>/dev/null
	[ $? = 1 ]&&echo "Please install expect package"&&exit 1
}

case $# in
	6)
		ACTION=2
		ACTION="$6"
		TEMP=0
		DEL_USER=0
		if [ "${ACTION}" != add ];then
			echo "127,,Sytanx error"
			exit 7
		fi
		if [ "${ACTION}" = 'add' ];then ACTION=0;fi
		checkIP
		execSSH ssh 0
	;;
	4)
		ACTION=2
		ACTION="$4"
		DEL_USER=0
		if [ "${ACTION}" != list ];then
			echo "5,,User ${CHUSER} not found"
			exit 5
		fi
		TEMP=1
		checkIP
		execSSH ssh 1
	;;
	5)
		ACTION=1
		TEMP=2
		DEL_USER=0
		checkIP
		if [ "$5" = 'deleteisomperuser' ];then
			DEL_USER=1
		fi
		execSSH ssh 0
	;;
	*)
		echo "Usage : "
		echo -e "\tList system user"
		echo -e "\t\tbash $0 'Administrator:14' 192.168.1.1 'Passw0rd' list\n"
		echo -e "\tChange user password"
		echo -e "\t\tbash $0 'Administrator:14' 192.168.1.1 'Passw0rd' zcy 'newPassw0rd'\n"
		echo -e "\tdel system user"
		echo -e "\t\tbash $0 'Administrator:14' 192.168.1.1 'Passw0rd' zcy deleteisomperuser\n"
		echo -e "\tAdd new system user account"
		echo -e "\t\tbash $0 'Administrator:14' 192.168.1.1 'Passw0rd' zcy 'newPassw0rd' add"
		exit 1
	;;
esac


case $? in
	2)
		echo "2,,Firewall issue"
		exit 2
	;;
	3)
		echo "3,,SSH service has not open"
		exit 3
	;;
	4)
		echo "4,,Password is incorrect"
		exit 4
	;;
	5)
		echo "5,,User ${CHUSER} not found"
		exit 5
	;;
	6)
		echo "6,,Password is so easy"
		exit 6
	;;
	0)
		if [ $# -eq 5 -a ${DEL_USER} = 0 ];then
			echo "0,,${CHUSER} Password has changed"
			exit 0
		elif [ $# -eq 6 ];then
			echo "0,,${CHUSER} has add"
			exit 0
		elif [ $# -eq 5 -a ${DEL_USER} = 1 ];then
			echo "0,,${CHUSER} has deleted"
			exit 0
		fi
	;;
	*)
		echo "127,,Sytanx error"
		exit 127
	;;
esac
#output user list
if [ "${ACTION}" = 'list' -a $# -eq 4 ];then 
	ACTION=2
	TEMP=2
	DEL_USER=0
	UPLINE=`cat -n ${LOG_FILE}|grep "\-\-\-"|awk '{print $1}'`
	cat ${LOG_FILE}|head -n`expr $(cat ${LOG_FILE} |wc -l) - 4`|sed -r '1,'${UPLINE}'d;s/\r//g' >${TMP_LIST}
        for USERNAME in `cat ${TMP_LIST}`
	do
		echo -n "${USERNAME},"
	done
	rm -rf ${TMP_LIST} >/dev/null 2>&1
fi
rm -rf ${LOG_FILE} >/dev/null 2>&1
