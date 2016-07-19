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
	$ck=`ps -ef | grep $1 | grep -v grep | wc -l`
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
	else
		echo "`date |cut -d' ' -f2-5` mysql running....">> $log_file
		echo " ------------local configuration checking done------------- ">> $log_file
	fi
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
		echo "`date|cut -d' ' -f2-5` tar  tar details faild faild ">> $log_file
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
			sleep 1
		fi
      		echo "`date |cut -d' ' -f2-5` start tomcat...">> $log_file
		rm -rf /usr/local/tomcat/work/*
        bash /usr/local/tomcat/bin/startup.sh >/dev/null
}


function mysql_update(){
	tar -zxvf ${P_VERSION}-${Package}.${new_version}.tar.gz >/dev/null 2>&1
	tar -zxvPf ${P_VERSION}-${Package}.${new_version}.fort.tar.gz >/dev/null 2>&1
	if [[ $? -ne 0 ]]; then
		echo "`date|cut -d' ' -f2-5` tar  tar details faild faild ">> $log_file
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
	echo $anum
	if [[ $anum -eq 2 ]]; then
		backup_tomcat
		tomcat_update
		mysql_update
	fi
	if [[ $anum -eq 0 ]]; then
		backup_tomcat
		backup_mysql
		tomcat_update
		mysql_update
	fi
	#mysql_update
	change_version
	echo "standard upgrade">> $log_file
	;;
2)
	check_services
	if [[ $anum -eq 2 ]]; then
		backup_tomcat
		tomcat_update
	fi
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
		backup_mysql
		mysql_update
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
esac 
}

Main $1
exit 0
