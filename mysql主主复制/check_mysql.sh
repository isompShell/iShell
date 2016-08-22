#!/bin/bash
while true
do
num=`ps aux | grep mysqld | grep -v grep | wc -l` >/dev/null
if [[ $num -ne 0 ]]               # 如果过滤有mysql进程会返回0则认为mysql存活
then
    sleep 3                     # 使脚本进入休眠
else
    /etc/init.d/mysql start
    ps aux | grep mysqld | grep -v grep > /dev/null
    if [[ $? -eq 0 ]]
    then
        pkill heartbeat
    fi
fi
done