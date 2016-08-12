#!/bin/bash


#===============定义包名===============
P_VERSION="0x4D01"
Package="fort-service"
#======================================
admin_dir="/var/lib/fort/"              #描述文件、版本控制文件所在路径
backup_dir="${admin_dir}backup/"        #备份目录
backup_version="${admin_dir}${Package}/"
version_file="${backup_version}version"
datetime=`date +"%Y%m%d%N"`
web_fort="/usr/local/tomcat/webapps/fort"
local_fort="/usr/local/fort" 
soft0_fort="/usr/local/soft9100"
soft1_fort="/usr/local/soft9101"
sh_fort="/usr/local/bin/"
ssh_fort="/usr/local/sbin"
log_name="forts.log"
log_file="/var/log/$log_name"
TMP="/tmp"
config_file="/etc/ip"
mysql_user="mysql"
mysql_pass='m2a1s2u!@#'
#当前环境
#1：标准 2：集群 3：地铁
anum=`cat -A /usr/local/tomcat/webapps/fort/WEB-INF/classes/fort.properties |  grep '^fort.cluster' | awk -F= '{print $2}' | cut -f -1 -d "^"`
num=`cat /var/lib/fort/version.sn | head -n1 | awk -F. '{print $3}'` #当前版本号最后一位，用来判断版本依赖和升级更改版本号问题
last_version=`cat /var/lib/fort/version.sn | head -n1`
let num=$num+1
if [ $num -lt 11 ];then
	new_version=`sed -n 1s/.$/$((num))/p /var/lib/fort/version.sn`  #new_version:下一升级版本号
elif [ $num  -lt 101 ];then
	new_version=`sed -n 1s/..$/$((num))/p /var/lib/fort/version.sn`
elif [ $num  -lt 1001 ];then
	new_version=`sed -n 1s/...$/$((num))/p /var/lib/fort/version.sn`		
fi

backup_tar="${backup_dir}${Package}_${new_version}_new/"
#=============检测服务状态========================
#传入参数（服务名） 如果存在，返回1.不存在，返回0
#==================================================
function check_status(){
	ck=`ps -ef | grep $1 | grep -v grep | wc -l`
	if [[ $ck==0 ]]; then
		echo 0
	else 
		echo 1
	fi
}
#==========================
#检测tomcat和mysql是否启动
#ck_tomcat 0:未启动 其他:启动
#ck_mysql  0:未启动 其他:启动
#==========================
function check_services(){
	echo "$last_version--->$new_version">> $log_file 
	echo " ------------local configuration checking now------------- ">> $log_file
	ck_tomcat=`ps -ef | grep tomcat | grep -v grep | wc -l`
	ck_mysql=`ps -ef | grep mysql | grep -v grep | wc -l`
	if [[ $ck_tomcat == 0 ]];then
		echo "`date |cut -d' ' -f2-5` tomcat not running">> $log_file
	else
		echo "`date |cut -d' ' -f2-5` tomcat running....">> $log_file
	fi
	if [[ $ck_mysql == 0 ]];then
		echo "`date |cut -d' ' -f2-5` mysql not running">> $log_file
		echo " ------------local configuration checking done------------- ">> $log_file
	else
		echo "`date |cut -d' ' -f2-5` mysql running....">> $log_file		
		echo " ------------local configuration checking done------------- ">> $log_file
	fi
	# 检测mysql是否同步
	status=`mysql -u$mysql_user -p$mysql_pass -e "show slave status\G" | grep -i "running"`> /dev/null
	Slave_IO_Running=`echo $status | grep Slave_IO_Running | awk '{print $2}'`
	Slave_SQL_Running=`echo $status | grep Slave_SQL_Running | awk '{print $2}'`
	Master_Host=`mysql -u$mysql_user -p$mysql_pass -e "show slave status\G" | grep -i "Master_Host" | awk -F: '{print $2}'`> /dev/null
# 检测是否存在heartbeat服务
	hb=`ps -ef | grep heartbeat | grep -v grep | wc -l`
}

function backup_tomcat(){
	mkdir -p "${backup_dir}${Package}_${new_version}_new"
	echo "`date|cut -d' ' -f2-5` tomcat backup create now ...">> $log_file
	tar -zcvPf ${backup_tar}${new_version}.tomcat.tar.gz ${sh_fort} ${ssh_fort} ${web_fort} ${local_fort} ${soft0_fort} ${soft1_fort} >/dev/null 2>&1
	if [[ -e ${backup_tar}${new_version}.tomcat.tar.gz ]]; then
		echo "`date|cut -d' ' -f2-5` tomcat backup  done ...">> $log_file 
	else
		echo "`date|cut -d' ' -f2-5` tomcat backup faild ...">> $log_file
		echo "faild"
		exit 1
	fi
}

function backup_mysql(){
	mkdir -p "${backup_dir}${Package}_${new_version}_new"
	echo "`date|cut -d' ' -f2-5` mysql backup now ...">> $log_file
	/usr/local/mysql/bin/mysqldump -umysql -p'm2a1s2u!@#' fort >${backup_dir}${Package}_${new_version}_new/sqlbackup_${new_version}.sql
	if [ $? == 0 ];then
			echo "`date|cut -d' ' -f2-5` mysql backup  done ...">> $log_file
	else
			echo "`date|cut -d' ' -f2-5` mysql backup faild ...">> $log_file
			echo "faild"
			exit 1
	fi
}
function tomcat_update(){
	tar -zxvf ${P_VERSION}-${Package}.${new_version}.tar.gz >/dev/null 2>&1
	tar -zxvPf ${P_VERSION}-${Package}.${new_version}.fort.tar.gz >/dev/null 2>&1
	if [[ $? -ne 0 ]]; then
		echo "`date|cut -d' ' -f2-5`tar fort faild ">> $log_file
	fi
	if [ -e /$TMP/${P_VERSION}-${Package}.${new_version}.tomcat.tar.gz ];then
				echo "`date|cut -d' ' -f2-5` tomcat update now ...">> $log_file
				tar -zxvPf ${P_VERSION}-${Package}.${new_version}.tomcat.tar.gz >/dev/null 2>&1
				if [ $?==0 ];then
                        echo "`date|cut -d' ' -f2-5` tomcat update done ..."|tee -a $log_file >/dev/null
                        rm -rf ${P_VERSION}-${Package}.${new_version}.tomcat.tar.gz
       		    else
                        echo "update tomcat faild">> $log_file
						echo "faild"
						exit 1
				fi
    fi
    rm -rf ${P_VERSION}-${Package}.${new_version}.tar.gz
    #rm -rf ${P_VERSION}-${Package}.${new_version}.fort.tar.gz
	#重启tomcat
	echo "`date |cut -d' ' -f2-5` stop tomcat...">> $log_file
		#bash /usr/local/bin/stop_tomcat.sh >/dev/null
		pid=(`ps -ef |grep -E "tomcat|java|jdk" |egrep -v 'egrep|tail|mgr_client'|awk '{print $2}'`)
		
		kill -9 ${pid[*]} >/dev/null 2>&1
		#killall -9 java >/dev/null
	
		sleep 2
		pid=(`ps -ef |grep -E "tomcat|java|jdk" |egrep -v 'egrep|tail|mgr_client'|awk '{print $2}'`)

		if [ "${pid[0]}" != "" ];then
			kill -9 ${pid[*]} >/dev/null 2>&1
			sleep 2
		fi
      	echo "`date |cut -d' ' -f2-5` start tomcat...">> $log_file
		rm -rf /usr/local/tomcat/work/*
		JAVA_HOME=/usr/local/java/jdk1.8.0_25
		export  JAVA_HOME
        bash /usr/local/tomcat/bin/startup.sh >/dev/null
}


function mysql_update(){
	tar -zxvf ${P_VERSION}-${Package}.${new_version}.tar.gz >/dev/null 2>&1
	tar -zxvPf ${P_VERSION}-${Package}.${new_version}.fort.tar.gz >/dev/null 2>&1
	if [[ $? -ne 0 ]]; then
		echo "`date|cut -d' ' -f2-5` tar details faild ">> $log_file
	fi
	if [ -e /$TMP/${P_VERSION}-${Package}.${new_version}.mysql.tar.gz ]; then
        		if [ ${ck_mysql} != 0 ];then
					echo "`date|cut -d' ' -f2-5` mysql udpate now ...">> $log_file
                	tar -zxvPf ${P_VERSION}-${Package}.${new_version}.mysql.tar.gz >/dev/null 2>&1
					if [ $? == 0 ];then	
						 mysql -umysql -p'm2a1s2u!@#' fort < /usr/local/tomcat/webapps/fort/WEB-INF/classes/update.sql >/dev/null 2>&1
						 #mysql -umysql -h127.0.0.1 -p'm2a1s2u!@#' fort < /usr/local/tomcat/webapps/fort/WEB-INF/classes/fortProcedure.sql >/dev/null 2>&1
					fi
					if [ $? == 0 ];then
               			 echo "`date|cut -d' ' -f2-5` mysql update done ...">> $log_file
               			 rm -rf ${P_VERSION}-${Package}.${new_version}.mysql.tar.gz
						# echo "success"
       			    else	
            		    echo "update mysql faild">> $log_file
						echo "faild"
						exit 1	
      			    fi
        		fi
	fi
	rm -rf ${P_VERSION}-${Package}.${new_version}.tar.gz
	#rm -rf ${P_VERSION}-${Package}.${new_version}.fort.tar.gz
}
function change_version(){
	echo $new_version >/var/lib/fort/version.sn
	nnn=`echo $new_version | awk -F. '{print $3}'`
	echo 100$nnn >>/var/lib/fort/version.sn
	echo "`date|cut -d' ' -f2-5` version change done ...">> $log_file
	echo "`date|cut -d' ' -f2-5` installation complete ...">> $log_file
	echo "success"
}


Main(){
sed -n -e '1,/^exit 0$/!p' $0 >"${TMP}/${P_VERSION}-${Package}.${new_version}.tar.gz"
cd $TMP
case $1 in 
1)
	check_services
	#=============地铁环境===============
	if [[ $anum -eq 2 ]]; then
		backup_tomcat
		tomcat_update
		if [[ $ck_mysql -ne 0 ]]; then
			mysql_update
		else
			echo "faild"
			echo "`date|cut -d' ' -f2-5` mysql not running ...">> $log_file
			exit 1
		fi
		
	fi
    #=====================================

    #=============标准版环境==============
	if [[ $anum -eq 0 ]]; then
		if [ "$Slave_IO_Running" = "Yes" -a "$Slave_SQL_Running" = "Yes" -a $hb -ne 0 ];then #双机环境
			ip_eth=`grep -v ^# /etc/ha.d/ha.cf | grep cast | awk '{print $2}'` #配置双机的网口
			#rsyn_ip=`grep -v ^# /etc/ha.d/ha.cf | grep cast | awk '{print $3}'` #备机IP
			backup_tomcat
			backup_mysql
			tomcat_update
			if [[ $ck_mysql -ne 0 ]]; then
				mysql_update
			else
				echo "faild"
				exit 1
			fi
			scp /usr/local/fort_nonsyn/config/concentrationManagement/patch/${P_VERSION}-${Package}.isomp.${new_version}.64 $Master_Host:/usr/local/fort_nonsyn/config/concentrationManagement/patch/${P_VERSION}-${Package}.isomp.${new_version}.64 > /dev/null
			cmd="bash /usr/local/fort_nonsyn/config/concentrationManagement/patch/${P_VERSION}-${Package}.isomp.${new_version}.64 5"
			ssh $Master_Host $cmd > /dev/null
		else #单机环境 
			backup_tomcat
			backup_mysql
			tomcat_update
			mysql_update
		fi
		
	fi
	#======================================

	#==========集群环境====================
	if [[ $anum -eq 1 ]]; then
		if [[ $ck_mysql -ne 0 ]]; then
			check_services
			backup_tomcat
			tomcat_update
			backup_mysql
			mysql_update
			change_version
		else
				echo "faild mysql not running"
				exit 1
		fi
		
		eth0=`ifconfig eth0 | grep "inet addr"|awk -F: '{print $2}'|awk -F" " '{print $1}'`
		eth1=`ifconfig eth1 | grep "inet addr"|awk -F: '{print $2}'|awk -F" " '{print $1}'`
		eth2=`ifconfig eth2 | grep "inet addr"|awk -F: '{print $2}'|awk -F" " '{print $1}'`
		eth3=`ifconfig eth3 | grep "inet addr"|awk -F: '{print $2}'|awk -F" " '{print $1}'`
		for ip in `cat $config_file|grep -E -v "$eth0|eth1|eth2|eth3"`
		do
			scp /usr/local/fort_nonsyn/config/concentrationManagement/patch/${P_VERSION}-${Package}.isomp.${new_version}.64 $ip:/usr/local/fort_nonsyn/config/concentrationManagement/patch/${P_VERSION}-${Package}.isomp.${new_version}.64 > /dev/null
			cmd="bash /usr/local/fort_nonsyn/config/concentrationManagement/patch/${P_VERSION}-${Package}.isomp.${new_version}.64 5"
			ssh $ip $cmd > /dev/null
		done
	fi
	#======================================
	change_version
	echo "standard upgrade">> $log_file
	;;
2)
	check_services
	#地铁环境
	if [[ $anum -eq 2 ]]; then
		backup_tomcat
		tomcat_update
	fi
	#标准版环境
	if [[ $anum -eq 0 ]]; then
		backup_tomcat
		backup_mysql
		tomcat_update
		mysql_update
	fi
	change_version
	echo "web_up">> $log_file
	;;
3)
	check_services
	if [[ $anum -eq 2 ]]; then
		
		if [[ $ck_mysql -ne 0 ]]; then
			backup_mysql
			mysql_update
		else
			echo "faild"
			exit 1
		fi
	fi

	change_version
	echo "mysql_main">> $log_file
	;;
4)	
	check_services
	change_version
	tar -zxvPf ${P_VERSION}-${Package}.${new_version}.tar.gz >/dev/null 2>&1
	tar -zxvPf ${P_VERSION}-${Package}.${new_version}.fort.tar.gz >/dev/null 2>&1
	if [[ $? -ne 0 ]]; then
		echo "`date|cut -d' ' -f2-5` tar details faild ">> $log_file
	fi
	echo "mysql_minor">> $log_file
	;;

5)
	check_services
	backup_tomcat
	backup_mysql
	tomcat_update
	change_version
esac 
}

Main $1
exit 0
