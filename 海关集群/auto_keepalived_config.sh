#!/bin/bash
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
realIP=`cat /etc/ip`
state=$(whiptail --title "fort dialog" --inputbox "输入堡垒主机状态[MASTER,BACKUP]? 必须大写" 10 60 BACKUP 3>&1 1>&2 2>&3)
interface=$(whiptail --title "fort dialog" --inputbox "lvs故障切换检测网口?" 10 60 eth0 3>&1 1>&2 2>&3)
priority=$(whiptail --title "fort dialog" --inputbox "输入优先级别(数字越大，优先级越高)" 10 60 100 3>&1 1>&2 2>&3)
vip=$(whiptail --title "fort dialog" --inputbox "输入虚拟IP地址" 10 60  3>&1 1>&2 2>&3)
real_server=$(whiptail --title "fort dialog" --inputbox "输入所有realserver IP地址(以空格分割)" 10 60 "${realIP}" 3>&1 1>&2 2>&3)
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
        delay_loop 3
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
        delay_loop 3
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
chmod 755 /usr/local/bin/sh/tomcat_down_backup$i.sh
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
MySQL_Cluster(){
mysql_cmd=`ps -ef | grep mysql | grep -v grep | awk '{print $2}'`
kill -9 $mysql_cmd
mv /usr/local/mysql /usr/local/mysql_bak
dpkg -i /var/package/deploy/libnuma1_2.0.8~rc4-1_amd64.deb
dpkg -i /var/package/deploy/libaio1_0.3.109-3_amd64.deb

tar -zxvPf /root/mysql.tar.gz
config_file=/etc/ip
ip1=`sed -n '1p' $config_file`
ip2=`sed -n '2p' $config_file`
ip3=`sed -n '3p' $config_file`


cat > /usr/local/mysql/mysql-cluster/config.ini <<EOF
[ndbd default]
# Options affecting ndbd processes on all data nodes:
NoOfReplicas=3    # Number of replicas
DataMemory=2048M    # How much memory to allocate for data storage
IndexMemory=512M   # How much memory to allocate for index storage
MaxNoOfTables=1024
MaxNoOfAttributes=5000000
MaxNoOfOrderedIndexes=10000         
MaxNoOfConcurrentTransactions=4096
MaxNoOfConcurrentOperations=100000
MaxNoOfLocalOperations=100000
StartPartialTimeout=1
StartFailureTimeout=0
StartPartitionedTimeout=1
	          # For DataMemory and IndexMemory, we have used the
                  # default values. Since the "world" database takes up
                  # only about 500KB, this should be more than enough for
                  # this example Cluster setup.
[tcp default]
# TCP/IP options:
portnumber=2202   # This the default; however, you can use any
                  # port that is free for all the hosts in the cluster
                  # Note: It is recommended that you do not specify the port
                  # number at all and simply allow the default value to be used
                  # instead
[ndb_mgmd]
# Management process options:
nodeid=1
hostname=$ip1         # Hostname or IP address of MGM node
datadir=/usr/local/mysql/mysql-cluster  # Directory for MGM node log files

[ndb_mgmd]
nodeid=2
hostname=$ip2
datadir=/usr/local/mysql/mysql-cluster

[ndb_mgmd]
nodeid=3
hostname=$ip3
datadir=/usr/local/mysql/mysql-cluster

[ndbd]
hostname=$ip1        # Hostname or IP address
NodeId=4
datadir=/usr/local/mysql/data   # Directory for this data node's data files

[ndbd]
hostname=$ip2
NodeId=5
datadir=/usr/local/mysql/data

[ndbd]
hostname=$ip3
NodeId=6
datadir=/usr/local/mysql/data

[mysqld]
NodeId=7
hostname=$ip1

[mysqld]
NodeId=8
hostname=$ip2

[mysqld]
NodeId=9
hostname=$ip3
[mysqld]
EOF

sed -i "/mysqldump/i\default-storage-engine=ndbcluster\nndbcluster\nndb-connectstring=$ip1,$ip2,$ip3\n[mysql_cluster]\nndb-connectstring=$ip1,$ip2,$ip3\n" /etc/my.cnf
ln -s /usr/local/mysql/bin/ndb_mgmd /usr/bin/ndb_mgmd
ln -s /usr/local/mysql/bin/ndb_mgm /usr/bin/ndb_mgm
ln -s /usr/local/mysql/bin/ndbd /usr/bin/ndbd
ln -s /usr/local/mysql/bin/ndb_restore /usr/bin/ndb_restore
ndb_mgmd -f /usr/local/mysql/mysql-cluster/config.ini --configdir=/usr/local/mysql/mysql-cluster --initial
}

#=========安装配置sersync======
SERSYNC(){
eth0=`ifconfig eth0 2>/dev/null | grep "inet addr" | awk -F: '{print $2}' | awk '{print $1}'`
#eth1=`ifconfig eth1 2>/dev/null | grep "inet addr" | awk -F: '{print $2}' | awk '{print $1}'`
#eth2=`ifconfig eth2 2>/dev/null | grep "inet addr" | awk -F: '{print $2}' | awk '{print $1}'`
#eth3=`ifconfig eth3 2>/dev/null | grep "inet addr" | awk -F: '{print $2}' | awk '{print $1}'`
seip1=`cat $config_file | grep -E -v "$eth0" | sed -n '1p'`
seip2=`cat $config_file | grep -E -v "$eth0" | sed -n '2p'`
cat >/usr/local/GNU-Linux-x86/conxml_ca.xml <<EOF
	<?xml version="1.0" encoding="ISO-8859-1"?>
<head version="2.5">
    <host hostip="localhost" port="8008"></host>
    <debug start="false"/>
    <fileSystem xfs="false"/>
    <filter start="false">
	<exclude expression="(.*)\.svn"></exclude>
	<exclude expression="(.*)\.gz"></exclude>
	<exclude expression="^info/*"></exclude>
	<exclude expression="^static/*"></exclude>
    </filter>
    <inotify>
	<delete start="true"/>
	<createFolder start="true"/>
	<createFile start="false"/>
	<closeWrite start="true"/>
	<moveFrom start="true"/>
	<moveTo start="true"/>
	<attrib start="false"/>
	<modify start="false"/>
    </inotify>

    <sersync>
	<localpath watch="/etc/simp_fort/cacenter">
	    <remote ip="$seip1" name="ca"/>
	    <remote ip="$seip1" name="ca"/>
	    <!--<remote ip="192.168.8.40" name="tongbu"/>-->
	</localpath>
	<rsync>
	    <commonParams params="-artupog --partial"/>
	    <auth start="true" users="isomp" passwordfile="/etc/rsyncl.pwd"/>
	    <userDefinedPort start="false" port="874"/><!-- port=874 -->
	    <timeout start="false" time="100"/><!-- timeout=100 -->
	    <ssh start="false"/>
	</rsync>
	<failLog path="/tmp/rsync_fail_log.sh" timeToExecute="60"/><!--default every 60mins execute once-->
	<crontab start="false" schedule="600"><!--600mins-->
	    <crontabfilter start="false">
		<exclude expression="*.php"></exclude>
		<exclude expression="info/*"></exclude>
	    </crontabfilter>
	</crontab>
	<plugin start="false" name="command"/>
    </sersync>

    <plugin name="command">
	<param prefix="/bin/sh" suffix="" ignoreError="true"/>	<!--prefix /opt/tongbu/mmm.sh suffix-->
	<filter start="false">
	    <include expression="(.*)\.php"/>
	    <include expression="(.*)\.sh"/>
	</filter>
    </plugin>

    <plugin name="socket">
	<localpath watch="/opt/tongbu">
	    <deshost ip="192.168.138.20" port="8009"/>
	</localpath>
    </plugin>
    <plugin name="refreshCDN">
	<localpath watch="/data0/htdocs/cms.xoyo.com/site/">
	    <cdninfo domainname="ccms.chinacache.com" port="80" username="xxxx" passwd="xxxx"/>
	    <sendurl base="http://pic.xoyo.com/cms"/>
	    <regexurl regex="false" match="cms.xoyo.com/site([/a-zA-Z0-9]*).xoyo.com/images"/>
	</localpath>
    </plugin>
</head>
	
EOF

cat >/usr/local/GNU-Linux-x86/conxml_fort.xml <<EOF
<?xml version="1.0" encoding="ISO-8859-1"?>
<head version="2.5">
    <host hostip="localhost" port="8008"></host>
    <debug start="false"/>
    <fileSystem xfs="false"/>
    <filter start="false">
	<exclude expression="(.*)\.svn"></exclude>
	<exclude expression="(.*)\.gz"></exclude>
	<exclude expression="^info/*"></exclude>
	<exclude expression="^static/*"></exclude>
    </filter>
    <inotify>
	<delete start="true"/>
	<createFolder start="true"/>
	<createFile start="false"/>
	<closeWrite start="true"/>
	<moveFrom start="true"/>
	<moveTo start="true"/>
	<attrib start="false"/>
	<modify start="false"/>
    </inotify>

    <sersync>
	<localpath watch="/usr/local/fort">
	    <remote ip="$seip1" name="fort"/>
	    <remote ip="$seip2" name="fort"/>
	    <!--<remote ip="192.168.8.40" name="tongbu"/>-->
	</localpath>
	<rsync>
	    <commonParams params="-artupog --partial"/>
	    <auth start="true" users="isomp" passwordfile="/etc/rsyncl.pwd"/>
	    <userDefinedPort start="false" port="874"/><!-- port=874 -->
	    <timeout start="false" time="100"/><!-- timeout=100 -->
	    <ssh start="false"/>
	</rsync>
	<failLog path="/tmp/rsync_fail_log.sh" timeToExecute="60"/><!--default every 60mins execute once-->
	<crontab start="false" schedule="600"><!--600mins-->
	    <crontabfilter start="false">
		<exclude expression="*.php"></exclude>
		<exclude expression="info/*"></exclude>
	    </crontabfilter>
	</crontab>
	<plugin start="false" name="command"/>
    </sersync>

    <plugin name="command">
	<param prefix="/bin/sh" suffix="" ignoreError="true"/>	<!--prefix /opt/tongbu/mmm.sh suffix-->
	<filter start="false">
	    <include expression="(.*)\.php"/>
	    <include expression="(.*)\.sh"/>
	</filter>
    </plugin>

    <plugin name="socket">
	<localpath watch="/opt/tongbu">
	    <deshost ip="192.168.138.20" port="8009"/>
	</localpath>
    </plugin>
    <plugin name="refreshCDN">
	<localpath watch="/data0/htdocs/cms.xoyo.com/site/">
	    <cdninfo domainname="ccms.chinacache.com" port="80" username="xxxx" passwd="xxxx"/>
	    <sendurl base="http://pic.xoyo.com/cms"/>
	    <regexurl regex="false" match="cms.xoyo.com/site([/a-zA-Z0-9]*).xoyo.com/images"/>
	</localpath>
    </plugin>
</head>
EOF

cat >/usr/local/GNU-Linux-x86/conxml_fort.xml <<EOF
<?xml version="1.0" encoding="ISO-8859-1"?>
<head version="2.5">
    <host hostip="localhost" port="8008"></host>
    <debug start="false"/>
    <fileSystem xfs="false"/>
    <filter start="false">
	<exclude expression="(.*)\.svn"></exclude>
	<exclude expression="(.*)\.gz"></exclude>
	<exclude expression="^info/*"></exclude>
	<exclude expression="^static/*"></exclude>
    </filter>
    <inotify>
	<delete start="true"/>
	<createFolder start="true"/>
	<createFile start="false"/>
	<closeWrite start="true"/>
	<moveFrom start="true"/>
	<moveTo start="true"/>
	<attrib start="false"/>
	<modify start="false"/>
    </inotify>

    <sersync>
	<localpath watch="/usr/local/fort_nonsyn/config/concentrationManagement/patch/">
	    <remote ip="$seip1" name="patch"/>
	    <remote ip="$seip2" name="patch"/>
	    <!--<remote ip="192.168.8.40" name="tongbu"/>-->
	</localpath>
	<rsync>
	    <commonParams params="-artupog --partial"/>
	    <auth start="true" users="isomp" passwordfile="/etc/rsyncl.pwd"/>
	    <userDefinedPort start="false" port="874"/><!-- port=874 -->
	    <timeout start="false" time="100"/><!-- timeout=100 -->
	    <ssh start="false"/>
	</rsync>
	<failLog path="/tmp/rsync_fail_log.sh" timeToExecute="60"/><!--default every 60mins execute once-->
	<crontab start="false" schedule="600"><!--600mins-->
	    <crontabfilter start="false">
		<exclude expression="*.php"></exclude>
		<exclude expression="info/*"></exclude>
	    </crontabfilter>
	</crontab>
	<plugin start="false" name="command"/>
    </sersync>

    <plugin name="command">
	<param prefix="/bin/sh" suffix="" ignoreError="true"/>	<!--prefix /opt/tongbu/mmm.sh suffix-->
	<filter start="false">
	    <include expression="(.*)\.php"/>
	    <include expression="(.*)\.sh"/>
	</filter>
    </plugin>

    <plugin name="socket">
	<localpath watch="/opt/tongbu">
	    <deshost ip="192.168.138.20" port="8009"/>
	</localpath>
    </plugin>
    <plugin name="refreshCDN">
	<localpath watch="/data0/htdocs/cms.xoyo.com/site/">
	    <cdninfo domainname="ccms.chinacache.com" port="80" username="xxxx" passwd="xxxx"/>
	    <sendurl base="http://pic.xoyo.com/cms"/>
	    <regexurl regex="false" match="cms.xoyo.com/site([/a-zA-Z0-9]*).xoyo.com/images"/>
	</localpath>
    </plugin>
</head>
EOF

cat /etc/rsyncd.conf <<EOF
[session]
	path = /var/log/simp_fort/session
	list = yes
	auth users = isomp
	secrets file = /etc/rsync.pwd
	strict modes = yes
	ignore errors = no
	ignore nonreadable = yes

[fort]
	path = /usr/local/fort
	list = yes
	auth users = isomp
	secrets file = /etc/rsync.pwd
	ignore errors = no
	ignore nonreadable = yes
[patch]
	path = /usr/local/fort_nonsyn/config/concentrationManagement/patch/
	list = yes
	auth users = isomp
	secrets file = /etc/rsync.pwd
	ignore errors = no
	ignore nonreadable = yes

EOF
#==============================

/usr/local/GNU-Linux-x86/sersync2 -d -r -o /usr/local/GNU-Linux-x86/confxml_ca.xml
/usr/local/GNU-Linux-x86/sersync2 -d -r -o /usr/local/GNU-Linux-x86/confxml_fort.xml
/usr/local/GNU-Linux-x86/sersync2 -d -r -o /usr/local/GNU-Linux-x86/confxml_patch.xml
}
Main(){
        OPTION=$(whiptail --title "fort dialog" --menu "Choose your option" 15 60 4 \
        "1" "lvs+keepalived" \
        "2" "MySQL_Cluster" \
        "3" "sersync" \
         3>&1 1>&2 2>&3)
		 keepalived_dialog
        if [[ $OPTION -eq 1 ]]; then
                keepalived_dialog
				ifconfig lo:0 $vip broadcast $vip netmask 255.255.255.255 up
				sed '7 anet.ipv4.conf.lo.arp_ignore=1\nnet.ipv4.conf.lo.arp_announce=2\nnet.ipv4.conf.all.arp_ignore=1\nnet.ipv4.conf.all.arp_announce=2\n' -i /etc/sysctl.conf
        elif [[ $OPTION -eq 2 ]]; then
                MySQL_Cluster
        elif [[ $OPTION -eq 3 ]]; then
                SERSYNC
        fi
		
}
Main