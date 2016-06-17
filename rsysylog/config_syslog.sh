#!/bin/bash
#Title:config_syslog.sh
#Usage:
#Description:add ip syslog
#Author:jiahan
#Date:2016-06-17
#Version:1.0
rm -rf /etc/rsyslog.d/b.conf
type2="windows2003"
type3="windows2008"
type4="linux"
type5="net"
#aa="192.168.23.1,windows/192.168.23.2,linux/192.168.23.3,net"
ip_type=$1
ip=`echo $ip_type|awk -F'/'  '{for(i=1;i<=NF;i++) print $i}'`
typea=`echo $ip_type|awk -F[,/]  '{for(i=2;i<=NF;i+=2) print $i}'`

for ip in $ip
do
	ip1=`echo $ip|awk -F, '{print $1}'`
	type1=`echo $ip | awk -F, '{print $2}'`
	if [ $type1 == $type2 ];then
		echo '$ModLoad imudp' >>/etc/rsyslog.d/b.conf
		echo '$UDPServerRun 514' >>/etc/rsyslog.d/b.conf
		echo ":fromhost,isequal,"$ip1" /var/log/win.log/aaa/$ip1" >>/etc/rsyslog.d/b.conf
		echo "$ ~" >>/etc/rsyslog.d/b.conf
	fi

	if [ $type1 == $type3 ];then
		echo '$ModLoad imudp' >>/etc/rsyslog.d/b.conf
		echo '$UDPServerRun 514' >>/etc/rsyslog.d/b.conf
		echo ":fromhost,isequal,"$ip1" /var/log/win.log/bbb/$ip1" >>/etc/rsyslog.d/b.conf
		echo "$ ~" >>/etc/rsyslog.d/b.conf
	fi
	if [ $type1 == $type4 ];then
		echo '$ModLoad imudp' >>/etc/rsyslog.d/b.conf
		echo '$UDPServerRun 514' >>/etc/rsyslog.d/b.conf
		echo ":fromhost,isequal,"$ip1" /var/log/unix.log/$ip1" >>/etc/rsyslog.d/b.conf
		echo "$ ~" >>/etc/rsyslog.d/b.conf
	fi

	if [ $type1 == $type5 ];then
		echo '$ModLoad imudp' >>/etc/rsyslog.d/b.conf
		echo '$UDPServerRun 514' >>/etc/rsyslog.d/b.conf
		echo ":fromhost,isequal,"$ip1" /var/log/net/log/$ip1" >>/etc/rsyslog.d/b.conf
		echo "$ ~" >>/etc/rsyslog.d/b.conf
	fi
done
