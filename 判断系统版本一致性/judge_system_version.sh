#!/bin/bash         
#
#Name		:judge version
#Version	:1.0.0
#Release	:
#Architecture	:x86,x86_64
#Date		:2015-11-27 11:00
#Release By	:jiahan@sbr-info.com
#Summary	:for auto judge system version
#Description	:this script has testing with debian 7.5.
#Notice		:         
fort_ip=$1
#fort_pwd='abc'
expect <<EOF >/dev/null 2&>1
    spawn ssh root@$fort_ip 
    expect  { 
        "*yes/no*" {exp_send "yes\n";exp_continue} 
        "*password:" {exp_send "$fort_pwd\n"}
        }
    expect "*#" {
        send "cat /var/lib/fort/version.sn>/root/a.txt\n"
        send "cat /etc/hostname>>/root/a.txt\n"
        
    } 
        
    spawn scp root@$fort_ip:/root/a.txt .
    expect  { 
        "*yes/no*" {exp_send "yes\n";exp_continue} 
        "*password:" {exp_send "$fort_pwd\r"}
        }
expect eof
EOF
cat /var/lib/fort/version.sn>b.txt
cat /etc/hostname>>b.txt
bei=`sed -n 1p a.txt`
zhu=`sed -n 1p b.txt`
host_bei=`sed -n 2p a.txt`
host_zhu=`sed -n 2p b.txt`

if [ $zhu == $bei ];then
        echo 1
else
        echo  $host_zhu $zhu
		echo  $host_bei $bei
fi
rm -rf a.txt b.txt