#!/bin/bash
#---------------------------------------------------------------------------------
#Filename:	change_windows_user_info.sh
#Revision:	2.0.0
#Author:	chunyunzeng@hotmail.com
#Date: 2015-10-21 23:00 CST
#Description: Change windows user password and get user list or create new account.
#---------------------------------------------------------------------------------

TIMEOUT="`echo $1|awk -F':' '{print $2}'`"
if [ "${TIMEOUT}" = "" ];then TIMEOUT=3;fi
IP=${2}
LOG_FILE="/tmp/`date +"%Y%m%d%S%N"`.log"
TMP_LIST="/tmp/`date +"%Y%m%d%S%N"`_list.log"


ACTION=0  #初始值

groupList="${6}" #组列表，以逗号隔开
groupList="`echo ${groupList}|sed "s#\,#\ #g"`"


adminUser=`echo $1|awk -F':' '{print $1}'`    #管理员账户
adminPwd="${3}"     #管理员密码

userName="${4}"           #普通用户
userPwd="${5}"   #用户密码

delUser="${5:-'2'}" #确认是否删除用户 0不删除  1删除 
delMsg="${6:-'2'}" #传递参数不存在是否返回成功 0返回成功 1返回用户不存在信息

addUser="${7:-'2'}"  #是否添加用户 0不添加 1添加
addGroup="${8:-'2'}" #是否添加组  0不添加  1添加

createUser='0' #用户不存在是否创建 0不创建  1创建
createGroup="${9:-'2'}" #组不存在是否创建  0不创建  1创建

localGroup=${10:-'0'} #添加本地组还是全局组 针对域环境有效  0本地组   1全局组

#check IP status and check software status
function checkIP()
{
	ping -c3 ${IP} >/dev/null 2>&1
	if [ $? != 0 ];then echo "1,,Network issue";exit 1;fi
	which expect >/dev/null 2>&1
	if [ $? != 0 ];then echo "Please install expect package";exit 127;fi
}


function return()
{
    case $? in
        1)
            echo "1,,Network issue"
            clean
            exit 1
        ;;
        2)
            echo "2,,Firewall issue"
            clean
            exit 2
        ;;
        3)
            echo "3,,SSH service has not open"
            clean
            exit 3
        ;;
        4)
            echo "4,,Password is incorrect"
            clean
            exit 4
        ;;
        5)
            echo "5,,User ${userName} not found"
            clean
            exit 5
        ;;
        6)
            echo "6,,Password is so easy"
            clean
            exit 6
        ;;
        7)
            echo "7,,Group not found"
            clean
            exit 7
        ;;
        8)
            echo "8,,No permission modify group or user"
            clean
            exit 8
        ;;
        9)
            echo "9,,Already exist group same as user"
            clean
            exit 9
        ;;
        10)
            echo "10,,Already exist user same as group"
            clean
            exit 10
        ;;
        11)
            echo "11,,Can not use local group method to add global group"
            clean
            exit 11
        ;;
        0)
                if [ "${ACTION}" != 1 ];then echo "0,,Successed";fi
        ;;
        *)
            echo "127,,Syntax error|resource error"
            clean
            exit 127
        ;;
    esac
}

function clean()
{
	[ -e "${LOG_FILE}" ]&&rm -rf ${LOG_FILE} >/dev/null 2>&1
	[ -e "${TMP_LIST}" ]&&rm -rf ${TMP_LIST} >/dev/null 2>&1
}

rm -rf ~/.ssh/known_hosts >/dev/null 2>&1

#change and create user info,and get user list
function execSSH() 
{
        case $1 in
                ssh)
			if [ "${adminUser}" = "" ];then
                        	CMD="ssh -o StrictHostKeyChecking=no ${IP}"
			else
                        	CMD="ssh -o StrictHostKeyChecking=no ${adminUser}@${IP}"
                        fi
			ACTION="$2"
                ;;
                telnet)
			CMD="telnet ${IP}"
			ACTION="$2"
                ;;
        esac
/usr/bin/env expect <<EOF
set timeout ${TIMEOUT}
spawn ${CMD}
expect { 
	timeout { exit 2 }
	"Connection refused" { exit 3 } 
	Unable  { exit 3 }
	closed { exit 3 }
	-re "sername:|login" { send "${adminUser}\r"
		expect  "assword:" { send "${adminPwd}\r"
			expect -re "sername:|login" { exit 4 }
		}
		expect -re "sername:|login" { exit 4 }
	}
	"assword:" { send "${adminPwd}\r"
		expect 	"assword:" { exit 4 }
	}
}
expect -re "~|#" { exit 127 }
if { ${ACTION} == 1 } {
	expect ">" { send "net user\r" }
	expect ">" { send "exit 0\r" }
}
if { ${ACTION} == 2 } {
	expect ">" { send "net user \"${userName}\"\r"
			expect "NET HELPMSG 2221" { exit 5 }
			expect "Yes" { send "net user \"${userName}\" ${userPwd}\r"
					expect "NET HELPMSG 2245" { exit 6 }
					expect "\ 5" { exit 8 }
					expect "*" { send " exit 0\r" }
			}
	}
}

if { ${ACTION} ==3 } {
	expect ">" { send "net user \"${userName}\"\r"
			expect "NET HELPMSG 2221" {
				if { ${delMsg} ==1 } {
					exit 5
				}
				if { ${delMsg} != 1 } {
					exit 0
				}
			}
			expect "Yes" { send "net user ${userName} /del\r"
					expect "\ 5" { exit 8 }
					expect "*" { send " exit 0\r" }
			}
	}
}


if { ${ACTION} == 4 } {
	expect ">" { send "net user \"${userName}\"\r"
			if { ${addUser} == 1 } {
				expect "NET USER" { exit 5 }
			}
			expect "NET HELPMSG 2221" { 
				if { ${addUser} == 0 } { exit 5 }
				if { ${addUser} == 1 } {
					send "net user \"${userName}\" ${userPwd} /add\r"
					expect "NET HELPMSG 2245" { exit 6 }
					expect "\ 5" { exit 8 }
					expect "\ 1379" { exit 9 }
				}
			}
			expect "Yes" {
				if { ${addUser} == 1 } {
					send "net user \"${userName}\" ${userPwd} \r"
					expect "NET HELPMSG 2245" { exit 6 }
				}
			}
	}
	if { ${addGroup} == 1 } {
		foreach group { ${groupList} } {
			expect ">" { send "net group \"\${group}\" \r"
					expect "NET HELPMSG 3515" {
						send "net localgroup \"\${group}\" \"${userName}\" /add\r"
						expect "NET HELPMSG 3783" { 
							if { ${addUser} != 0 } { exit 5 }
						}
						expect "NET LOCALGROUP" { 
							if { ${createGroup} ==1 } { send "net localgroup \"\${group}\" /add\r"
								expect "NET HELPMSG 2224" { exit 10 }
								expect "\ 5" { exit 8 }
							}
						}
						expect "\ 1376" {
							if { ${createGroup} == 0 } { exit 7 }
							if { ${createGroup} == 1 } { send "net localgroup \"\${group}\" /add\r"
								expect "NET HELPMSG 2224" { exit 10 }
								if { ${addUser} == 1 } {
									send "net localgroup \"\${group}\" \"${userName}\" /add\r"
								}
								expect "NET HELPMSG 3783" {
									if { ${addUser} != 0 } { exit 5 }
								}
								expect "\ 5" { exit 8 }
							}
						}
					}
					expect -re "NET HELPMSG 2220|---" {
						if { ${localGroup} == 0 } { 
							if { ${createGroup} == 1 } { send "net group \"\${group}\" /add\r"
								expect "NET HELPMSG 2224" { exit 10 }
								expect "\ 5" { exit 8 }
							}
							send "net group \"\${group}\" \"${userName}\" /add\r"
							expect -re "NET HELPMSG 3755|NET GROUP" {
									if { ${addUser} != 2 } { exit 5 }
							}
							expect "NET HELPMSG 2220" {
								if { ${createGroup} == 0 } { exit 7 }
							}
						}
						if { ${localGroup} == 1 } {
							send "net localgroup \"\${group}\" \"${userName}\" /add\r"
							expect -re "\ 8217|\ 1376" {
								if { ${createGroup} == 0 } { exit 7 }
								if { ${createGroup} == 1 } { send "net localgroup \"\${group}\" /add\r"
									expect "NET HELPMSG 2224" { exit 10 }
									expect "\ 5" { exit 8 }
								}
								if { ${addUser} == 1 } {
									send "net localgroup \"\${group}\" \"${userName}\" /add\r"
									expect "\ 1376" { exit 11 }
								}
								send "net localgroup \"\${group}\"\r"
								if { ${createGroup} == 1 } { expect "\ 1376" { exit 11 } }
							}
							expect "NET LOCALGROUP" {
								if { ${createGroup} == 1 } { send "net localgroup \"\${group}\" /add\r"
									expect "NET HELPMSG 2224" { exit 10 }
									expect "\ 5" { exit 8 }
								}
							}
						}
					}
			}
		}
	}
}
EOF
}

case $# in
	9|10)
		checkIP
		execSSH ssh 4 >${LOG_FILE}
		return
	;;
	6)
		checkIP
		if [ "${delUser}" = 1 ];then
			execSSH ssh 3 >${LOG_FILE}
		fi
		return
	;;
	5)
		checkIP
		execSSH ssh 2 >${LOG_FILE}
		return
	;;
	4)
		checkIP
		execSSH ssh 1 >${LOG_FILE}
		return
		if [ ! -e "${LOG_FILE}" ];then exit 127;fi
		UPLINE=`cat -n ${LOG_FILE}|grep "\-\-\-"|awk '{print $1}'`
		cat ${LOG_FILE}|head -n`expr $(cat ${LOG_FILE} |wc -l) - 3`|sed -r '1,'${UPLINE}'d;s/\r//g' >${TMP_LIST}
        	for USERNAME in `cat ${TMP_LIST}`
		do
			echo -n "${USERNAME},"
		done
	;;
	*)
		echo "Usage : "
		echo -e "\tList system user"
		echo -e "bash $0 'adminUser:4' 192.168.1.1 'adminPwd' list\n"

		echo -e "\tChange user password"
		echo -e "bash $0 'adminUser:4' 192.168.1.1 'adminPwd' 'userName' 'userPwd'\n"

		echo -e "\tdel system user"
		echo -e "bash $0 'adminUser:4' 192.168.1.1 'adminPwd' 'userName'  'confirm' 'return'\n"
		echo -e "\tconfirm set 0 ,do nothing,set 1 .will be delete the account"
		echo -e "\treturn set 0 ,do nothing,ignore error msg,if user no exist ,set 1 ,return user no found msg,if user not exist\n"

		echo -e "\tAdd system user or group"
		echo -e "bash $0 'adminUser:4' 192.168.1.1 'adminPwd' 'userName' 'userPwd' '\"group1\",\"group2\",\"group3\"' addUser addGroup createGroup\n"
		echo -e "\taddUser set 0 ,do nothing,set 1 ,create new user if not exist ,set 2,ignore error"
		echo -e "\taddGroup set 0 ,do nothing, set 1 ,add group if exist "
		echo -e "\tcreateGroup set 0 ,do nothing,set 1 ,create new group if not exist ,set 2,ignore error\n"
		exit 1
	;;
esac

clean

