#!/bin/bash
#------------------------------------------------
#Filename:	node_patch_management.sh
#Revision:	1.0
#Date:		2016/04/15
#Author:	liuhao
#Description:	config and management tar package
#------------------------------------------------
#Version 1.0
#The first one,config and management tar package
#PackeageName: 0x4D01-fort-service.isomp.1.0.1.64

version_num=`cat /var/lib/fort/version.sn | head -n1 | awk -F. '{print $3}'` #提取版本号最后一位
if [ $version_num != 0 ];then
	let last_version_num=$version_num-1      #上一版本号最后一位
fi
let next_version_num=$version_num+1        #要升级版本号最后一位
NOW_VERSION=`cat /var/lib/fort/version.sn | head -n1`  #当前版本号
LAST_VERSION=`sed -n 1s/.$/$((last_version_num))/p /var/lib/fort/version.sn` #上一版本号
let aaa=`echo $NOW_VERSION | awk -F. '{print $3}'`+1
UPDATE_VERSION="1.0.$aaa"
#UPDATE_VERSION=`sed -n 1s/.$/$((next_version_num))/p /var/lib/fort/version.sn` #要升级版本号（下一版本号）
Package_name=`echo "$3" | awk -F- '{print $3}' | awk -F. '{print $3"."$4"."$5}'` #包名版本
Package_name_tail=`echo "$3" | awk -F- '{print $3}' | awk -F. '{print $5}'` 
P_VERSION="0x4D01"
Package="fort-service.isomp"
admin_dir="/var/lib/fort/"
backup_dir="${admin_dir}backup/"
backup_version="${admin_dir}${Package}/"
backup_version="${admin_dir}${Package}/"
version_file="${backup_version}version"
datetime=`date +"%Y%m%d%N"`
backup_tar="${backup_dir}${Package}_${new_version}_new/"
web_fort="/usr/local/tomcat/webapps/fort"
local_fort="/usr/local/fort"
soft0_fort="/usr/local/soft9100"
soft1_fort="/usr/local/soft9101"
sh_fort="/usr/local/bin"
ssh_fort="/usr/local/sbin"
log_name="forts.log"
log_file="/var/log/$log_name"



function uninstall_fort()
{
mysql -umysql -p'm2a1s2u!@#' fort </var/lib/fort/backup/fort-service_${NOW_VERSION}_new/delete.sql >/dev/null 2>&1
mysql -umysql -p'm2a1s2u!@#' fort </var/lib/fort/backup/fort-service_${NOW_VERSION}_new/sqlbackup_${NOW_VERSION}.sql >/dev/null 2>&1
if [ -e /var/lib/fort/backup/fort-service_${NOW_VERSION}_new ];then
            for file in `find /var/lib/fort/backup/fort-service_${NOW_VERSION}_new/${NOW_VERSION}.tomcat.tar.gz  -type  f >/dev/null`
             	do
              		if [ -f $file ];then
						echo "`date |cut -d' ' -f2-5` stop tomcat..."|tee -a $log_file
						bash /usr/local/tomcat/bin/shutdown.sh >/dev/null 2>&1
						sleep 2
                 		rm -rf $web_fort
                 		rm -rf $local_fort
                 		rm -rf $soft0_fort
                 		rm -rf $soft1_fort
                 		rm -rf $sh_fort
						rm -rf $ssh_fort
						echo "tomcat uninstall now "|tee -a $log_file >/dev/null 2>&1

						
                 		chmod 755 $file >/dev/null 2>&1
                 		tar -zxvPf $file >/dev/null 2>&1
						echo "tomcat uninstall done "|tee -a $log_file >/dev/null 2>&1
						#mysql -umysql -p'm2a1s2u!@#' fort </var/lib/fort/backup/fort-service_${NOW_VERSION}_new/delete.sql
						#mysql -umysql -p'm2a1s2u!@#' fort < sqlbackup_delete_$NOW_VERSION.sql
						echo "mysql unistall now "|tee -a $log_file >/dev/null 2>&1
						#mysql -umysql -p'm2a1s2u!@#' fort </var/lib/fort/backup/fort-service_${NOW_VERSION}_new/sqlbackup_${NOW_VERSION}.sql >/dev/null 2>&1
						echo "mysql unistall done "|tee -a $log_file >/dev/null 2>&1
             		 #else
                 		#echo "failed"
						#echo "unistall failed:上一版本文件不存在 /var/lib/fort/backup/fort-service_${NOW_VERSION}_new/${NOW_VERSION}.tomcat.tar.gz "|tee -a $log_file
                 		#exit 1
             		fi
            done
	#echo "failed"
	#echo "uninstall:faild备份目录不存在 /var/lib/fort/backup/fort-service_${NOW_VERSION}_new"|tee -a $log_file >/dev/null 2>&1
	#exit 1
fi


                pid=(`ps -ef 2>/dev/null|grep -E "tomcat|java|jdk" |egrep -v 'egrep|tail'|awk '{print $2}'`)

                kill -9 ${pid[*]} >/dev/null
                killall -9 java >/dev/null

                pid=(`ps -ef 2>/dev/null|grep -E "tomcat|java|jdk" |egrep -v 'egrep|tail'|awk '{print $2}'`)

                if [ "${pid[0]}" != "" ];then
                        kill -9 ${pid[*]} >/dev/null
                fi
                echo "`date |cut -d' ' -f2-5` start tomcat..."|tee -a $log_file
                rm -rf /usr/local/tomcat/work/*
                bash /usr/local/tomcat/bin/startup.sh >/dev/null

}

case $1 in 
    detail)
		   one=`cat /var/lib/fort/control_$2|grep Description|sed 's/$/_a_/g'`
		   echo $one
		   two=`cat /var/lib/fort/control_$2|grep id|sed 's/$/_a_/g'`
		   echo $two
		   three=`cat /var/lib/fort/control_$2|grep PA|sed 's/$/_a_/g'`
		   echo $three
		   four=`cat /var/lib/fort/control_$2|grep WS|sed 's/$/_a_/g'`
		   echo $four
           five=`cat /var/lib/fort/control_$2|grep Name|sed 's/$/_a_/g'`
           echo $five
           #echo $2|sed 's/$/_a_/g'

         ;;
    status)
			#package_version=`echo $Package_name | awk -F. '{print $3}'`
			package_version=`echo "$2" | awk -F- '{print $3}' | awk -F. '{print $5}'`
			if [[ $version_num -ge $package_version ]]; then
				echo "successed"
			else
				echo "failed"
			fi
		 ;;
	remove)
			Package_name=`echo "$2" | awk -F- '{print $3}' | awk -F. '{print $3"."$4"."$5}'`
			rm -rf "/usr/local/fort_nonsyn/config/concentrationManagement/patch/${P_VERSION}-${Package}.${Package_name}.64"
			if [ -e "/usr/local/fort_nonsyn/config/concentrationManagement/patch/${P_VERSION}-${Package}.${Package_name}}.64" ];then
				echo "failed"
			else
				echo "successed"
			fi
		;;
    install)
		if [[ $Package_name_tail -le $version_num ]]; then
			echo "already install"
			exit 1
		fi
		
	    if [ $Package_name == $UPDATE_VERSION ];then   #判断包名版本号是否等于当前版本号加1
          if [ -e /usr/local/fort_nonsyn/config/concentrationManagement/patch ];then
            for file in `find /usr/local/fort_nonsyn/config/concentrationManagement/patch/${P_VERSION}-${Package}.${UPDATE_VERSION}.64 -type f`
             do
               if [ -f $file ];then
                 chmod 777 $file >/dev/null
                 bash $file $2
				 if [ $? -eq 0 ];then
					rm -rf /root/*.tar.gz
					sed -i -e 2d /var/lib/fort/version.sn
					if [ $next_version_num -lt 10 ];then
						#echo "$LAST_VERSION--->$100$next_version_num"|tee -a $log_file
						echo "100$next_version_num" >>/var/lib/fort/version.sn
					elif [ $next_version_num  -lt 100 ];then
						#echo "$LAST_VERSION--->$10$next_version_num"|tee -a $log_file
						echo "10$next_version_num" >>/var/lib/fort/version.sn
					elif [ $next_version_num  -lt 1000 ];then
						#echo "$LAST_VERSION--->$1$next_version_num"|tee -a $log_file
						echo "1$next_version_num" >>/var/lib/fort/version.sn
					fi
				 fi
               else
				 echo "/usr/local/fort_nonsyn/config/concentrationManagement/patch/${P_VERSION}-${Package}.${UPDATE_VERSION}.64 not found"
				 echo "failed"
                 exit 1
               fi
            done
          fi
		else
			echo "Version dependent problem"|tee -a $log_file
			echo "failed"
			exit 1
		fi
	


  	;;
    uninstall)
		 if [ $version_num == 0 ];then
				echo "初始版本不能升级卸载"|tee -a $log_file >/dev/null 2>&1
				exit 1
		 fi
        uninstall_fort
		if [ $? == 0 ];then
		echo "$NOW_VERSION--->$LAST_VERSION"|tee -a $log_file >/dev/null 2>&1
		num=`awk -F. '{print $3}' /var/lib/fort/version.sn`
		let num=$num-1
                echo $LAST_VERSION  >/var/lib/fort/version.sn
				nnn=`echo $LAST_VERSION | awk -F. '{print $3}'`
				echo 100$nnn >>/var/lib/fort/version.sn
				echo "success"
		else
				echo "failed"
		fi
         ;;
esac
