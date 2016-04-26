#!/bin/bash
#---------------------------------------------------------------------------------
#Filename:	change_cisco_user_info.sh
#Revision:	1.0.0
#Author:	chunyunzeng@hotmail.com
#Date: 2015-08-25 09:00 CST
#Description: Change cisco user password and get user list or create new account.
#---------------------------------------------------------------------------------

PROTOCOL="`echo $1|awk -F':' '{print $1}'`"
TIMEOUT="`echo $1|awk -F':' '{print $2}'`"
USER="$2"
IP="$3"
PWD="$4"
ACTION="$5"
CHPWD="$6"
CHUSER="$7"
NEWUSER="$5"
NEW_USER_PWD="$6"
ENPWD="$7"
USER_LEVEL="${8:-1}"
LOG_FILE="/tmp/log.`date +"%Y%m%d%S%N"`"

if [ "${TIMEOUT}" = "" ];then
	TIMEOUT=2
fi

if [ "$1" = '-version' -o "$1" = '--version' ];then
	echo -e "version:\t1.0.0"
	exit 0
fi


which telnet >/dev/null 2>&1
if [ $? -ne 0 ];then
        echo "127,,Sytanx error"
        exit 127
fi

rm -rf ~/.ssh/known_hosts

function changePassword()
{
	if [ -e "${LOG_FILE}" ];then
		USERLIST=1
		for USERNAME in `cat ${LOG_FILE} |egrep '^username'|cut -d' ' -f2`
		do
        		if [ "${USERNAME}" = "${CHUSER}" ];then
                		USER_INFO=`cat ${LOG_FILE}|egrep '^username'|sed -n ''${USERLIST}'p'`
                		CHUSER=`echo $USER_INFO|awk '{print $2}'`
                		STATUS=`echo $USER_INFO|awk '{print $3}'`
                		case ${STATUS} in
                        		secret)
                                		CHINFO="username ${CHUSER} secret ${NEWPWD}"
                        		;;
                        		privilege)
                                		STATUS=`echo $USER_INFO|awk '{print $5}'`
                                		LEVEL=`echo $USER_INFO|awk '{print $4}'`
                                		if [ "${STATUS}" != "" ];then
                                        		case ${STATUS} in
                                                		secret)
                                                        		CHINFO="username ${CHUSER} privilege ${LEVEL} secret ${NEWPWD}"
                                                		;;
                                                		password)
                                                        		CHINFO="username ${CHUSER} privilege ${LEVEL} password ${NEWPWD}"
                                                		;;
                                        		esac
                                		else
                                        		CHINFO="username ${CHUSER} privilege ${LEVEL}"
                                		fi
                        		;;
                        		password)
                                		CHINFO="username ${CHUSER} password ${NEWPWD}"
                        		;;
                		esac
                		break
        		fi
        		let USERLIST++
		done
		if [ "${USER}" = "" -a "${CHINFO}" = "" ];then
			CHVTY="`cat ${LOG_FILE}|grep -i 'line vty'`"
			CHINFO="password 0 ${NEWPWD}"
		fi
	fi
}

function execSSH() 
{
        case $1 in
                ssh)
			if [ "${USER}" = "" ];then
                        	CMD="ssh -o StrictHostKeyChecking=no -o CheckHostIP=no  ${IP}"
			else
                        	CMD="ssh -o StrictHostKeyChecking=no -o CheckHostIP=no ${USER}@${IP}"
			fi
                        TEMP="$2"
                ;;
                telnet)
                        
                        CMD="telnet ${IP}"
                        TEMP="$2"
                ;;
        esac
	/usr/bin/env expect -c "
	set timeout ${TIMEOUT}
	spawn ${CMD}
	expect {
		failed { exit 7 }
		\"Connection refused\" { exit 3 }
		\"sername:\" { send \"${USER}\r\"
			expect	\"assword:\" { send \"${PWD}\r\"
					expect \"sername:\" { exit 4 }
			}
		}
		\"assword:\" { send \"${PWD}\r\"
			expect \"assword\" { exit 4 }
		}
	}	
	if { ${TEMP} == 0 } {
				send \"enable\r\"
				expect \"assword:\" { send \"${CHPWD}\r\"
						expect 	\"assword:\" { exit 4 } }
				send \"show running-config | include username | vty\r\"
				send \"exit\r\"
				expect timeout	{ exit 2 }
	}
	if { ${TEMP} == 1 } {
				send \"enable\r\"
				expect \"assword:\" { send \"${CHPWD}\r\"
						expect 	\"assword:\" { exit 4 } }
				send \"configure terminal\r\"
				send \"${CHINFO}\r\"
				send \"do write\r\"
				send \"end\r\"
				send \"exit\r\"
				expect timeout	{ exit 2 }
	}
	if { ${TEMP} == 3 } {
				send \"enable\r\"
				expect \"assword:\" { send \"${CHPWD}\r\"
						expect 	\"assword:\" { exit 4 } }
				send \"configure terminal\r\"
				send \"${CHVTY}\r\"
				send \"${CHINFO}\r\"
				send \"do write\r\"
				send \"end\r\"
				send \"exit\r\"
				expect timeout	{ exit 2 }
	}
	if { ${TEMP} == 4 } {
				send \"enable\r\"
				expect \"assword:\" { send \"${ENPWD}\r\"
						expect 	\"assword:\" { exit 4 } }
				send \"configure terminal\r\"
                		send \"username ${NEWUSER} privilege ${USER_LEVEL} secret 0 ${NEW_USER_PWD}\r\"
				send \"do write\r\"
				send \"end\r\"
				send \"exit\r\"
				expect timeout	{ exit 2 }
	}
	if { ${TEMP} == 5 } {
				send \"enable\r\"
				expect \"assword:\" { send \"${ENPWD}\r\"
						expect 	\"assword:\" { exit 4 } }
				send \"configure terminal\r\"
                		send \"no username ${NEWUSER} \r\"
				send \"do write\r\"
				send \"end\r\"
				send \"exit\r\"
				expect timeout	{ exit 2 }
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
	[ $? != 0 ]&&echo "Please install expect package"&&exit 1
}

function checkResult()
{
	case $TEST in
		2)
			echo "2,,Firewall issue"
			exit 2
		;;
		3)
			echo "3,,${PROTOCOL} service has not open"
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
		7)
			echo "7,,SSH key failed"
		;;
		0)
			echo "Successed"
			exit 0
		;;
		*)
			echo "127,,Sytanx error"
			exit 127
		;;
	esac
}
case $# in
	9)
		TEMP=2
		checkIP
                if [ "$PROTOCOL" = ssh ];then
                        execSSH  ssh 5
                        TEST=$?
			rm -rf ${LOG_FILE} >/dev/null 2>&1
                        checkResult
                elif [ "$PROTOCOL" = 'telnet' ];then
                        execSSH  telnet 5
                        TEST=$?
			rm -rf ${LOG_FILE} >/dev/null 2>&1
                        checkResult
                fi
        ;;
	8)
		TEMP=2
		checkIP
                if [ "$PROTOCOL" = ssh ];then
                        execSSH  ssh 4
                        TEST=$?
			rm -rf ${LOG_FILE} >/dev/null 2>&1
                        checkResult
                elif [ "$PROTOCOL" = 'telnet' ];then
                        execSSH  telnet 4
                        TEST=$?
			rm -rf ${LOG_FILE} >/dev/null 2>&1
                        checkResult
                fi
        ;;
	7)
		TEMP=2
		checkIP
		if [ "${PROTOCOL}" = ssh -a "$7" = 'ModifyPassword' ];then
			execSSH ssh 0
			TEST=$?
			[ "${TEST}" != 0 ]&&checkResult
				CHUSER="${ACTION}"
				NEWPWD="${CHPWD}"
				changePassword
			if [ "${CHINFO}" != "" ];then
				if [ "${USER}" = "" -a "${NEWUSER}" = "" ];then
					execSSH ssh 3
				else
					execSSH ssh 1
				fi
				TEST=$?
				rm -rf ${LOG_FILE} >/dev/null 2>&1
				checkResult
			else
				echo "5,,${CHUSER} not found"
			fi
		elif [ "${PROTOCOL}" = telnet -a "$7" = 'ModifyPassword' ];then
			execSSH telnet 0
			TEST=$?
			[ "${TEST}" != 0 ]&&checkResult
				CHUSER="${ACTION}"
				NEWPWD="${CHPWD}"
				changePassword
			if [ "${CHINFO}" != "" ];then
				if [ "${USER}" = "" -a "${NEWUSER}" = "" ];then
					execSSH telnet 3
				else
					execSSH telnet 1
				fi
				TEST=$?
				rm -rf ${LOG_FILE} >/dev/null 2>&1
				checkResult
			else
				echo "5,,${CHUSER} not found"
			fi
		elif [ "${PROTOCOL}" = ssh ];then
			execSSH ssh 0
			TEST=$?
			[ "${TEST}" != 0 ]&&checkResult
				NEWPWD="${ACTION}"
				changePassword
			if [ "${CHINFO}" != "" ];then
				if [ "${USER}" = "" -a "${CHUSER}" = "" ];then
					execSSH ssh 3
				else
					execSSH ssh 1
				fi
				TEST=$?
				rm -rf ${LOG_FILE} >/dev/null 2>&1
				checkResult
			else
				echo "5,,${CHUSER} not found"
			fi
		elif [ "${PROTOCOL}" = telnet ];then
			execSSH telnet 0
			TEST=$?
			[ "${TEST}" != 0 ]&&checkResult
				NEWPWD="${ACTION}"
				changePassword
			if [ "${CHINFO}" != "" ];then
				if [ "${USER}" = "" -a "${CHUSER}" = "" ];then
					execSSH telnet 3
				else
					execSSH telnet 1
				fi
				TEST=$?
				rm -rf ${LOG_FILE} >/dev/null 2>&1
				checkResult
			else
				echo "5,,${CHUSER} not found"
			fi
		else
				rm -rf ${LOG_FILE} >/dev/null 2>&1
			echo "127,,Sytanx error"
			exit 127
		fi
	;;
	6)
		TEMP=2
		checkIP
		if [ "${ACTION}" = 'list' -a "${PROTOCOL}" = ssh ];then
			execSSH ssh 0
			TEST=$?
			[ "${TEST}" != 0 ]&&checkResult
			cat ${LOG_FILE} |egrep '^username'|while read username
			do
				USER=`echo ${username}|cut -d' ' -f2`
				echo -n "${USER},"
			done
		elif [ "${ACTION}" = 'list' -a "${PROTOCOL}" = telnet ];then
			execSSH telnet 0
			TEST=$?
			[ "${TEST}" != 0 ]&&checkResult
			cat ${LOG_FILE} |egrep '^username'|while read username
			do
				USER=`echo ${username}|cut -d' ' -f2`
				echo -n "${USER},"
			done
				rm -rf ${LOG_FILE} >/dev/null 2>&1
		else
				rm -rf ${LOG_FILE} >/dev/null 2>&1
			echo "127,,Sytanx error"
			exit 127
		fi
	;;
	5)
		TEMP=2
		checkIP
		if [ "${ACTION}" = 'list' -a "${PROTOCOL}" = ssh ];then
			execSSH ssh 0
			TEST=$?
			[ "${TEST}" != 0 ]&&checkResult
			cat ${LOG_FILE} |egrep '^username'|while read username
			do
				USER=`echo ${username}|cut -d' ' -f2`
				echo -n "${USER},"
			done
		elif [ "${ACTION}" = 'list' -a "${PROTOCOL}" = telnet ];then
			execSSH telnet 0
			TEST=$?
			[ "${TEST}" != 0 ]&&checkResult
			cat ${LOG_FILE} |egrep '^username'|while read username
			do
				USER=`echo ${username}|cut -d' ' -f2`
				echo -n "${USER},"
			done
		else
			echo "127,,Sytanx error"
			exit 127
		fi
	;;	
	*)
		echo "Usage : "
		echo -e "\tList system user"
		echo -e "\t\tbash $0 'ssh:8|telnet:8' Adminuser 192.168.1.1 'adminpwd' list 'enablepwd'\n"
		echo -e "\t\tbash $0 'ssh:8|telnet:8' Adminuser 192.168.1.1 'adminpwd' list\n"
		echo -e "\tChange user password"
		echo -e "\t\tbash $0 'ssh:8|telnet:8' Adminuser 192.168.1.1 'adminpwd' 'userpwd' 'enablepwd' user \n"
		echo -e "\t\tbash $0 'ssh:8|telnet:8' Adminuser 192.168.1.1 'adminpwd' user 'userpwd' ModifyPassword \n"
		echo -e "\tAdd user"
		echo -e "\t\tbash $0 'ssh:8|telnet:8' Adminuser 192.168.1.1 'adminpwd' newuser 'newuserpwd' 'enablepwd' privilegelevel\n"
		echo -e "\tDel user"
		echo -e "\t\tbash $0 'ssh:8|telnet:8' Adminuser 192.168.1.1 'adminpwd' newuser '1' 'enablepwd' '3' '4' \n"
		exit 127
	;;
esac
rm -rf ${LOG_FILE} >/dev/null 2>&1
