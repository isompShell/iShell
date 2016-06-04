#!/bin/bash

P_VERSION="0x4D01"
Package="fort-service"
#new_version="1.0.1"           #当前要升级版本号
num=`cat /var/lib/fort/version.sn | head -n1 | awk -F. '{print $3}'`
let num=$num+1
new_version=`sed -n 1s/.$/$((num))/p /var/lib/fort/version.sn`
last_version=`cat /var/lib/fort/version.sn`          #当前版本号
#next_version="1.0.2"          #下一版本
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
#标准版升级
function standard_up()
{

TOM_PORT=`lsof -i :443`
MYSQL_PORT=`lsof -i :3306`
TOM_SERVICE=`ps aux|grep tomcat|grep -v grep`
MYSQL_SERVICE=`ps aux|grep mysql|grep -v grep`

DSSH_PORT=`lsof -i :22 > /tmp/dssh_port.txt`
DMYSQL_PORT=`lsof -i :3306 > /tmp/dmysql_port.txt`
DSSH_SERVICE=`ps aux|grep sshd|grep -v grep > /tmp/dssh_service.txt`
DMYSQL_SERVICE=`ps aux|grep mysql|grep -v grep > /tmp/dmysql_service.txt`

DSSH_PORT_FILE="/tmp/dssh_port.txt"
DMYSQL_PORT_FILE="/tmp/dmysql_port.txt"
DSSH_SERVICE_FILE="/tmp/dssh_service.txt"
DMYSQL_SERVICE_FILE="/tmp/dmysql_service.txt"

echo "$last_version--->$new_version "|tee -a $log_file
echo " ------------local configuration checking now------------- "|tee -a $log_file

		echo ${TOM_PORT} >/dev/null 2>&1
if [  $? != 0 ] ;then 
		echo "`date |cut -d' ' -f2-5` error[1001] 443 port no open"|tee -a $log_file
else
		echo "`date |cut -d' ' -f2-5` 443 port open"|tee -a $log_file
                SINTOM=1  #判断服务是否正常
fi
		echo ${MYSQL_PORT} >/dev/null 2>&1
if [ $? != 0  ];then
		echo "`date |cut -d' ' -f2-5` error[1002] 3306 port no open"|tee -a $log_file
else
		echo "`date |cut -d' ' -f2-5` 3306 port open"|tee -a $log_file
                SINMYSQL=1
fi
		echo ${TOM_SERVICE} >/dev/null 2>&1
if [ $? != 0 ];then
		echo "`date |cut -d' ' -f2-5` error[1003] tomcat service no open"|tee -a $log_file
else
		echo "`date |cut -d' ' -f2-5` tomcat service open"|tee -a $log_file
                SINTOM=1
fi
		echo ${MYSQL_SERVICE} >/dev/null 2>&1
if [ $? != 0 ];then
		echo "`date |cut -d' ' -f2-5` error[1004] mysql service no open"|tee -a $log_file
else
		echo "`date |cut -d' ' -f2-5` mysql service open"|tee -a $log_file
                SINMYSQL=1
fi 
echo " ------------local configuration checking done------------- "|tee -a $log_file

#双机升级前检测
#echo " ------------dual configuration checking now------------- "|tee -a $log_file
#PING=`ping -c 3 1.1.1.1 && ping -c 3 1.1.1.2`
#
#		echo ${PING} >/dev/null 2>&1
#if [ $? != 0 ];then
#		echo "`date |cut -d' ' -f2-5` error[2005] Dual network barrier"|tee -a $log_file
#exit 1
#else
#		echo "`date |cut -d' ' -f2-5` unblocked network"|tee -a $log_file
#fi
#IP=`ifconfig|sed -n '/^eth1/,/lo/p'|grep "inet addr"|awk -F ":" '{print $2}'|awk -F " " '{print $1}'`
#if [ ${IP} = "1.1.1.1" ];then
#    DIP="1.1.1.2"
#  else 
#    DIP="1.1.1.1"
#fi
#expect -c "
#	spawn ssh root@${DIP}
#		expect { 
#        		assword {send \"m2a1s2u3000\n\"}
#        		Connection\ refused {exit 2}}
#		expect \# {send \"${DSSH_PORT}\n\"}
#		expect \# {send \"${DMYSQL_PORT}\n\"}
#		expect \# {send \"${DSSH_SERVICE}\n\"}
#		expect \# {send \"${DMYSQL_SERVICE}\n\"}
#		expect \# 
#">/dev/null
#sleep 1
#if [ ! -s ${DSSH_PORT_FILE} ] ;then
#		echo "`date |cut -d' ' -f2-5` error[2001] another server 22 port is not open"|tee -a $log_file
#else
#		echo "`date |cut -d' ' -f2-5` another server 22 port is open"|tee -a $log_file
#                DOUSSH = 1
#fi
#if [ ! -s ${DMYSQL_PORT_FILE} ];then
#		echo "`date |cut -d' ' -f2-5` error[2002] another server 3306 port is not open"|tee -a $log_file
#else
#		echo "`date |cut -d' ' -f2-5` another server 3306 port is  open"|tee -a $log_file
 #               DOUMYSQL = 1
#fi
#if [ ! -s ${DSSH_SERVICE_FILE} ] ;then
#		echo "`date |cut -d' ' -f2-5` error[2003] another server ssh service is not open" |tee -a $log_file
#else
#		echo "`date |cut -d' ' -f2-5` another server ssh service is  open" |tee -a $log_file
 #               DOUSSH = 1
#fi
#if [ ! -s ${DMYSQL_SERVICE_FILE} ];then
#		echo "`date |cut -d' ' -f2-5` error[2004] another server mysql service is not open" |tee -a $log_file 
#else
#		echo "`date |cut -d' ' -f2-5` another server mysql service is  open" |tee -a $log_file 
 #               DOUMYSQL = 1 
#fi


#集群升级前检测
#rm -rf ${DSSH_PORT_FILE}
#rm -rf ${DMYSQL_PORT_FILE}
#rm -rf ${DSSH_SERVICE_FILE}
#rm -rf ${DMYSQL_SERVICE_FILE}
#		echo " ------------dual configuration checking done------------- "|tee -a $log_file


#PING=`ping -c 3 1.1.1.1 && ping -c 3 1.1.1.2`
#
#echo ${PING} >/dev/null 2>&1
#if [ $? != 0 ];then
#echo "`date |cut -d' ' -f2-5` error colony network barrier"|tee -a $log_file
#exit 1
#else
#echo "`date |cut -d' ' -f2-5` unblocked network"|tee -a $log_file
#fi
#IP=`ifconfig|sed -n '/^eth1/,/lo/p'|grep "inet addr"|awk -F ":" '{print $2}'|awk -F " " '{print $1}'`
#if [ ${IP} = "1.1.1.1" ];then
#    DIP="1.1.1.2"
#  else
#    DIP="1.1.1.1"
#fi
#expect -c "
#spawn ssh root@${DIP}
#expect { 
#        assword {send \"m2a1s2u3000\n\"}
#        Connection\ refused {exit 2}}
#expect \# {send \"${DSSH_PORT}\n\"}
#expect \# {send \"${DMYSQL_PORT}\n\"}
#expect \# {send \"${DSSH_SERVICE}\n\"}
#expect \# {send \"${DMYSQL_SERVICE}\n\"}
#expect \# 
#">/dev/null
#sleep 1
#if [ ! -s ${DSSH_PORT_FILE} ] ;then
#echo "`date |cut -d' ' -f2-5` error another server 22 port is not open"|tee -a $log_file
#exit 1
#else
#echo "`date |cut -d' ' -f2-5` another server 22 port is open"|tee -a $log_file
#fi
#if [ ! -s ${DMYSQL_PORT_FILE} ];then
#echo "`date |cut -d' ' -f2-5` error another server 3306 port is not open"|tee -a $log_file
#exit 1
#else
#echo "`date |cut -d' ' -f2-5`  another server 3306 port is  open"|tee -a $log_file
#fi
#if [ ! -s ${DSSH_SERVICE_FILE} ] ;then
#echo "`date |cut -d' ' -f2-5` error another server ssh service is not open" |tee -a $log_file
#exit
#else
#echo "`date |cut -d' ' -f2-5` another server ssh service is  open" |tee -a $log_file
#fi
#if [ ! -s ${DMYSQL_SERVICE_FILE} ];then
#echo "`date |cut -d' ' -f2-5` error another server mysql service is not open" |tee -a $log_file
#exit 1
#else
#echo "`date |cut -d' ' -f2-5` another server mysql service is  open" |tee -a $log_file
#fi


rm -rf ${DSSH_PORT_FILE}
rm -rf ${DMYSQL_PORT_FILE}
rm -rf ${DSSH_SERVICE_FILE}
rm -rf ${DMYSQL_SERVICE_FILE}

#chmod +x /usr/local/sbin/rdpd
#chown -R root:root /usr/local/sbin/rdpd
#cd /usr/local/soft9100
#chmod +x run.sh
#./run.sh &
#echo -e \003
#cd /usr/local/soft9101
#chmod +x run.sh
#./run.sh &
#echo -e \003
#
#chmod +x /usr/local/bin/SimpShell
#chmod u+s /usr/local/bin/SimpShell
#/etc/init.d/ssh restart
 
	#备份sql
		mkdir -p "${backup_dir}${Package}_${new_version}_new"
		echo "`date|cut -d' ' -f2-5` mysql backup now ..."|tee -a $log_file
		/usr/local/mysql/bin/mysqldump -umysql -p'm2a1s2u!@#' fort >${backup_dir}${Package}_${new_version}_new/${datetime}sqlbackup_${new_version}.sql 1>/dev/null
		echo "`date|cut -d' ' -f2-5` mysql backup done ..."|tee -a $log_file


	#备份tomcat文件
		echo "`date|cut -d' ' -f2-5` tomcat backup create now ..."|tee -a $log_file 
     	tar -zcvPf ${backup_tar}${new_version}.tomcat.tar.gz ${sh_fort} ${web_fort} ${local_fort} ${soft0_fort} ${soft1_fort} 1>/dev/null
      	echo "`date|cut -d' ' -f2-5` tomcat backup create done ..."|tee -a $log_file

	#解tomcat_tar包,导出sql
        echo "`date|cut -d' ' -f2-5` tomcat update now ..."|tee -a $log_file
		tar -zxvf ${P_VERSION}-${Package}.${new_version}.tar.gz 1>/dev/null
        tar -zxvPf ${P_VERSION}-${Package}.${new_version}.tomcat.tar.gz 1>/dev/null
		if [ $?==0 ];then
                        echo "`date|cut -d' ' -f2-5` tomcat update done ..."|tee -a $log_file
        else
                        echo "update tomcat faild"
        fi
		
		if [ "${SINMYSQL}" = 1 ];then
				echo "`date|cut -d' ' -f2-5` msyql udpate now ..."|tee -a $log_file
                tar -zxvPf ${P_VERSION}-${Package}.${new_version}.mysql.tar.gz 1>/dev/null
                mysql -umysql -p'm2a1s2u!@#' fort < /usr/local/tomcat/webapps/fort/WEB-INF/classes/update.sql
				mysql -umysql -p'm2a1s2u!@#' fort < /usr/local/tomcat/webapps/fort/WEB-INF/classes/fortProcedure.sql
		if [ $?==0 ];then
                echo "`date|cut -d' ' -f2-5` mysql update done ..."|tee -a $log_file
        else
                echo "update mysql faild"
        fi
		fi
             

	#重启tomcat服务
      		echo "`date |cut -d' ' -f2-5` stop tomcat..."|tee -a $log_file
		bash /usr/local/tomcat/bin/shutdown.sh 2>/dev/null

		pid=(`ps -ef 2>/dev/null|grep -E "tomcat|java|jdk" |egrep -v 'egrep|tail'|awk '{print $2}'`)

		kill -9 ${pid[*]} 1>/dev/null
		killall -9 java 1>/dev/null
	
		sleep 10
		pid=(`ps -ef 2>/dev/null|grep -E "tomcat|java|jdk" |egrep -v 'egrep|tail'|awk '{print $2}'`)

		if [ "${pid[0]}" != "" ];then
			kill -9 ${pid[*]} 2>/dev/null
			sleep 1
		fi
      		echo "`date |cut -d' ' -f2-5` start tomcat..."|tee -a $log_file
		rm -rf /usr/local/tomcat/work/*
        	bash /usr/local/tomcat/bin/startup.sh 2>/dev/null
		echo "standard upgrade"|tee -a $log_file
		
}

#web版升级
function web_up()
{

TOM_PORT=`lsof -i :443`
MYSQL_PORT=`lsof -i :3306`
TOM_SERVICE=`ps -aux|grep tomcat|grep -v grep`
MYSQL_SERVICE=`ps -aux|grep mysql|grep -v grep`

DSSH_PORT=`lsof -i :22 > /tmp/dssh_port.txt`
DMYSQL_PORT=`lsof -i :3306 > /tmp/dmysql_port.txt`
DSSH_SERVICE=`ps -aux|grep sshd|grep -v grep > /tmp/dssh_service.txt`
DMYSQL_SERVICE=`ps -aux|grep mysql|grep -v grep > /tmp/dmysql_service.txt`

DSSH_PORT_FILE="/tmp/dssh_port.txt"
DMYSQL_PORT_FILE="/tmp/dmysql_port.txt"
DSSH_SERVICE_FILE="/tmp/dssh_service.txt"
DMYSQL_SERVICE_FILE="/tmp/dmysql_service.txt"

echo "$last_version--->$new_version "|tee -a $log_file
echo " ------------local configuration checking now------------- "|tee -a $log_file
		echo ${TOM_PORT} >/dev/null 2>&1
if [  $? != 0 ] ;then 
		echo "`date |cut -d' ' -f2-5` error[1001] web server 443 port no open"|tee -a $log_file
else
		echo "`date |cut -d' ' -f2-5` web server 443 port open"|tee -a $log_file
                SINTOM=1
fi
		echo ${TOM_SERVICE} >/dev/null 2>&1
if [ $? != 0 ];then
		echo "`date |cut -d' ' -f2-5` error[1003] web server tomcat service no open"|tee -a $log_file
else
		echo "`date |cut -d' ' -f2-5` tomcat service open"|tee -a $log_file
                SINTOM=1
fi
echo " ------------local configuration checking done------------- "|tee -a $log_file

#chmod +x /usr/local/sbin/rdpd
#chown -R root:root /usr/local/sbin/rdpd
#cd /usr/local/soft9100
#./run.sh &
#echo -e \003
#cd /usr/local/soft9101
#./run.sh &
#echo -e \003
# 
#chmod +x /usr/local/bin/SimpShell
#chmod u+s /usr/local/bin/SimpShell
#/etc/init.d/ssh restart
	#tomcat文件备份
		mkdir -p "${backup_dir}${Package}_${new_version}_new"
		echo "`date|cut -d' ' -f2-5` tomcat backup now ..."|tee -a $log_file 
     		tar -zcvPf ${backup_tar}${new_version}.tomcat.tar.gz ${sh_fort} ${web_fort} ${local_fort} ${soft0_fort} ${soft1_fort} 2>/dev/null
      		echo "`date|cut -d' ' -f2-5` tomcat backup done ..."|tee -a $log_file
	#tomcat文件解压
      		echo "`date|cut -d' ' -f2-5` tomcat update now ..."|tee -a $log_file
      		tar -zxvf ${P_VERSION}-${Package}.${new_version}.tar.gz 2>/dev/null
      		tar -zxvPf ${P_VERSION}-${Package}.${new_version}.tomcat.tar.gz 2>/dev/null
      		echo "`date|cut -d' ' -f2-5` tomcat update done ..."|tee -a $log_file
	#tomcat服务重启
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
echo "web_up"|tee -a $log_file
}

#mysql版主机升级
function mysql_main()
{
echo "$last_version--->$new_version "|tee -a $log_file

TOM_PORT=`lsof -i :443`
MYSQL_PORT=`lsof -i :3306`
TOM_SERVICE=`ps -aux|grep tomcat|grep -v grep`
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
		echo ${MYSQL_PORT} >/dev/null 2>&1
if [ $? != 0  ];then
		echo "`date |cut -d' ' -f2-5` error[1002] mysql server 3306 port no open"|tee -a $log_file
else
		echo "`date |cut -d' ' -f2-5` mysql server 3306 port open"|tee -a $log_file
                SINMYSQL=1
fi
		echo ${MYSQL_SERVICE} >/dev/null 2>&1
if [ $? != 0 ];then
		echo "`date |cut -d' ' -f2-5` error[1004] mysql service no open"|tee -a $log_file
else
		echo "`date |cut -d' ' -f2-5` mysql service open"|tee -a $log_file
                SINMYSQL=1
fi 
echo " ------------local configuration checking done------------- "|tee -a $log_file

	#sql备份
		mkdir -p "${backup_dir}${Package}_${new_version}_new"
		echo "`date|cut -d' ' -f2-5` mysql backup now ..."|tee -a $log_file
		/usr/local/mysql/bin/mysqldump -umysql -p'm2a1s2u!@#' fort >${backup_dir}${Package}_${new_version}_new/${datetime}sqlbackup_${new_version}.sql 2>/dev/null
		echo "`date|cut -d' ' -f2-5` mysql backup done ..."|tee -a $log_file
        #sql升级
                echo "`date|cut -d' ' -f2-5` tomcat update now ..."|tee -a $log_file
                if [ "${SINMYSQL}" = 1 ];then
				tar -zxvf ${P_VERSION}-${Package}.${new_version}.tar.gz 2>/dev/null
                tar -zxvPf ${P_VERSION}-${Package}.${new_version}.mysql.tar.gz 2>/dev/null
                mysql -umysql -p'm2a1s2u!@#' fort < /usr/local/tomcat/webapps/fort/WEB-INF/classes/update.sql
                mysql -umysql -p'm2a1s2u!@#' fort < /usr/local/tomcat/webapps/fort/WEB-INF/classes/fortProcedure.sql
                fi
                echo "`date|cut -d' ' -f2-5` tomcat update done ..."|tee -a $log_file
		echo "mysql_main"|tee -a $log_file
}
#mysql备级升级
function mysql_minor()
{
TOM_PORT=`lsof -i :443`
MYSQL_PORT=`lsof -i :3306`
TOM_SERVICE=`ps -aux|grep tomcat|grep -v grep`
MYSQL_SERVICE=`ps -aux|grep mysql|grep -v grep`

DSSH_PORT=`lsof -i :22 > /tmp/dssh_port.txt`
DMYSQL_PORT=`lsof -i :3306 > /tmp/dmysql_port.txt`
DSSH_SERVICE=`ps -aux|grep sshd|grep -v grep > /tmp/dssh_service.txt`
DMYSQL_SERVICE=`ps -aux|grep mysql|grep -v grep > /tmp/dmysql_service.txt`

DSSH_PORT_FILE="/tmp/dssh_port.txt"
DMYSQL_PORT_FILE="/tmp/dmysql_port.txt"
DSSH_SERVICE_FILE="/tmp/dssh_service.txt"
DMYSQL_SERVICE_FILE="/tmp/dmysql_service.txt"

echo "$last_version--->$new_version "|tee -a $log_file
echo " ------------local configuration checking now------------- "|tee -a $log_file
		echo ${MYSQL_PORT} >/dev/null 2>&1
if [ $? != 0  ];then
		echo "`date |cut -d' ' -f2-5` error[1002] mysql server 3306 port no open"|tee -a $log_file
else
		echo "`date |cut -d' ' -f2-5` mysql server 3306 port open"|tee -a $log_file
                SINMYSQL=1
fi
		echo ${MYSQL_SERVICE} >/dev/null 2>&1
if [ $? != 0 ];then
		echo "`date |cut -d' ' -f2-5` error[1004] mysql service no open"|tee -a $log_file
else
		echo "`date |cut -d' ' -f2-5` mysql service open"|tee -a $log_file
                SINMYSQL=1
fi 
echo " ------------local configuration checking done------------- "|tee -a $log_file
echo "mysql_minor"|tee -a $log_file

}

dir_tmp=/root/
sed -n -e '1,/^exit 0$/!p' $0 > "${dir_tmp}/${P_VERSION}-${Package}.${new_version}.tar.gz" 2>/dev/null
cd $dir_tmp
case $1 in 
     1)
      standard_up
     ;; 
     2)
      web_up 
     ;;
     3)
      mysql_main
     ;;
     4)
      mysql_minor    
     ;;        

esac
      echo $new_version >/var/lib/fort/version.sn
      echo "`date|cut -d' ' -f2-5` version change done ..."|tee -a $log_file
      echo "`date|cut -d' ' -f2-5` installation complete ..."|tee -a $log_file
exit 0