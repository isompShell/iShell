#!/bin/bash

while:
do
    #������ڵ��Ƿ��Ѿ�����
    nc -w 10 -z 127.0.0.1 1186 > /dev/null 2>&1
    #ndb_mgmd=`echo $?`
    #lsof -i:1186
    if [ $? -eq 0 ];then
    #����ڵ�����������£�������ݽڵ��sql�ڵ㡣
    #������ݽڵ�δ�������������ݽڵ㣬������mysqld���������κβ�����
        ndbd_num=`ps -C ndbd --no-header | wc -l`
        if [ $ndbd_num -eq 0 ];then
          /usr/local/mysql/bin/ndbd
          #sleep 20
          #killall -s SIGKILL mysql
          #service mysql start
        fi

    else
    #����ڵ�δ���������ڵ�ҵ���ʱ�򣬹ر����ݽڵ�
      ndb_mgmd -f /usr/local/mysql/mysql-cluster/config.ini --configdir=/usr/local/mysql/mysql-cluster --reload
          #ndbd_num=`ps -C ndbd --no-header | wc -l`
      #if [ $ndbd_num != 0 ];then
        #killall -s SIGKILL ndbd
      #fi
    fi
    sleep 5
done
