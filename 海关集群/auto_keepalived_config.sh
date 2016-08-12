#!/binbash
#Title:auto_keepalived_config.sh
#Usage:  交互式
#Description: 
#Author:jiahan
#Date:2016-08-04
#Version:1.0

#获取本机eth0IP 添加realserver
#===============================
#安装lvs+keepalived
#===============================
#
#
#



#===============================
#++++检测keepalived是否安装+++++
#===============================
function keepalived_check(){
        if [[ -f /etc/init.d/keepalived ]]; then
                whiptail --title "fort dialog" --msgbox "keepalived installed" 15 60
        else
                whiptail --title "fort dialog" --msgbox "keepalived not install" 15 60
        fi
}


#================================
#+++++++安装lvs+keepalived+++++++
#================================
function keepalived_install(){
        if [[ -f  /var/package/deploy/libnl1_1.1-7_amd64.deb ]]; then
                dpkg -i /var/package/deploy/libnl1_1.1-7_amd64.deb
        else
                echo "libnl1_1.1-7_amd64.deb not found"
                exit 0
        fi
        if [[ -f  /var/package/deploy/libnl1_1.1-7_amd64.deb ]]; then
                dpkg -i /var/package/deploy/ipvsadm_1.26-1_amd64.deb
        else    
                echo "ipvsadm_1.26-1_amd64.deb not found"
                exit  0
        fi
        if [[ -f  /var/package/deploy/libnl1_1.1-7_amd64.deb ]]; then
                dpkg -i /var/package/deploy/keepalived_1.2.2-3_amd64.deb
        else 
                echo "keepalived_1.2.2-3_amd64.deb not found"
                exit 0
        fi  
}


#===============================
#修改keepalived配置文件
#===============================
function keepalived_config(){
#echo "============lvs+keepalived autoconfig=============="
#read -p "Enter host state? [backup1/backup2/backup3]:"  state
#read -p "Enter interface? [eth0]:" interface
#read -p "Enter priority :" priority
#read -p "Enter virtual IP :" vip
#read -p "Enter real_server :" real_server
#real_server=($real_server) #real_server数组
#real_server_count=echo $real_server | awk '{print NF}'   #real_serverIP数量

state=$(whiptail --title "fort dialog" --inputbox "输入堡垒主机状态[backup1,backup2,backup3]?" 10 60 master 3>&1 1>&2 2>&3)
interface=$(whiptail --title "fort dialog" --inputbox "输入堡垒通信网卡?" 10 60 eth0 3>&1 1>&2 2>&3)
priority=$(whiptail --title "fort dialog" --inputbox "输入优先级别(数字越大，优先级越高)" 10 60 100 3>&1 1>&2 2>&3)
vip=$(whiptail --title "fort dialog" --inputbox "输入虚拟IP地址" 10 60 192.168.200.100 3>&1 1>&2 2>&3)
real_server=$(whiptail --title "fort dialog" --inputbox "输入所有realserver IP地址(以空格分割)" 10 60  3>&1 1>&2 2>&3)
real_port=$(whiptail --title "fort dialog" --inputbox "输入所有realserver 开放端口(以空格分割)" 10 60 "22 3390 20021" 3>&1 1>&2 2>&3)
real_server=($real_server)
real_port=($real_port)
real_server_count=`echo "${real_server[@]}" | awk '{print NF}'`   #real_serverIP数量
real_port_count=`echo "${real_port[@]}" | awk '{print NF}'`  #real开放端口数量

let real_server_count=real_server_count-1
let real_port_count=real_port_count-1
cat > /etc/keepalived/keepalived.conf <<EOF
! Configuration File for keepalived
global_defs {
router_id LVS_1
}
vrrp_instance VI_1 {
        state $state
        interface $interface
        virtual_router_id 60
        priority $priority
        advert_int 1
        authentication {
                auth_type PASS
                auth_pass 1111
        }
        virtual_ipaddress {
                $vip
        }
}
virtual_server $vip 443 {
        delay_loop 6
        lb_algo sh
        lb_kind DR
        # persistence_timeout 60
        protocol TCP
}
EOF




#==========添加所有端口========================
#
#
#




for i in `seq 0 $real_port_count`
do
cat >> /etc/keepalived/keepalived.conf <<EOF
virtual_server $vip ${real_port[$i]} {
        delay_loop 6
        lb_algo sh
        lb_kind DR
        # persistence_timeout 60
        protocol TCP                                                                                                                                                                                                                                                                     
}                    
EOF
done

#=================================================================
#添加 443端口 realserver
for i in `seq 0 $real_server_count`
do
	count=`grep -n "virtual_server $vip 443" /etc/keepalived/keepalived.conf | awk -F: '{print $1}'`
	let count=count+5
	sed "$count a\ \treal_server ${real_server[$i]} 443 {\n\tnotify_up /usr/local/bin/sh/tomcat_up.sh\n\tnotify_down /usr/local/bin/sh/tomcat_down_backup$i.sh\n\tTCP_CHECK {\n\t\tconnect_timeout 10\n\t\tnb_get_retry 3\n\t\tdelay_before_retry 3\n\t\tconnect_port 443\n\t\t}\n\t}\n" -i /etc/keepalived/keepalived.conf
	cat > /usr/local/bin/sh/tomcat_down_backup$i.sh <<EOF
	#!/bin/bash
	ipvsadm -d -t $vip:443 -r ${real_server[$i]}:443 >/dev/null
	ipvsadm -d -t $vip:${real_port[0]} -r ${real_server[$i]}:${real_port[0]} >/dev/null
	ipvsadm -d -t $vip:${real_port[1]} -r ${real_server[$i]}:${real_port[1]} >/dev/null
	ipvsadm -d -t $vip:${real_port[2]} -r ${real_server[$i]}:${real_port[2]} >/dev/null
	ipvsadm -d -t $vip:${real_port[3]} -r ${real_server[$i]}:${real_port[3]} >/dev/null
	ipvsadm -d -t $vip:${real_port[4]} -r ${real_server[$i]}:${real_port[4]} >/dev/null
	ipvsadm -d -t $vip:${real_port[5]} -r ${real_server[$i]}:${real_port[5]} >/dev/null
EOF
chmod +x /usr/loca/bin/sh/tomcat_down_backup$i.sh
done

#添加real_server
for i in `seq 0 $real_port_count`
do
	count=`grep -n "virtual_server $vip ${real_port[$i]}" /etc/keepalived/keepalived.conf | awk -F: '{print $1}'`
	let count=count+5 #在此行下插入realserver
	for j in `seq 0 $real_server_count`
	do
		sed "$count a\ \treal_server ${real_server[$j]} ${real_port[$i]} {\n\tTCP_CHECK {\n\t\tconnect_timeout 10\n\t\tnb_get_retry 3\n\t\tdelay_before_retry 3\n\t\tconnect_port ${real_port[$i]}\n\t\t}\n\t}\n" -i /etc/keepalived/keepalived.conf
	done

done

}
#==============================
#+++++lvs+keepalived对话框+++++
#==============================
function keepalived_dialog(){
        keepdia=$(whiptail --title "fort dialog" --menu "Choose your option" 15 60 4 \
        "1" "自动" \
        "2" "检测" \
        "3" "安装" \
        "4" "配置" \
         3>&1 1>&2 2>&3)
         if [[ $keepdia -eq 1 ]]; then
                keepalived_check
                keepalived_install
                keepalived_config
                /etc/init.d/ipvsadm restart
                /etc/init.d/keepalived restart
         fi
         if [[ $keepdia -eq 2 ]]; then
                keepalived_check
         fi
         if [[ $keepdia -eq 3 ]]; then
                keepalived_install
         fi
         if [[ $keepdia -eq 4 ]]; then
                keepalived_config
         fi
}
#================================
#+++主函数，程序从这里开始运行+++
#================================
Main(){
        OPTION=$(whiptail --title "fort dialog" --menu "Choose your option" 15 60 4 \
        "1" "lvs+keepalived" \
        "2" "heartbeat" \
        "3" "sersync" \
         3>&1 1>&2 2>&3)
        if [[ $OPTION -eq 1 ]]; then
                keepalived_dialog
				ifconfig lo:0 $vip broadcast $vip netmask 255.255.255.255 up
        elif [[ $OPTION -eq 2 ]]; then
                keepalived_dialog
        elif [[ $OPTION -eq 3 ]]; then
                keepalived_dialog
        fi
}
Main