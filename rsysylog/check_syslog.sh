#!/bin/bash
#---------------------------------------------------
#Filename:              check_syslog.sh
#Revision:              1.1
#Date:                  2016/01/21
#Author:                liuhao
#Descriptiik on:           收集分析日志
#---------------------------------------------------
#global
today=`date +%Y_%m_%d`
year=`date +%Y`
#mkdir -p ${logs_path}/$today
#unix syslog   
  if [ -e /var/log/unix.log ];then
     for file in `ls /var/log/unix.log/`
         do
            cat /var/log/unix.log/$file|grep sshd|grep Accepted >/var/log/unix.log/$file.test.log
            cat /var/log/unix.log/$file.test.log|awk -F " " '{print " "$1" "$2" "$3"|"$4"|"$9"|"$11}'|sed  "s/$/|$file,/g"|sed "s/^/$year/g" >>/var/log/isomp_syslog/$today/isomp_syslog.log
            rm -rf /var/log/unix.log/$file.test.log
         done
  fi
#windows syslog
 if [ -e /var/log/win.log ];then
     for file in `ls /var/log/win.log/bbb/` 
         do 
            cat /var/log/win.log/bbb/$file|grep "已成功登录帐户" >/var/log/win.log/bbb/$file.test.log
            cat /var/log/win.log/bbb/$file.test.log|awk '/帐户名/ {for(i=1;i<=NF;i++) if($i ~ /帐户名/) for(o=1;o<=NF;o++) if($o ~ /源网络地址/)  print " "$1" "$2" "$3"|" "n" "|"$(i+1)"|"$(o+1)}'|sed /WIN/d|sed /-/d|sed "s/$/|$file,/g"|sed "s/^/$year/g" >>/var/log/isomp_syslog/$today/isomp_syslog.log
            rm -rf /var/log/win.log/bbb/$file.test.log
         done
     for i in `ls /var/log/win.log/bbb/` 
         do
           cat /var/log/win.log/bbb/$i|grep "successfully logged on" >/var/log/win.log/bbb/$i.test.log
            cat /var/log/win.log/bbb/$i.test.log|awk '/Account/ {for(i=1;i<=NF;i++) if($i ~ /Account/) for(o=1;o<=NF;o++) if($o ~ /Source/)  print " "$1" "$2" "$3"|" "n" "|"$(i+2)"|"$(o+3)}'|sed /WIN/d|sed /-/d|sed /WOR/d|sed /Detailed/d|sed "s/$/|$i,/g"|sed "s/^/$year/g" >>/var/log/isomp_syslog/$today/isomp_syslog.log 
           rm -rf /var/log/win.log/bbb/$i.test.log
         done        
 fi 
 if [ -e /var/log/win.log ];then
     for file in `ls /var/log/win.log/aaa/` 
         do 
            cat /var/log/win.log/aaa/$file|grep "登录成功" >/var/log/win.log/aaa/$file.test.log
            cat /var/log/win.log/aaa/$file.test.log|awk '/用户名/ {for(i=1;i<=NF;i++) if($i ~ /用户名/) for(o=1;o<=NF;o++) if($o ~ /源网络地址/)  print " "$1" "$2" "$3"|" "n" "|"$(i+1)"|"$(o+1)}'|sed /WIN/d|sed /-/d|sed "s/$/|$file,/g"|sed "s/^/$year/g" >>/var/log/isomp_syslog/$today/isomp_syslog.log
            rm -rf /var/log/win.log/aaa/$file.test.log
         done
     for file in `ls /var/log/win.log/aaa/`
         do
           cat /var/log/win.log/aaa/$file|grep "Logged on user:" >/var/log/win.log/aaa/$file.test.log
            cat /var/log/win.log/aaa/$file.test.log|awk '/Target/ {for(i=1;i<=NF;i++) if($i ~ /Target/) for(o=1;o<=NF;o++) if($o ~ /Source/)  print " "$1" "$2" "$3"|" "n" "|"$(i+3)"|"$(o+3)}'|sed /AUDIT_SUCCESS/d|sed /-/d|sed /Target/d|sed /localhost/d|sed "s/$/|$file,/g"|sed "s/^/$year/g" >>/var/log/isomp_syslog/$today/isomp_syslog.log
           rm -rf /var/log/win.log/aaa/$file.test.log
         done
 fi
#net syslog
  if [ -e /var/log/net.log ];then
     for file in `ls /var/log/net.log/`
         do
           cat /var/log/net.log/$file|grep LOGIN|grep -v "failed" >/var/log/net.log/$file.test.log
           cat /var/log/net.log/$file.test.log|awk -F" " '{print " "$1" "$2" "$3"|"$4"|"$6,$7"|"$9,$10}'|sed 's/login//g'|sed 's/%%10SHELL\/4\/LOGIN(l)://g'|sed 's/from//g'|sed "s/$/|$file,/g"|sed "s/^/$year/g" >>/var/log/isomp_syslog/$today/isomp_syslog.log
           rm -rf /var/log/net.log/$file.test.log
         done
  fi
#syslog cut
# declare logs_path="/var/log/isomp_syslog";
# #declare need_delete_path=${logs_path}/$(date -d "7 days ago" "+%Y_%m_%d");
# declare yestoday_log_path=${logs_path}/$(date -d "yesterday" "+%Y_%m_%d");
 #rm -rf ${need_delete_path}
 #rm -rf ${yestoday_log_path}
# mv ${logs_path}/$today ${yestoday_log_path}
# mkdir -p ${logs_path}/$today

rm -rf /var/log/unix.log/*
rm -rf /var/log/win.log/aaa/*
rm -rf /var/log/win.log/bbb/*
rm -rf /var/log/net.log/*
/etc/init.d/rsyslog restart
