#!/bin/bash


SIP=(`cat /usr/local/bin/cluster_config.conf`)
#原IP
DIP=($(whiptail --title "Change Ipaddress" --inputbox "要更改的IP" 10 60  3>&1 1>&2 2>&3))
#修改后的IP

#++++++++++++++更改三台集群的IP++++++++++++++
for((i=0;i<3;i++))
do
	ssh ${SIP[$i]} "sed -i \"s/${SIP[$i]}/${DIP[$i]}/g\" /etc/network/interfaces && bash change_ip $1 $2 $3 $4 ${SIP[$i]}"
done
#============================================
