#!/bin/bash

P_VERSION="0x4c92"
Package="fort-service"
new_version="1.0.1"
last_version="1.0.0"
next_version="1.0.2"
admin_dir="/var/lib/fort/"
backup_dir="${admin_dir}backup/"
backup_version="${admin_dir}${Package}/"
version_file="${backup_version}version"
datetime=`date +"%Y%m%d%N"`
backup_tar="${backup_dir}${Package}_${new_version}_new/"
web_fort="/usr/local/tomcat/webapps/fort"
local_fort="/usr/local/fort"
soft0_fort="/usr/local/soft9100"
soft1_fort="/usr/local/soft9101"
sh_fort="/usr/local/bin/sh"
log_name="forts.log"
log_file="/var/log/$log_name"


function local_system_check ()
{
SSH_PORT=`lsof -i :22`
MYSQL_PORT=`lsof -i :3306`
SSH_SERVICE=`ps -aux|grep sshd|grep -v grep`
MYSQL_SERVICE=`ps -aux|grep mysql|grep -v grep`

DSSH_PORT=`lsof -i :22 > /tmp/dssh_port.txt`
DMYSQL_PORT=`lsof -i :3306 > /tmp/dmysql_port.txt`
DSSH_SERVICE=`ps -aux|grep sshd|grep -v grep > /tmp/dssh_service.txt`
DMYSQL_SERVICE=`ps -aux|grep mysql|grep -v grep > /tmp/dmysql_service.txt`

DSSH_PORT_FILE="/tmp/dssh_port.txt"
DMYSQL_PORT_FILE="/tmp/dmysql_port.txt"
DSSH_SERVICE_FILE="/tmp/dssh_service.txt"
DMYSQL_SERVICE_FILE="/tmp/dmysql_service.txt"

echo " ------------local configuration checking now------------- "|tee -a $log_file
 echo ${SSH_PORT} >/dev/null 2>&1
if [  $? != 0 ] ;then 
echo "`date |cut -d' ' -f2-5` error[1001] 22 port no open"|tee -a $log_file
exit 1
else
echo "`date |cut -d' ' -f2-5` 22 port open"|tee -a $log_file
fi
 echo ${MYSQL_PORT} >/dev/null 2>&1
if [ $? != 0  ];then
echo "`date |cut -d' ' -f2-5` error[1002] 3306 port no open"|tee -a $log_file
exit 1
else
echo "`date |cut -d' ' -f2-5` 3306 port open"|tee -a $log_file
fi
 echo ${SSH_SERVICE} >/dev/null 2>&1
if [ $? != 0 ];then
echo "`date |cut -d' ' -f2-5` error[1003] ssh service no open"|tee -a $log_file
exit 1
else
echo "`date |cut -d' ' -f2-5` ssh service open"|tee -a $log_file
fi
 echo ${MYSQL_SERVICE} >/dev/null 2>&1
if [ $? != 0 ];then
echo "`date |cut -d' ' -f2-5` error[1004] mysql service no open"|tee -a $log_file
exit 1
else
echo "`date |cut -d' ' -f2-5` mysql service open"|tee -a $log_file
fi 
echo " ------------local configuration checking done------------- "|tee -a $log_file
}


function dual_system_check ()
{
SSH_PORT=`lsof -i :22`
MYSQL_PORT=`lsof -i :3306`
SSH_SERVICE=`ps -aux|grep sshd|grep -v grep`
MYSQL_SERVICE=`ps -aux|grep mysql|grep -v grep`

DSSH_PORT=`lsof -i :22 > /tmp/dssh_port.txt`
DMYSQL_PORT=`lsof -i :3306 > /tmp/dmysql_port.txt`
DSSH_SERVICE=`ps -aux|grep sshd|grep -v grep > /tmp/dssh_service.txt`
DMYSQL_SERVICE=`ps -aux|grep mysql|grep -v grep > /tmp/dmysql_service.txt`

DSSH_PORT_FILE="/tmp/dssh_port.txt"
DMYSQL_PORT_FILE="/tmp/dmysql_port.txt"
DSSH_SERVICE_FILE="/tmp/dssh_service.txt"
DMYSQL_SERVICE_FILE="/tmp/dmysql_service.txt"


echo " ------------dual configuration checking now------------- "|tee -a $log_file
PING=`ping -c 3 1.1.1.1 && ping -c 3 1.1.1.2`

echo ${PING} >/dev/null 2>&1
if [ $? != 0 ];then
echo "`date |cut -d' ' -f2-5` error[2005] Dual network barrier"|tee -a $log_file
exit 1
else
echo "`date |cut -d' ' -f2-5` unblocked network"|tee -a $log_file
fi
IP=`ifconfig|sed -n '/^eth1/,/lo/p'|grep "inet addr"|awk -F ":" '{print $2}'|awk -F " " '{print $1}'`
if [ ${IP} = "1.1.1.1" ];then
    DIP="1.1.1.2"
  else 
    DIP="1.1.1.1"
fi
expect -c "
spawn ssh root@${DIP}
expect { 
        assword {send \"m2a1s2u3000\n\"}
        Connection\ refused {exit 2}}
expect \# {send \"${DSSH_PORT}\n\"}
expect \# {send \"${DMYSQL_PORT}\n\"}
expect \# {send \"${DSSH_SERVICE}\n\"}
expect \# {send \"${DMYSQL_SERVICE}\n\"}
expect \# 
">/dev/null
sleep 1
if [ ! -s ${DSSH_PORT_FILE} ] ;then
echo "`date |cut -d' ' -f2-5` error[2001] another server 22 port is not open"|tee -a $log_file
exit 1
else
echo "`date |cut -d' ' -f2-5` another server 22 port is open"|tee -a $log_file
fi
if [ ! -s ${DMYSQL_PORT_FILE} ];then
echo "`date |cut -d' ' -f2-5` error[2002] another server 3306 port is not open"|tee -a $log_file
exit 1
else
echo "`date |cut -d' ' -f2-5` another server 3306 port is  open"|tee -a $log_file
fi
if [ ! -s ${DSSH_SERVICE_FILE} ] ;then
echo "`date |cut -d' ' -f2-5` error[2003] another server ssh service is not open" |tee -a $log_file
exit
else
echo "`date |cut -d' ' -f2-5` another server ssh service is  open" |tee -a $log_file
fi
if [ ! -s ${DMYSQL_SERVICE_FILE} ];then
echo "`date |cut -d' ' -f2-5` error[2004] another server mysql service is not open" |tee -a $log_file 
exit 1
else
echo "`date |cut -d' ' -f2-5` another server mysql service is  open" |tee -a $log_file 
fi
rm -rf ${DSSH_PORT_FILE}
rm -rf ${DMYSQL_PORT_FILE}
rm -rf ${DSSH_SERVICE_FILE}
rm -rf ${DMYSQL_SERVICE_FILE}
echo " ------------dual configuration checking done------------- "|tee -a $log_file
}

function colony_system_check ()
{
SH_PORT=`lsof -i :22`
MYSQL_PORT=`lsof -i :3306`
SSH_SERVICE=`ps -aux|grep sshd|grep -v grep`
MYSQL_SERVICE=`ps -aux|grep mysql|grep -v grep`

DSSH_PORT=`lsof -i :22 > /tmp/dssh_port.txt`
DMYSQL_PORT=`lsof -i :3306 > /tmp/dmysql_port.txt`
DSSH_SERVICE=`ps -aux|grep sshd|grep -v grep > /tmp/dssh_service.txt`
DMYSQL_SERVICE=`ps -aux|grep mysql|grep -v grep > /tmp/dmysql_service.txt`

DSSH_PORT_FILE="/tmp/dssh_port.txt"
DMYSQL_PORT_FILE="/tmp/dmysql_port.txt"
DSSH_SERVICE_FILE="/tmp/dssh_service.txt"
DMYSQL_SERVICE_FILE="/tmp/dmysql_service.txt"

PING=`ping -c 3 1.1.1.1 && ping -c 3 1.1.1.2`

echo ${PING} >/dev/null 2>&1
if [ $? != 0 ];then
echo "`date |cut -d' ' -f2-5` error colony network barrier"|tee -a $log_file
exit 1
else
echo "`date |cut -d' ' -f2-5` unblocked network"|tee -a $log_file
fi
IP=`ifconfig|sed -n '/^eth1/,/lo/p'|grep "inet addr"|awk -F ":" '{print $2}'|awk -F " " '{print $1}'`
if [ ${IP} = "1.1.1.1" ];then
    DIP="1.1.1.2"
  else
    DIP="1.1.1.1"
fi
expect -c "
spawn ssh root@${DIP}
expect { 
        assword {send \"m2a1s2u3000\n\"}
        Connection\ refused {exit 2}}
expect \# {send \"${DSSH_PORT}\n\"}
expect \# {send \"${DMYSQL_PORT}\n\"}
expect \# {send \"${DSSH_SERVICE}\n\"}
expect \# {send \"${DMYSQL_SERVICE}\n\"}
expect \# 
">/dev/null
sleep 1
if [ ! -s ${DSSH_PORT_FILE} ] ;then
echo "`date |cut -d' ' -f2-5` error another server 22 port is not open"|tee -a $log_file
exit 1
else
echo "`date |cut -d' ' -f2-5` another server 22 port is open"|tee -a $log_file
fi
if [ ! -s ${DMYSQL_PORT_FILE} ];then
echo "`date |cut -d' ' -f2-5` error another server 3306 port is not open"|tee -a $log_file
exit 1
else
echo "`date |cut -d' ' -f2-5`  another server 3306 port is  open"|tee -a $log_file
fi
if [ ! -s ${DSSH_SERVICE_FILE} ] ;then
echo "`date |cut -d' ' -f2-5` error another server ssh service is not open" |tee -a $log_file
exit
else
echo "`date |cut -d' ' -f2-5` another server ssh service is  open" |tee -a $log_file
fi
if [ ! -s ${DMYSQL_SERVICE_FILE} ];then
echo "`date |cut -d' ' -f2-5` error another server mysql service is not open" |tee -a $log_file
exit 1
else
echo "`date |cut -d' ' -f2-5` another server mysql service is  open" |tee -a $log_file
fi
rm -rf ${DSSH_PORT_FILE}
rm -rf ${DMYSQL_PORT_FILE}
rm -rf ${DSSH_SERVICE_FILE}
rm -rf ${DMYSQL_SERVICE_FILE}
}
function sql_tar_backup ()
{
 mkdir -p "${backup_dir}${Package}_${new_version}_new"
      echo "`date|cut -d' ' -f2-5` mysql backup now ..."|tee -a $log_file
/usr/local/mysql/bin/mysqldump -umysql -p'm2a1s2u!@#' fort >${backup_dir}${Package}_${new_version}_new/${datetime}sqlbackup_${new_version}.sql 2>/dev/null
      echo "`date|cut -d' ' -f2-5` mysql backup done ..."|tee -a $log_file
}



function tar_create ()
{

      echo "`date|cut -d' ' -f2-5` tar last create now ..."|tee -a $log_file 
      tar -zcvPf ${backup_tar}${new_version}.tar.gz ${sh_fort} ${web_fort} ${local_fort} ${soft0_fort} ${soft1_fort} 2>/dev/null
      echo "`date|cut -d' ' -f2-5` tar last create done ..."|tee -a $log_file
}



function tar_extract ()
{
      echo "`date|cut -d' ' -f2-5` tar new extract now ..."|tee -a $log_file
      tar -zxcPf ${P_VERSION}.${Package}.${MASTER_VERSION}.tar.gz 2>/dev/null
      echo "`date|cut -d' ' -f2-5` tar new extract done ..."|tee -a $log_file
}





function tomcat_restart ()
{
      echo "`date |cut -d' ' -f2-5` stop tomcat..."|tee -a $log_file
	bash /usr/local/tomcat/bin/shutdown.sh 2>/dev/null

	pid=(`ps -ef 2>/dev/null|grep -E "tomcat|java|jdk" |egrep -v 'egrep|tail'|awk '{print $2}'`)

	kill -9 ${pid[*]} 2>/dev/null
	killall -9 java 2>/dev/null
	
	sleep 10
	pid=(`ps -ef 2>/dev/null|grep -E "tomcat|java|jdk" |egrep -v 'egrep|tail'|awk '{print $2}'`)

	if [ "${pid[0]}" != "" ];then
		kill -9 ${pid[*]} 2>/dev/null
		sleep 1
	fi
      echo "`date |cut -d' ' -f2-5` start tomcat..."|tee -a $log_file
	rm -rf /usr/local/tomcat/work/*
        bash /usr/local/tomcat/bin/startup.sh 2>/dev/null

}
dir_tmp=/root/
sed -n -e '1,/^exit 0$/!p' $0 > "${dir_tmp}/${P_VERSION}.${Package}.${new_version}.tar.gz" 2>/dev/null
cd $dir_tmp
local_system_check
#dual_system_check
sql_tar_backup
tar_create
tar_extract
#write_configuration
#tomcat_restart



      echo "1002" >/var/lib/fort/version.sn
      echo "`date|cut -d' ' -f2-5` version change done ..."|tee -a $log_file
      echo "`date|cut -d' ' -f2-5` installation complete ..."|tee -a $log_file
exit 0
