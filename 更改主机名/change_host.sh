#!/bin/bash
#----------------------------------------------------|
#Date     :2016/06/17
#Author   :Alger
#Mail     :alger_bin@foxmail.com
#Function :this script change system hostname&hosts
#Version  :1.0
#----------------------------------------------------|
Hosts=$1

echo $1 >/etc/hostname
HOST=`cat -A  /etc/hosts| grep '127.0.0.1'| awk -F ^ '{print$2}' |grep -v 'localhost' |cut -f 2 -d "I" |cut -f 1 -d "$"`
sed -i "/$HOST/s/$HOST/$1/" /etc/hosts

if [ $? == 0 ];
then
/etc/init.d/hostname.sh
echo "|---------change hosts&&hostname Done "
else
echo "|---------change hosts&&hostname Failed"
fi
