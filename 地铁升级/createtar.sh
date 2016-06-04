#!/bin/bash

#Title:createtar1.sh
#Usage:根据提示输入相关信息
#Description:tar
#Author:jiahan
#Date:2016-06-03
#Version:1.0

P_VERSION="0x4D01"
Package="fort-service"
NEW_VERSION="1.0.1"
update_tomcat(){
	read -p "要升级的TOMCAT文件数量？" UPDATE_COUNT
	if [ $UPDATE_COUNT == 0 ];then
		update_mysql;
	fi
	for i in `seq 1 $UPDATE_COUNT`
	do
		read -p "要升级的TOMCAT文件路径？" UPDATE_PATH
		TOMCAT_TARFILE+=$UPDATE_PATH" "
	done
	tar -zcvPf $P_VERSION-$Package.tomcat.tar.gz $TOMCAT_TARFILE >/dev/null
	if [ $? == 0 ];then
		echo "tomcat打包成功"
	else 
		echo "tomcat打包失败，请重新打包"
	fi
}

update_mysql(){
	read -p "要升级的SQL文件数量？" UPDATE_COUNT_MYSQL
	if [ $UPDATE_COUNT_MYSQL == 0 ];then
		tar -zcvf ${P_VERSION}-${Package}.${NEW_VERSION}.tar.gz $P_VERSION-$Package.tomcat.tar.gz >/dev/null
		cat extracttar.sh ${P_VERSION}-${Package}.${NEW_VERSION}.tar.gz >${P_VERSION}-${Package}.${NEW_VERSION}.bin
 	        rm ${P_VERSION}-${Package}.${NEW_VERSION}.tar.gz >/dev/null
		rm $P_VERSION-$Package.tomcat.tar.gz >/dev/null
	        rm $P_VERSION-$Package.mysql.tar.gz >/dev/null 2>&1
		exit 0


	fi
	for i in `seq 1 $UPDATE_COUNT_MYSQL`
	do
		read -p "要升级的SQL文件路径？" UPDATE_PATH
		MySQL_TARFILE+=$UPDATE_PATH" "
	done
	tar -zcvPf $P_VERSION-$Package.mysql.tar.gz $MySQL_TARFILE >/dev/null
	if [ $? == 0 ];then
        	echo "mysql打包成功"
	else
        	echo "mysql打包失败，请重新打包"
	fi
	if [ $UPDATE_COUNT == 0 ];then
                tar -zcvf ${P_VERSION}-${Package}.${NEW_VERSION}.tar.gz $P_VERSION-$Package.mysql.tar.gz >/dev/null
		cat extracttar.sh ${P_VERSION}.${Package}.${NEW_VERSION}.tar.gz >${P_VERSION}.${Package}.${NEW_VERSION}.bin
		rm ${P_VERSION}.${Package}.${NEW_VERSION}.tar.gz >/dev/null
                rm $P_VERSION-$Package.tomcat.tar.gz >/dev/null
                rm $P_VERSION-$Package.mysql.tar.gz >/dev/null
		exit 0
	fi
}

Main(){
	update_tomcat;
	update_mysql;
	tar -zcvf ${P_VERSION}-${Package}.${NEW_VERSION}.tar.gz $P_VERSION-$Package.tomcat.tar.gz $P_VERSION-$Package.mysql.tar.gz >/dev/null
	cat extracttar.sh ${P_VERSION}-${Package}.${NEW_VERSION}.tar.gz >${P_VERSION}.${Package}.${NEW_VERSION}.bin
	if [ $? == 0 ];then
		echo "bin包成功: ${P_VERSION}.${Package}.${NEW_VERSION}.bin"
	fi
	rm ${P_VERSION}-${Package}.tomcat.tar.gz >/dev/null
	rm ${P_VERSION}-${Package}.mysql.tar.gz >/dev/null
	rm ${P_VERSION}-${Package}.${NEW_VERSION}.tar.gz >/dev/null
}
Main;
