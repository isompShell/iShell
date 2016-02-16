#!/bin/bash
#---------------------------------------------------------------------------------
#Filename:	change_h3c_user_info.sh
#Revision:	1.0.0
#Author:	chunyunzeng@hotmail.com
#Date: 2015-08-20 12:00 CST
#Description: Change H3C user password and get user list or create new account.
#---------------------------------------------------------------------------------

PROTOCOL="`echo $1|awk -F':' '{print $1}'`"
TIMEOUT="`echo $1|awk -F':' '{print $2}'`"
USER="$2"
IP="$3"
PWD="$4"
ACTION="$5"
CHPWD="$6"
CHUSER="$7"
LOG_FILE="/tmp/log.`date +"%Y%m%d%S%N"`"
USER_LIST="/user.list`date +"%Y%m%d%S%N"`"

if [ "${TIMEOUT}" = "" ];then
	TIMEOUT=9
fi

if [ "$1" = '-version' -o "$1" = '--version' ];then
	echo -e "version:\t1.0.0"
	exit 0
fi

rm -rf ~/.ssh/known_hosts
rm -rf ${LOG_FILE}

which telnet >/dev/null 2>&1
if [ $? -ne 0 ];then
	echo "127,,Sytanx error"
	exit 127
fi
	

function changePassword()
{
	if [ -e "${LOG_FILE}" ];then
		USERLIST=1
		for i in `cat ${LOG_FILE}|grep -i 'local-user'|awk '{print $2}'|sed 's/\\r//g'`
		do
        		if [ "${i}" = "${CHUSER}" ];then
                		USER_INFO=`cat ${LOG_FILE}|grep -i 'local-user'|sed -n ''${USERLIST}'p'`
                		CHUSER=`echo $USER_INFO|awk '{print $2}'`
                		STATUS='cipher'
                		case ${STATUS} in
                        		simple)
                                		CHINFO="local-user ${CHUSER} password simple ${NEWPWD}"
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
                        		cipher)
                                		CHINFO="password cipher ${NEWPWD}"
                        		;;
                		esac
                		break
        		fi
        		let USERLIST++
        		sleep 1
		done
		if [ "${USER}" = "" ];then
			CHVTY="`cat ${LOG_FILE}|grep -i 'user-interface vty'`"
			CHINFO="set authentication password `cat ${LOG_FILE}|grep -A1 'user-interface vty'|tail -n1|awk '{print $4}'` ${NEWPWD}"
		fi
	fi
}

function execSSH() 
{
        case $1 in
                ssh)
			if [ "${USER}" = "" ];then
                        	CMD="ssh -o StrictHostKeyChecking=no -o VerifyHostKeyDNS=no -o CheckHostIP=no ${IP}"
			else
                        	CMD="ssh -o StrictHostKeyChecking=no -o VerifyHostKeyDNS=no -o CheckHostIP=no ${USER}@${IP}"
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
		timeout	{
			send_user \"\nFirewall issue\n\";exit 2
		}
		\"Connection refused\" {
			send_user \"\n${PROTOCOL} service has not open\n\";exit 3
		}
		\"sername:\" {
			send \"${USER}\r\"
		}
		\"assword:\" {
			send \"${PWD}\r\"
		}
	}	
	expect \"assword:\" {
		send \"${PWD}\r\"
	}
	expect { 
		\"assword\" {
			send_user \"\nPassword is incorrect\n\";exit 4
		}
		\"sername:\" {
			send_user \"\nPassword is incorrect\n\";exit 4
		}
	}
	if { ${TEMP} == 0 } {
		expect	\"\>\" {
				send \"super\r\"
				expect \"assword:\" {
					send \"${CHPWD}\r\"
				}
					send \"system-view\r\"
					expect	"\]" {
						send \"display current-configuration\r\"
						while {1} {
							sleep 0.5
							expect "More" { send \ ;continue }
							sleep 0.5
							expect "\]" { break
							}
						}
						send \"return\r\"
						send \"quit\r\" 
					}
					expect 	\"assword:\" {
						send_user \"\nPassword is incorrect\n\";exit 4
						}
				}
	}
	if { ${TEMP} == 1 } {
		expect	\"\>\" {
				send \"super\r\"
				expect \"assword:\" {
					send \"${CHPWD}\r\"
				}
					send \"system-view\r\"
					expect	"\]" {
						send \"local-user ${CHUSER}\r\"
					}
					expect \"luser\" {
						send \"${CHINFO}\r\"
						expect \"Error:\" {
							send_user \"\nPassword is too simpler\n\";exit 6
						}
						send \"return\r\"
						send \"save\r\"
						send \"Y\r\"
						send \"\r\"
						send \"Y\r\"
						send \"quit\r\"
					}
					
					expect 	\"assword:\" {
						send_user \"\nPassword is incorrect\n\";exit 4
					}
		}
	}
	if { ${TEMP} == 3 } {
		expect	\"\>\" {
				send \"super\r\"
				expect \"assword:\" {
					send \"${CHPWD}\r\"
				}
					send \"system-view\r\"
					expect	"\]" {
						send \"${CHVTY}\r\"
						send \"${CHINFO}\r\"
						expect \"Error:\" {
							send_user \"\nPassword is too simpler\n\";exit 6
						}
						send \"return\r\"
						send \"save\r\"
						send \"Y\r\"
						send \"\r\"
						send \"Y\r\"
						send \"quit\r\"
					}
					
					expect 	\"assword:\" {
						send_user \"\nPassword is incorrect\n\";exit 4
					}
		}
	}
	">${LOG_FILE}
}

#check IP status and check software status
function checkIP()
{
	ping -c 3 ${IP} >/dev/null
	if [ $? != 0 ];then
		echo "1,,Network issue"
		exit 1
	fi
	which expect &>/dev/null
	[ $? != 0 ]&&echo -e "\e[0;31mPlease install expect package\e[0m"&&exit 1
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
				if [ "${USER}" = "" ];then
					execSSH ssh 3
				else
					execSSH ssh 1
				fi
				TEST=$?
				checkResult
				rm -rf ${LOG_FILE} >/dev/null 2>&1
				rm -rf ${USER_LIST} >/dev/null 2>&1
			else
				echo "5,,User ${CHUSER} not found"
				exit 5
			fi
		elif [ "${PROTOCOL}" = telnet -a "$7" = 'ModifyPassword' ];then
			execSSH telnet 0
			TEST=$?
			[ "${TEST}" != 0 ]&&checkResult
				CHUSER="${ACTION}"
				NEWPWD="${CHPWD}"
				changePassword
			if [ "${CHINFO}" != "" ];then
				if [ "${USER}" = "" ];then
					execSSH telnet 3
				else
					execSSH telnet 1
				fi
				TEST=$?
				checkResult
				rm -rf ${LOG_FILE} >/dev/null 2>&1
				rm -rf ${USER_LIST} >/dev/null 2>&1
			else
				echo "5,,User ${CHUSER} not found"
				exit 5
			fi
		elif [ "${PROTOCOL}" = ssh ];then
			execSSH ssh 0
			TEST=$?
			[ "${TEST}" != 0 ]&&checkResult
				NEWPWD="${ACTION}"
				changePassword
			if [ "${CHINFO}" != "" ];then
				if [ "${USER}" = "" ];then
					execSSH ssh 3
				else
					execSSH ssh 1
				fi
				TEST=$?
				checkResult
				rm -rf ${LOG_FILE} >/dev/null 2>&1
				rm -rf ${USER_LIST} >/dev/null 2>&1
			else
				echo "5,,User ${CHUSER} not found"
				exit 5
			fi
		elif [ "${PROTOCOL}" = telnet ];then
			execSSH telnet 0
			TEST=$?
			[ "${TEST}" != 0 ]&&checkResult
				NEWPWD="${ACTION}"
				changePassword
			if [ "${CHINFO}" != "" ];then
				if [ "${USER}" = "" ];then
					execSSH telnet 3
				else
					execSSH telnet 1
				fi
				TEST=$?
				checkResult
				rm -rf ${LOG_FILE} >/dev/null 2>&1
				rm -rf ${USER_LIST} >/dev/null 2>&1
			else
				echo "5,,User ${CHUSER} not found"
				exit 5
			fi
		else
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
			for i in `cat ${LOG_FILE}|grep -i 'local-user'|awk '{print $2}'|sed 's/\\r//g'`
				do
					echo -n "${i},"
				done
				rm -rf ${LOG_FILE} >/dev/null 2>&1
				rm -rf ${USER_LIST} >/dev/null 2>&1
		elif [ "${ACTION}" = 'list' -a "${PROTOCOL}" = telnet ];then
			execSSH telnet 0
			TEST=$?
			[ "${TEST}" != 0 ]&&checkResult
			for i in `cat ${LOG_FILE}|grep -i 'local-user'|awk '{print $2}'|sed 's/\\r//g'`
				do 
					echo -n "${i},"
				done
				rm -rf ${LOG_FILE} >/dev/null 2>&1
				rm -rf ${USER_LIST} >/dev/null 2>&1
		else
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
			for i in `cat ${LOG_FILE}|grep -i 'local-user'|awk '{print $2}'|sed 's/\\r//g'`
				do
					echo -n "$i,"
				done
				rm -rf ${LOG_FILE} >/dev/null 2>&1
				rm -rf ${USER_LIST} >/dev/null 2>&1
		elif [ "${ACTION}" = 'list' -a "${PROTOCOL}" = telnet ];then
			execSSH telnet 0
			TEST=$?
			[ "${TEST}" != 0 ]&&checkResult
			for i in `cat ${LOG_FILE}|grep -i 'local-user'|awk '{print $2}'|sed 's/\\r//g'`
				do 
					echo -n "$i,"
				done
				rm -rf ${LOG_FILE} >/dev/null 2>&1
				rm -rf ${USER_LIST} >/dev/null 2>&1
		else
			echo "127,,Sytanx error"
			exit 127
		fi
	;;	
	*)
		echo "Usage : "
		echo -e "\tList system user"
		echo -e "\t\tbash $0 ssh|telnet Adminuser 192.168.1.1 adminpwd list enablepwd\n"
		echo -e "\t\tbash $0 ssh|telnet Adminuser 192.168.1.1 adminpwd list\n"
		echo -e "\tChange user password"
		echo -e "\t\tbash $0 ssh|telnet Adminuser 192.168.1.1 adminpwd userpwd enablepwd user \n"
		echo -e "\t\tbash $0 ssh|telnet Adminuser 192.168.1.1 adminpwd user userpwd ModifyPassword \n"
		exit 127
	;;
esac
