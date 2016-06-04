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

version_num=`cat /var/lib/fort/version.sn | head -n1 | awk -F. '{print $3}'` #提取版本号最后一位
if [ $version_num != 0 ];then
	let last_version_num=$version_num-1
fi
let next_version_num=$num+1
NOW_VERSION=`cat /var/lib/fort/version.sn | head -n1`  #当前版本号
LAST_VERSION=`sed -n 1s/.$/$((last_version_num))/p /var/lib/fort/version.sn` #上一版本号
UPDATE_VERSION=`sed -n 1s/.$/$((next_version_num))/p /var/lib/fort/version.sn` #要升级版本号（下一版本号）
Package_name=`echo "$3" | awk -F- '{print $3}' | awk -F. '{print $2"."$3"."$4}'` #包名版本
P_VERSION="0x4D01"
Package="fort-service"
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



function uninstall_fort()
{
if [ -e /var/lib/fort/backup/fort-service_${LAST_VERSION}_new ];then
            for file in `find /var/lib/fort/backup/fort-service_${LAST_VERSION}_new/${LAST_VERSION}.tomcat.tar.gz  -type  f 2>/dev/null`
             	do
              		if [ -f $file ];then
                 		rm -rf $web_fort
                 		rm -rf $local_fort
                 		rm -rf $soft_fort
                 		rm -rf $soft1_fort
                 		rm -rf $sh_fort
                 		sleep 1
                 		chmod 755 $file 2>/dev/null
                 		tar -zxvPf $file
             		 else
                 		echo failed
                 		exit 1
             		fi
            	done
          fi
 #tomcat服务重启
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

case $1 in 
    detail)
           cat /var/lib/fort/control_${NOW_VERSION}|grep Name|sed 's/$/_a_/g'
           cat /var/lib/fort/control_${NOW_VERSION}|grep Description|sed 's/$/_a_/g'
           cat /var/lib/fort/version.sn|head -n1|sed 's/$/_a_/g'

         ;;
    install)
	    if [ $Package_name==$NOW_VERSION+1 ]
          if [ -e /usr/local/fort_nonsyn/config/concentrationManagement/patch ];then
            for file in `find /usr/local/fort_nonsyn/config/concentrationManagement/patch/${P_VERSION}-${Package}.${UPDATE_VERSION}.bin -type f`
             do
               if [ -f $file ];then
                 chmod 777 $file 2>/dev/null
                 bash $file $2 2>/dev/null
               else
                 echo failed
                 exit 1
               fi
            done
          fi
		else
			echo "faild"
		fi



  	;;
    uninstall)
		 if [ $version_num=0 ];then
				echo "初始版本不能升级卸载"
				exit 1
		 fi
           uninstall_fort
		num=`awk -F. '{print $3}'` /var/lib/fort/version.sn
		let num=$num-1
                sed -i 1s/.$/$((num))/ /var/lib/fort/version.sn
                sed -i 2s/.$/$((num-1))/ /var/lib/fort/version.sn
         ;;
esac
