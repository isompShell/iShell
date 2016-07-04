#!/bin/bash
#Title:config_syslog.sh
#Usage:
#Description:add ip syslog
#Author:jiahan
#Date:2016-06-17
#Version:1.0
rm -rf /etc/rsyslog.d/b.conf


linux="Commonlinux"
redhat="RedHat"
ubuntu="Ubuntu"
hp="HPunix"
ibm="AIX(IBM)"
sco="SCOunix"
sun="Solaris(Sun)"
freebsd="FreeBsd"
centos="Centos"
debian="Debian"
opensuse="OpenSuSe"

win3="WindowsServer2003"
win8="WindowsServer2008"
win12="WindowsServer2012"
yk03="Windows2003域控服务器"
yk08="Windows2008域控服务器"
yk12="Windows2012域控服务器"
common="CommonWindows" #无法判断

network="Commonnetworkequipment"
cisco="Cisco"
huawei="华为"
asa="CiscoASA"
h3c="H3C"
maipu="迈普"
ruijie="锐捷"

windows3() {
	echo '$ModLoad imudp' >>/etc/rsyslog.d/b.conf
	echo '$UDPServerRun 514' >>/etc/rsyslog.d/b.conf
	echo ":fromhost,isequal,\"$ip1\" /var/log/win.log/aaa/$ip1" >>/etc/rsyslog.d/b.conf
	echo "& ~" >>/etc/rsyslog.d/b.conf
}

windows8() {
	echo '$ModLoad imudp' >>/etc/rsyslog.d/b.conf
	echo '$UDPServerRun 514' >>/etc/rsyslog.d/b.conf
	echo ":fromhost,isequal,\"$ip1\" /var/log/win.log/bbb/$ip1" >>/etc/rsyslog.d/b.conf
	echo "& ~" >>/etc/rsyslog.d/b.conf
}

unix() {
	echo '$ModLoad imudp' >>/etc/rsyslog.d/b.conf
	echo '$UDPServerRun 514' >>/etc/rsyslog.d/b.conf
	echo ":fromhost,isequal,\"$ip1\" /var/log/unix.log/$ip1" >>/etc/rsyslog.d/b.conf
	echo "& ~" >>/etc/rsyslog.d/b.conf
}

net() {
	echo '$ModLoad imudp' >>/etc/rsyslog.d/b.conf
	echo '$UDPServerRun 514' >>/etc/rsyslog.d/b.conf
	echo ":fromhost,isequal,\"$ip1\" /var/log/net.log/$ip1" >>/etc/rsyslog.d/b.conf
	echo "& ~" >>/etc/rsyslog.d/b.conf
}

#aa="192.168.23.1,Windows Server 2003;192.168.23.2,Windows Server 2008;192.168.23.3,Unix/Linux资源;192.168.23.10,网络设备"
ip_type=`echo $1 | sed s/[[:space:]]//g`  #去掉参数中的所有空格
ip=`echo $ip_type|awk -F';'  '{for(i=1;i<=NF;i++) print $i}'`    #192.168.23.1,WindowsServer2003;192.168.23.2,WindowsServer2008;192.168.23.3,Unix/Linux资源;192.168.23.10,网络设备

for ip in $ip      #递归所有的ip
do
	ip1=`echo $ip|awk -F, '{print $1}'`   #IP
	type1=`echo $ip|awk -F, '{print $2}'` #IP对应的资源类型
	case $type1 in
    $win3)	
		windows3
	;;
	$win8)	
		windows8
	;;
	$win12)	
		windows8
	;;
	$yk03)	
		windows3
	;;
	$yk08)	
		windows8
	;;
	$yk12)	
		windows8
	;;
	$common)	
		windows8
	;;
	$network)
		net
	;;
	$cisco)	
		net
	;;
	$huawei)	
		net
	;;
	$asa)	
		net
	;;
	$h3c)	
		net
	;;
	$maipu)	
		net
	;;
	$ruijie)	
		net
	;;
	$linux)	
		unix
	;;
	$redhat)	
		unix
	;;
	$hp)	
		unix
	;;
	$ibm)	
		unix
	;;
	$sun)	
		unix
	;;
	$sco)	
		unix
	;;
	$freebsd)	
		unix
	;;
	$centos)	
		unix
	;;
	$debian)	
		unix
	;;
	$opensuse)	
		unix
	;;
	$ubuntu)	
		unix
	;;
	esac
done