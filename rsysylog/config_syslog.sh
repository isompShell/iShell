#!/bin/bash
#Title:config_syslog.sh
#Usage:
#Description:add ip syslog
#Author:jiahan
#Date:2016-06-17
#Version:1.0
rm -rf /etc/rsyslog.d/b.conf
type2="WindowsServer2003"
type3="WindowsServer2008"
type4="Unix/Linux资源"
type5="网络设备"
type6="WindowsServer2012"
#aa="192.168.23.1,Windows Server 2003;192.168.23.2,Windows Server 2008;192.168.23.3,Unix/Linux资源;192.168.23.10,网络设备"
ip_type=`echo $1 | sed s/[[:space:]]//g`
ip=`echo $ip_type|awk -F';'  '{for(i=1;i<=NF;i++) print $i}'`    #192.168.23.1,Windows Server 2003 192.168.23.2,linux

for ip in $ip
do
	ip1=`echo $ip|awk -F, '{print $1}'`
	type1=`echo $ip|awk -F, '{print $2}'`
	if [ "$type1" == $type2 ];then
		echo '$ModLoad imudp' >>/etc/rsyslog.d/b.conf
		echo '$UDPServerRun 514' >>/etc/rsyslog.d/b.conf
		echo ":fromhost,isequal,"$ip1" /var/log/win.log/aaa/$ip1" >>/etc/rsyslog.d/b.conf
		echo "$ ~" >>/etc/rsyslog.d/b.conf
	fi

	if [ "$type1" == $type3 ];then
		echo '$ModLoad imudp' >>/etc/rsyslog.d/b.conf
		echo '$UDPServerRun 514' >>/etc/rsyslog.d/b.conf
		echo ":fromhost,isequal,"$ip1" /var/log/win.log/bbb/$ip1" >>/etc/rsyslog.d/b.conf
		echo "$ ~" >>/etc/rsyslog.d/b.conf
	fi
	
	if [ "$type1" == $type6 ];then
		echo '$ModLoad imudp' >>/etc/rsyslog.d/b.conf
		echo '$UDPServerRun 514' >>/etc/rsyslog.d/b.conf
		echo ":fromhost,isequal,"$ip1" /var/log/win.log/bbb/$ip1" >>/etc/rsyslog.d/b.conf
		echo "$ ~" >>/etc/rsyslog.d/b.conf
	fi
	
	if [ "$type1" == $type4 ];then
		echo '$ModLoad imudp' >>/etc/rsyslog.d/b.conf
		echo '$UDPServerRun 514' >>/etc/rsyslog.d/b.conf
		echo ":fromhost,isequal,"$ip1" /var/log/unix.log/$ip1" >>/etc/rsyslog.d/b.conf
		echo "$ ~" >>/etc/rsyslog.d/b.conf
	fi

	if [ "$type1" == $type5 ];then
		echo '$ModLoad imudp' >>/etc/rsyslog.d/b.conf
		echo '$UDPServerRun 514' >>/etc/rsyslog.d/b.conf
		echo ":fromhost,isequal,"$ip1" /var/log/net/log/$ip1" >>/etc/rsyslog.d/b.conf
		echo "$ ~" >>/etc/rsyslog.d/b.conf
	fi
done

