#!/bin/bash
#------------------------------------------------------
#Filename:     check_disk.sh
#Revision:     1.1
#Date:         2015/09/17
#Author:       liuhao
#Description:  Check disk and send email
#------------------------------------------------------


DISK_MAIL=/root/check_disk/disk_mail 
DISK=`/bin/df --total|grep -i 'total'|awk '{print $5}'|tr -d "%"`
DISK_USE=`cat $DISK_MAIL|awk -F , '{ print $1 " -c " $2 " -c " $3 " -c " $4" -c " $5" -c "$6 " -c "$7" -c "$8" -c "$9}'`

if [ $DISK -ge "90" ];then

echo "Storage space and Already exceeded $DISK" | mail -s "Disk Warning" $DISK_USE

fi


