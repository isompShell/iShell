#!/bin/bash
#Title:change_ip.sh
#Usage:x
#Description:change cluster ip
#Author:jiahan
#Date:2016-10-26
#Version:1.0

#fort.appagent.conf=00
umount -l /var/log/simp_fort/session
CONFIG_FILE="/usr/local/bin/cluster_config.conf"
CONFIG_KEEP="/etc/keepalived/keepalived.conf"
#获取更改前的IP
BEFORE_IP=(`cat $CONFIG_FILE`)   #将之前IP转换为数组
#获取虚拟IP
BEFORE_VIP=`cat /etc/keepalived/keepalived.conf | grep virtual_server | awk '{print $2}'|uniq`
PAR_NUM=$#
FIR=$1
SEC=$2
THI=$3
FOUR=$4
#! /bin/bash
#检测IP是否合法
checkip() {
        if echo $1 |egrep -q '^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$' ; then
                a=`echo $1 | awk -F. '{print $1}'`
                b=`echo $1 | awk -F. '{print $2}'`
                c=`echo $1 | awk -F. '{print $3}'`
                d=`echo $1 | awk -F. '{print $4}'`

                for n in $a $b $c $d; do
                        if [ $n -ge 255 ] || [ $n -le 0 ]; then                             
                                echo "1"
                        fi
                done
        else
                echo "1"
        fi
}

chang_file(){
	if [ $PAR_NUM -eq 0 ];then
		while [[ true ]]; do
		VIP=($(whiptail --title "Change Virtual IP" --inputbox "要更改的VIP" 10 60  3>&1 1>&2 2>&3))
		if [[ $? -ne 0 ]]; then
				exit 0
		fi	
		
		if [[ `checkip $VIP` -eq 1 ]]; then
			whiptail --title "错误" --msgbox "Error.IP不合法" 10 60
		else
			break
		fi
	    done

		while [[ true ]]; do
			IP=($(whiptail --title "Change Ipaddress" --inputbox "要更改的IP" 10 60  3>&1 1>&2 2>&3))
			if [[ $? -ne 0 ]]; then
				exit 0
			fi
			COUNT=`echo "${IP[@]}" | awk '{print NF}'`   #用户输入的IP数量
			if [[ $COUNT -lt 3 ]]; then
				whiptail --title "错误" --msgbox "Error:输入IP少于三个" 10 60
				#continue
			elif [[ ${IP[0]} == ${IP[1]} || ${IP[0]} == ${IP[2]} || ${IP[1]} == ${IP[2]} ]]; then
				whiptail --title "错误" --msgbox "Error:IP不可相同" 10 60
				#continue
			elif [[ `checkip ${IP[0]}` -eq 1 || `checkip ${IP[1]}` -eq 1 || `checkip ${IP[2]}` -eq 1 ]]; then
				whiptail --title "错误" --msgbox "Error:IP不合法" 10 60
				#continue
			else
				break
			fi
		done
	else
		VIP=($FIR)
		IP=($SEC $THI $FOUR)
		COUNT=`echo "${IP[@]}" | awk '{print NF}'`
	fi
	

	
	
	#========判断IP的数量小于3=============
	#++++++++++++++++++++++++++++++++++++++++
	#=======IP不能相等=======================
	#++++++++++++++++++++++++++++++++++++++++
	#=====IP合法性===========================
	#++++++++++++++++++++++++++++++++++++++++
	
	rm -rf $CONFIG_FILE    #清空文件内容
	touch $CONFIG_FILE     #清空文件内容
	for((i=0;i<$COUNT;i++));
	do
		echo ${IP[$i]} >> $CONFIG_FILE;
	done
}

keepalived(){
	sed -i "s/$BEFORE_VIP/$VIP/g" $CONFIG_KEEP
	for((i=0;i<$COUNT;i++));
	do
		sed -i "/real_server/s/${BEFORE_IP[$i]}/${IP[$i]}/g" $CONFIG_KEEP;
		sed -i "s/${BEFORE_VIP}/${VIP}/g" /usr/local/bin/sh/tomcat_down_backup$i.sh;
		sed -i "s/${BEFORE_IP[$i]}/${IP[$i]}/g" /usr/local/bin/sh/tomcat_down_backup$i.sh;
	done	
}

sersync(){
	for((i=0;i<$COUNT;i++));
	do
		sed -i "/remote/s/${BEFORE_IP[$i]}/${IP[$i]}/g" /usr/local/GNU-Linux-x86/confxml_ca.xml;
		sed -i "/remote/s/${BEFORE_IP[$i]}/${IP[$i]}/g" /usr/local/GNU-Linux-x86/confxml_fort.xml;
		sed -i "/remote/s/${BEFORE_IP[$i]}/${IP[$i]}/g" /usr/local/GNU-Linux-x86/confxml_patch.xml;
		sed -i "/remote/s/${BEFORE_IP[$i]}/${IP[$i]}/g" /usr/local/GNU-Linux-x86/confxml_str.xml;
	done
}

change_mysql(){
	for((i=0;i<$COUNT;i++));
	do
		sed -i "/ndb-connectstring/s/${BEFORE_IP[$i]}/${IP[$i]}/g" /etc/my.cnf;
		sed -i "s/${BEFORE_IP[$i]}/${IP[$i]}/g" /usr/local/mysql/mysql-cluster/config.ini;
	done
}


magent_memcache(){
	MEM_IP=`awk -F: '/memcached/{print $2}' /usr/local/tomcat/conf/context.xml`
	sed -i "/memcachedNodes/s/$MEM_IP/127.0.0.1/g" /usr/local/tomcat/conf/context.xml
	LIP=`cat /usr/local/tomcat/webapps/fort/WEB-INF/classes/fort.properties  | grep memcached | grep -v ^# | awk -F[:=] '{print $2}'`
	LOIP=`cat /usr/local/tomcat/webapps/fort/WEB-INF/classes/fort.properties  | grep fort.local | grep -v ^# | awk -F= '{print $2}'`
	sed -i "/memcached/s/$LIP/127.0.0.1/g" /usr/local/tomcat/webapps/fort/WEB-INF/classes/fort.properties
	sed -i "/^fort.local/s/$LOIP/$LOCAL_IP/g" /usr/local/tomcat/webapps/fort/WEB-INF/classes/fort.properties
}


service_restart(){
#keepalived服务重启
/etc/init.d/keepalived restart

#sersync服务重启
killall -9 sersync2 >/dev/null
service rsync restart >/dev/null
/usr/local/GNU-Linux-x86/sersync2 -d -r -o /usr/local/GNU-Linux-x86/confxml_ca.xml
/usr/local/GNU-Linux-x86/sersync2 -d -r -o /usr/local/GNU-Linux-x86/confxml_fort.xml
/usr/local/GNU-Linux-x86/sersync2 -d -r -o /usr/local/GNU-Linux-x86/confxml_patch.xml
/usr/local/GNU-Linux-x86/sersync2 -d -r -o /usr/local/GNU-Linux-x86/confxml_str.xml

#数据库重启
killall -9 ndb_mgmd
killall -9 ndbd
rm -rf /usr/local/mysql/mysql-cluster/ndb*

#magent服务重启
killall -9 magent
magent -u root -p 12000 -s 127.0.0.1:11211 -b 127.0.0.1:12001
magent -u root -p 12001 -s ${EXP_IP[0]}:11211 -b ${EXP_IP[1]}:11211
sed -i '/magent/d' /usr/local/bin/sh/start.sh
sed -i '/ifconfig/d' /usr/local/bin/sh/start.sh
ifconfig lo:0 $VIP broadcast $VIP netmask 255.255.255.255 up
stop_tomcat.sh
start_tomcat.sh
echo "ifconfig lo:0 $VIP broadcast $VIP netmask 255.255.255.255 up" >>/usr/local/bin/sh/start.sh
echo "magent -u root -p 12000 -s 127.0.0.1:11211 -b 127.0.0.1:12001" >>/usr/local/bin/sh/start.sh
echo "magent -u root -p 12001 -s ${EXP_IP[0]}:11211 -b ${EXP_IP[1]}:11211" >>/usr/local/bin/sh/start.sh
ps -ef | grep mysql | egrep -v "grep|ndb" |awk '{print $2}'| xargs kill -9
/etc/init.d/mysql start
}


appagent(){
	#NUMBER=`cat /usr/local/tomcat/webapps/fort/WEB-INF/classes/fort.properties | grep appagent | grep -v ^# | awk -F= '{print $2}'`
	
	for((i=0;i<$COUNT;i++));
	do
		SIP=`cat /etc/simp_fort/conf/sso_channel/0$i.conf | grep ip | awk -F= '{print $2}'`
		sed -i "s/$SIP/${IP[$i]}/g" /etc/simp_fort/conf/sso_channel/0$i.conf;
	done
}

chang_file
#本机IP
LOCAL_IP=`ifconfig eth0 | grep "inet addr"|awk -F: '{print $2}'|awk '{print $1}'`
##本机以外的IP
EXP_IP=(`cat $CONFIG_FILE | grep -v $LOCAL_IP`)
keepalived
sersync
change_mysql
magent_memcache
appagent
service_restart