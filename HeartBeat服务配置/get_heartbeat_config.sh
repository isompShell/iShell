#!/bin/bash
if [ -e "/etc/ha.d" ];then
	[ `/etc/init.d/heartbeat status |awk '{print $2}'` = OK ] && HA_STATUS=0 ||HA_STATUS=1
	UCAST=`egrep '^ucast' /usr/etc/ha.d/ha.cf |awk '{print $2" "$3}'`
	PING_IP=`grep '^ping' /usr/etc/ha.d/ha.cf |awk '{print $2}' `
	MASTER=`grep -v "^#" /usr/etc/ha.d/haresources|awk '{print $1}'`
	LOCAL_HOST=`cat /etc/hostname`
	[ "${MASTER}" = "${LOCAL_HOST}" ]&&ROLE=0 || ROLE=1
fi
if [ -e "/etc/init.d/rsync" ];then
	[ `/etc/init.d/rsync status |awk '{print $2$3}'` = isrunning. ] && RSYNC_STATUS=0 ||RSYNC_STATUS=1
fi

#ACTIVE_NIC=`mii-tool 2>/dev/null |egrep 'link ok$'|awk '{print $1}'|sed 's/://'`
ACTIVE_NIC=`ifconfig|cut -d ' ' -f1|grep -v "^$"|egrep  "[[:alpha:]][[:digit:]]$"`

[ -e "/etc/ha.d" ]&&HA_VIP=`tail -n 1  /etc/ha.d/haresources |awk '{print $2}'|sed 's/\/[[:alpha:]].*$//'`
[ -e "/etc/ha.d" ]&&HA_NIC=`tail -n 1  /etc/ha.d/haresources |awk '{print $2}'|sed 's/^[[:digit:]].*\///'`
echo $HA_STATUS,$RSYNC_STATUS,$ROLE,$ACTIVE_NIC,$UCAST,$HA_VIP,$HA_NIC,$PING_IP
