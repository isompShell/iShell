#!/bin/bash

while:
do
    #检测管理节点是否已经启动
    nc -w 10 -z 127.0.0.1 1186 > /dev/null 2>&1
    #ndb_mgmd=`echo $?`
    #lsof -i:1186
    if [ $? -eq 0 ];then
    #管理节点启动的情况下，检测数据节点和sql节点。
    #如果数据节点未启动，启动数据节点，并重启mysqld。否则不做任何操作。
        ndbd_num=`ps -C ndbd --no-header | wc -l`
        if [ $ndbd_num -eq 0 ];then
          /usr/local/mysql/bin/ndbd
          #sleep 20
          #killall -s SIGKILL mysql
          #service mysql start
        fi

    else
    #管理节点未启动或管理节点挂掉的时候，关闭数据节点
      ndb_mgmd -f /usr/local/mysql/mysql-cluster/config.ini --configdir=/usr/local/mysql/mysql-cluster --reload
          #ndbd_num=`ps -C ndbd --no-header | wc -l`
      #if [ $ndbd_num != 0 ];then
        #killall -s SIGKILL ndbd
      #fi
    fi
    sleep 5
done
