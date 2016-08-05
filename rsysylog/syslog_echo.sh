#!/bin/bash
today=`date +%Y_%m_%d`
day=`date +%T`
lh=`cat /var/log/isomp_syslog/$today/isomp_syslog.log|grep "+"|tail -n1`
sed -n "/$lh/,500000p" /var/log/isomp_syslog/$today/isomp_syslog.log
echo "$day +," >> /var/log/isomp_syslog/$today/isomp_syslog.log
#cat /var/log/isomp_syslog/$today/isomp_syslog.log
