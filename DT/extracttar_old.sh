#!/bin/bash
P_VERSION="0x4D01"
Package="fort-service"
#new_version="1.0.1"           #当前要升级版本号
num=`cat /var/lib/fort/version.sn | head -n1 | awk -F. '{print $3}'`
let num=$num+1
if [ $num -lt 11 ];then
	new_version=`sed -n 1s/.$/$((num))/p /var/lib/fort/version.sn`
elif [ $num  -lt 101 ];then
	new_version=`sed -n 1s/..$/$((num))/p /var/lib/fort/version.sn`
elif [ $num  -lt 1001 ];then
	new_version=`sed -n 1s/...$/$((num))/p /var/lib/fort/version.sn`		
fi
#new_version=`sed -n 1s/.$/$((num))/p /var/lib/fort/version.sn` #要升级的版本号
last_version=`cat /var/lib/fort/version.sn | head -n1` #当前版本号
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
sh_fort="/usr/local/bin/"
ssh_fort="/usr/local/sbin"
log_name="forts.log"
log_file="/var/log/$log_name"
#标准版升级
anum=`cat -A /usr/local/tomcat/webapps/fort/WEB-INF/classes/fort.properties |  grep '^fort.cluster' | awk -F= '{print $2}' | cut -f -1 -d "^"`

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

echo "$last_version--->$new_version "|tee -a $log_file >/dev/null
echo " ------------local configuration checking now------------- "|tee -a $log_file >/dev/null

		echo ${TOM_PORT} >/dev/null 2>&1
if [  $? != 0 ] ;then 

		echo "`date |cut -d' ' -f2-5` error[1001] 443 port no open"|tee -a $log_file >/dev/null
else
		echo "`date |cut -d' ' -f2-5` 443 port open"|tee -a $log_file >/dev/null
                SINTOM=1  #判断服务是否正常
fi
		echo ${MYSQL_PORT} >/dev/null 2>&1
if [ $? != 0  ];then
		echo "`date |cut -d' ' -f2-5` error[1002] 3306 port no open"|tee -a $log_file >/dev/null
else
		echo "`date |cut -d' ' -f2-5` 3306 port open"|tee -a $log_file >/dev/null
                SINMYSQL=1
fi
		echo ${TOM_SERVICE} >/dev/null 2>&1
if [ $? != 0 ];then
		echo "`date |cut -d' ' -f2-5` error[1003] tomcat service no open"|tee -a $log_file >/dev/null
else
		echo "`date |cut -d' ' -f2-5` tomcat service open"|tee -a $log_file >/dev/null
                SINTOM=1
fi
		echo ${MYSQL_SERVICE} >/dev/null 2>&1
if [ $? != 0 ];then
		echo "`date |cut -d' ' -f2-5` error[1004] mysql service no open"|tee -a $log_file >/dev/null
else
		echo "`date |cut -d' ' -f2-5` mysql service open"|tee -a $log_file >/dev/null
                SINMYSQL=1
fi 
echo " ------------local configuration checking done------------- "|tee -a $log_file >/dev/null


 
	#备份sql
		mkdir -p "${backup_dir}${Package}_${new_version}_new"
		echo "`date|cut -d' ' -f2-5` mysql backup now ..."|tee -a $log_file >/dev/null
		#/usr/local/mysql/bin/mysqldump -umysql -p'm2a1s2u!@#' fort >${backup_dir}${Package}_${new_version}_new/sqlbackup_${new_version}.sql >/dev/null 2>&1
		if [ $anum != 2 ];then
			/usr/local/mysql/bin/mysqldump -umysql -p'm2a1s2u!@#' fort >${backup_dir}${Package}_${new_version}_new/sqlbackup_${new_version}.sql >/dev/null
		fi
		if [ $? == 0 ];then
			echo "`date|cut -d' ' -f2-5` mysql backup done ..."|tee -a $log_file >/dev/null
		else
			echo "`date|cut -d' ' -f2-5` mysql backup faild ..."|tee -a $log_file >/dev/null
			echo "faild"
			exit 1
		fi
		

	#备份tomcat文件
		echo "`date|cut -d' ' -f2-5` tomcat backup create now ..."|tee -a $log_file >/dev/null 
     	tar -zcvPf ${backup_tar}${new_version}.tomcat.tar.gz ${sh_fort} ${ssh_fort} ${web_fort} ${local_fort} ${soft0_fort} ${soft1_fort} >/dev/null 2>&1
		if [ $? == 0 ];then
			echo "`date|cut -d' ' -f2-5` tomcat backup create done ..."|tee -a $log_file >/dev/null
		else
			echo "`date|cut -d' ' -f2-5` tomcat backup faild ..."|tee -a $log_file >/dev/null
			echo "faild"
			exit 1
		fi

	#解tomcat_tar包,导出sql
        
		tar -zxvf ${P_VERSION}-${Package}.${new_version}.tar.gz >/dev/null 2>&1
		if [ $? != 0 ];then
			echo "tar fail ${P_VERSION}-${Package}.${new_version}.tar.gz"|tee -a $log_file >/dev/null
			echo "faild"
			exit 1
		else
			tar -zxvPf ${P_VERSION}-${Package}.${new_version}.fort.tar.gz >/dev/null 2>&1
			if [ $? != 0 ];then
				echo "tar fail ${P_VERSION}-${Package}.${new_version}.fort.tar.gz"|tee -a $log_file >/dev/null
				echo "faild"	
				exit 1
			fi
			if [ -e /root/${P_VERSION}-${Package}.${new_version}.tomcat.tar.gz ];then
				echo "`date|cut -d' ' -f2-5` tomcat update now ..."|tee -a $log_file >/dev/null
				tar -zxvPf ${P_VERSION}-${Package}.${new_version}.tomcat.tar.gz >/dev/null 2>&1
				if [ $?==0 ];then
                        echo "`date|cut -d' ' -f2-5` tomcat update done ..."|tee -a $log_file >/dev/null
       		    else
                        echo "update tomcat faild"|tee -a $log_file >/dev/null
						echo "faild"
						exit 1
				fi
        	fi

        	if [ -e /root/${P_VERSION}-${Package}.${new_version}.mysql.tar.gz ]; then
        		if [ "${SINMYSQL}" = 1 ];then
					echo "`date|cut -d' ' -f2-5` mysql udpate now ..."|tee -a $log_file >/dev/null
                	tar -zxvPf ${P_VERSION}-${Package}.${new_version}.mysql.tar.gz >/dev/null 2>&1
					if [ $? == 0 ];then	
						 mysql -umysql -h127.0.0.1 -p'm2a1s2u!@#' fort < /usr/local/tomcat/webapps/fort/WEB-INF/classes/update.sql >/dev/null 2>&1
						 #mysql -umysql -h127.0.0.1 -p'm2a1s2u!@#' fort < /usr/local/tomcat/webapps/fort/WEB-INF/classes/fortProcedure.sql >/dev/null 2>&1
					fi
					if [ $? == 0 ];then
               			 echo "`date|cut -d' ' -f2-5` mysql update done ..."|tee -a $log_file >/dev/null
						# echo "success"
       			    else	
            		    echo "update mysql faild"|tee -a $log_file >/dev/null
						echo "faild"
						exit 1	
      			    fi
				fi
        	fi
		fi
		#tar -zxvPf ${P_VERSION}-${Package}.${new_version}.fort.tar.gz >/dev/null 2>&1
		
        rm -rf ${dir_tmp}/*.tar.gz    

	#重启tomcat服务
      	echo "`date |cut -d' ' -f2-5` stop tomcat..."|tee -a $log_file >/dev/null
		#bash /usr/local/bin/stop_tomcat.sh >/dev/null
		pid=(`ps -ef |grep -E "tomcat|java|jdk" |egrep -v 'egrep|tail|mgr_client'|awk '{print $2}'`)
		
		kill -9 ${pid[*]} >/dev/null 2>&1
		#killall -9 java >/dev/null
	
		sleep 2
		pid=(`ps -ef |grep -E "tomcat|java|jdk" |egrep -v 'egrep|tail|mgr_client'|awk '{print $2}'`)

		if [ "${pid[0]}" != "" ];then
			kill -9 ${pid[*]} >/dev/null 2>&1
			sleep 1
		fi
      		echo "`date |cut -d' ' -f2-5` start tomcat..."|tee -a $log_file >/dev/null
		rm -rf /usr/local/tomcat/work/*
        bash /usr/local/tomcat/bin/startup.sh >/dev/null
		echo "standard upgrade"|tee -a $log_file >/dev/null
		
}

#web版升级
function web_up()
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

echo "$last_version--->$new_version "|tee -a $log_file >/dev/null
echo " ------------local configuration checking now------------- "|tee -a $log_file >/dev/null
		echo ${TOM_PORT} >/dev/null 2>&1
if [  $? != 0 ] ;then 
		echo "`date |cut -d' ' -f2-5` error[1001] web server 443 port no open"|tee -a $log_file >/dev/null
else
		echo "`date |cut -d' ' -f2-5` web server 443 port open"|tee -a $log_file >/dev/null
                SINTOM=1
fi
		echo ${TOM_SERVICE} >/dev/null 2>&1
if [ $? != 0 ];then
		echo "`date |cut -d' ' -f2-5` error[1003] web server tomcat service no open"|tee -a $log_file >/dev/null
else
		echo "`date |cut -d' ' -f2-5` tomcat service open"|tee -a $log_file >/dev/null
                SINTOM=1
fi
echo " ------------local configuration checking done------------- "|tee -a $log_file >/dev/null

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
		echo "`date|cut -d' ' -f2-5` tomcat backup now ..."|tee -a $log_file >/dev/null 
     		tar -zcvPf ${backup_tar}${new_version}.tomcat.tar.gz ${sh_fort} ${ssh_fort} ${web_fort} ${local_fort} ${soft0_fort} ${soft1_fort} >/dev/null
      		echo "`date|cut -d' ' -f2-5` tomcat backup done ..."|tee -a $log_file >/dev/null
	#tomcat文件解压
      	tar -zxvf ${P_VERSION}-${Package}.${new_version}.tar.gz >/dev/null 2>&1
		if [ $? != 0 ];then
			echo "tar fail ${P_VERSION}-${Package}.${new_version}.tar.gz"|tee -a $log_file >/dev/null
			echo "faild"
			exit 1
		else
			tar -zxvPf ${P_VERSION}-${Package}.${new_version}.fort.tar.gz >/dev/null 2>&1
			if [ $? != 0 ];then
				echo "tar fail ${P_VERSION}-${Package}.${new_version}.fort.tar.gz"|tee -a $log_file >/dev/null
				echo "faild"
			exit 1
		fi
			if [ -e /root/${P_VERSION}-${Package}.${new_version}.tomcat.tar.gz ];then
				echo "`date|cut -d' ' -f2-5` tomcat update now ..."|tee -a $log_file >/dev/null
				tar -zxvPf ${P_VERSION}-${Package}.${new_version}.tomcat.tar.gz >/dev/null 2>&1
				if [ $?==0 ];then
                        echo "`date|cut -d' ' -f2-5` tomcat update done ..."|tee -a $log_file >/dev/null
       		    else
                        echo "update tomcat faild"|tee -a $log_file >/dev/null
						echo "faild"
						exit 1
				fi
        	fi
		fi
		rm -rf ${dir_tmp}/*.tar.gz 
	#tomcat服务重启
		echo "`date|cut -d' ' -f2-5` tomcat stop  ..."|tee -a $log_file >/dev/null
		#bash /usr/local/tomcat/bin/shutdown.sh >/dev/null
		pid=(`ps -ef |grep -E "tomcat|java|jdk" |egrep -v 'egrep|tail|mgr_client'|awk '{print $2}'`)

		kill -9 ${pid[*]} >/dev/null 2>&1
		#killall -9 java >/dev/null
	
		sleep 2
		pid=(`ps -ef |grep -E "tomcat|java|jdk" |egrep -v 'egrep|tail|mgr_client'|awk '{print $2}'`)

		if [ "${pid[0]}" != "" ];then
			kill -9 ${pid[*]} >/dev/null 2>&1
			sleep 1
		fi
      	echo "`date |cut -d' ' -f2-5` start tomcat..."|tee -a $log_file >/dev/null
		rm -rf /usr/local/tomcat/work/*
        bash /usr/local/tomcat/bin/startup.sh >/dev/null
echo "web_up"|tee -a $log_file >/dev/null

}

#mysql版主机升级
function mysql_main()
{
echo "$last_version--->$new_version "|tee -a $log_file >/dev/null

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

echo " ------------local configuration checking now------------- "|tee -a $log_file >/dev/null
		echo ${MYSQL_PORT} >/dev/null 2>&1
if [ $? != 0  ];then
		echo "`date |cut -d' ' -f2-5` error[1002] mysql server 3306 port no open"|tee -a $log_file >/dev/null
else
		echo "`date |cut -d' ' -f2-5` mysql server 3306 port open"|tee -a $log_file >/dev/null
                SINMYSQL=1
fi
		echo ${MYSQL_SERVICE} >/dev/null 2>&1
if [ $? != 0 ];then
		echo "`date |cut -d' ' -f2-5` error[1004] mysql service no open"|tee -a $log_file >/dev/null
else
		echo "`date |cut -d' ' -f2-5` mysql service open"|tee -a $log_file >/dev/null
                SINMYSQL=1
fi 
echo " ------------local configuration checking done------------- "|tee -a $log_file >/dev/null

	#sql备份
		mkdir -p "${backup_dir}${Package}_${new_version}_new"
		echo "`date|cut -d' ' -f2-5` mysql backup now ..."|tee -a $log_file >/dev/null
		/usr/local/mysql/bin/mysqldump -umysql -p'm2a1s2u!@#' fort >${backup_dir}${Package}_${new_version}_new/sqlbackup_${new_version}.sql >/dev/null
		if [ $? == 0 ];then
			echo "`date|cut -d' ' -f2-5` mysql backup done ..."|tee -a $log_file >/dev/null
		else
			echo "`date|cut -d' ' -f2-5` mysql backup faild ..."|tee -a $log_file >/dev/null
			exit 1
		fi
		tar -zxvf ${P_VERSION}-${Package}.${new_version}.tar.gz >/dev/null 2>&1
		if [ $? != 0 ];then
			echo "tar fail ${P_VERSION}-${Package}.${new_version}.tar.gz"|tee -a $log_file >/dev/null
			echo "faild"
			exit 1
		else
        #sql升级
            tar -zxvPf ${P_VERSION}-${Package}.${new_version}.fort.tar.gz >/dev/null 2>&1
			if [ $? != 0 ];then
				echo "tar fail ${P_VERSION}-${Package}.${new_version}.fort.tar.gz"|tee -a $log_file >/dev/null
				echo "faild"
				exit 1
			fi
            if [ -e /root/${P_VERSION}-${Package}.${new_version}.mysql.tar.gz ]; then
        		if [ "${SINMYSQL}" = 1 ];then
					echo "`date|cut -d' ' -f2-5` mysql udpate now ..."|tee -a $log_file >/dev/null
                	tar -zxvPf ${P_VERSION}-${Package}.${new_version}.mysql.tar.gz >/dev/null 2>&1
					if [ $? == 0 ];then	
						 mysql -umysql -h127.0.0.1 -p'm2a1s2u!@#' fort < /usr/local/tomcat/webapps/fort/WEB-INF/classes/update.sql >/dev/null 2>&1
						#mysql -umysql -h127.0.0.1 -p'm2a1s2u!@#' fort < /usr/local/tomcat/webapps/fort/WEB-INF/classes/fortProcedure.sql >/dev/null 2>&1
					fi
					if [ $? == 0 ];then
               			 echo "`date|cut -d' ' -f2-5` mysql update done ..."|tee -a $log_file >/dev/null
						# echo "success"
       			    else	
            		    echo "update mysql faild"|tee -a $log_file >/dev/null
						echo "faild"
						exit 1	
      			    fi
				fi
        	fi
        fi
		echo "mysql_main"|tee -a $log_file >/dev/null
		rm -rf ${dir_tmp}/*.tar.gz  
}
#mysql备级升级
function mysql_minor()
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

echo "$last_version--->$new_version "|tee -a $log_file >/dev/null
echo " ------------local configuration checking now------------- "|tee -a $log_file >/dev/null
		echo ${MYSQL_PORT} >/dev/null 2>&1
if [ $? != 0  ];then
		echo "`date |cut -d' ' -f2-5` error[1002] mysql server 3306 port no open"|tee -a $log_file >/dev/null
else
		echo "`date |cut -d' ' -f2-5` mysql server 3306 port open"|tee -a $log_file >/dev/null
                SINMYSQL=1
fi
		echo ${MYSQL_SERVICE} >/dev/null 2>&1
if [ $? != 0 ];then
		echo "`date |cut -d' ' -f2-5` error[1004] mysql service no open"|tee -a $log_file >/dev/null
else
		echo "`date |cut -d' ' -f2-5` mysql service open"|tee -a $log_file >/dev/null
                SINMYSQL=1
fi 
echo " ------------local configuration checking done------------- "|tee -a $log_file >/dev/null
echo "mysql_minor"|tee -a $log_file >/dev/null
tar -zxvf ${P_VERSION}-${Package}.${new_version}.tar.gz >/dev/null 2>&1
tar -zxvPf ${P_VERSION}-${Package}.${new_version}.fort.tar.gz >/dev/null 2>&1
#echo "success"
rm -rf {dir_tmp}/*.tar.gz 
}

dir_tmp=/root/
sed -n -e '1,/^exit 0$/!p' $0 >"${dir_tmp}/${P_VERSION}-${Package}.${new_version}.tar.gz"
cd $dir_tmp
case $1 in 
     1)
      standard_up
	  if [ $? == 0 ];then
		echo $new_version >/var/lib/fort/version.sn
		nnn=`echo $new_version | awk -F. '{print $3}'`
		echo 100$nnn >>/var/lib/fort/version.sn
		echo "`date|cut -d' ' -f2-5` version change done ..."|tee -a $log_file >/dev/null
		echo "`date|cut -d' ' -f2-5` installation complete ..."|tee -a $log_file >/dev/null
		echo "success"
	  fi
     ;; 
     2)
      web_up 
	  if [ $? == 0 ];then
		echo $new_version >/var/lib/fort/version.sn
		nnn=`echo $new_version | awk -F. '{print $3}'`
		echo 100$nnn >>/var/lib/fort/version.sn
		echo "`date|cut -d' ' -f2-5` version change done ..."|tee -a $log_file >/dev/null
		echo "`date|cut -d' ' -f2-5` installation complete ..."|tee -a $log_file >/dev/null
		echo "success"
	  fi
     ;;
     3)
      mysql_main
	  if [ $? == 0 ];then
		echo $new_version >/var/lib/fort/version.sn
		nnn=`echo $new_version | awk -F. '{print $3}'`
		echo 100$nnn >>/var/lib/fort/version.sn
		echo "`date|cut -d' ' -f2-5` version change done ..."|tee -a $log_file >/dev/null
		echo "`date|cut -d' ' -f2-5` installation complete ..."|tee -a $log_file >/dev/null
		echo "success"
	  fi
     ;;
     4)
      mysql_minor    
	  if [ $? == 0 ];then
		echo $new_version >/var/lib/fort/version.sn
		nnn=`echo $new_version | awk -F. '{print $3}'`
		echo 100$nnn >>/var/lib/fort/version.sn
		echo "`date|cut -d' ' -f2-5` version change done ..."|tee -a $log_file >/dev/null
		echo "`date|cut -d' ' -f2-5` installation complete ..."|tee -a $log_file >/dev/null 
		echo "success"
	  fi
     ;;        
esac
exit 0
