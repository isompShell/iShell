#!/bin/bash
#-----------------------------------------|
#Date     :2016/06/21
#Author   :Alger
#Mail     :alger_bin@foxmail.com
#Function :this script is Service Menu
#Version  :1.0
#-----------------------------------------|
#Variables
INFO="/usr/local/client/clientInfo.xml"
NODE="/usr/local/client/node.properties"
IPADDR=`ifconfig eth0|grep 'inet addr'|sed 's/^.*addr://g' |sed 's/Bcast:.*$//g' | cut -f 1 -d " "`
#1.check server process
function server_check() {
for a in server
do
CHECK1=`grep -e 'serverStatus' $INFO |cut -f 2 -d ">" | cut -f 1 -d "<"`
echo $CHECK1 >/dev/dull
if [ $? -eq 0 ];then
if [ "$CHECK1" == "true" ];then
echo "9.服务器状态..............................[true]"
else
echo "9.服务器状态...........................[false]"
continue
fi
fi
done
}
#2.check app process
function app_check() {
for b in appstatus
do
CHECK2=`grep -e 'ifAppAccess' $INFO |cut -f 2 -d ">" | cut -f 1 -d "<"`
echo $CHECK2 >/dev/dull
if [ $? -eq 0 ];then
if [ $CHECK2 == true ];then
echo "1.应用服务状态................................[true]"
else
echo "1.应用服务状态...............................[false]"
continue
fi
fi
done
}
#3.fileserver check
function file_check(){
for c in file
do
CHECK3=`grep -e 'ifFileServiceAccess' $INFO |cut -f 2 -d ">" | cut -f 1 -d "<"`
echo $CHECK3 >/dev/dull
if [ $? -eq 0 ];then
if [ $CHECK3 == true ];then
echo "2.文件服务状态................................[true]"
else
echo "2.文件服务状态...............................[false]"
continue
fi
fi
done
}
#4. DB status check
function db_check(){
for a in db
do
CHECK4=`grep -e 'ifDbAccess' $INFO |cut -f 2 -d ">" | cut -f 1 -d "<"`
echo $CHECK4 >/dev/dull
if [ $? -eq 0 ];then
if [ "$CHECK4" == "true" ];then
echo "3.数据库服务状态..............................[true]"
else
echo "3.数据库服务状态.............................[false]"
continue
fi
fi
done
}
#5. Proxy status check
function proxy_check(){
for a in proxy
do
CHECK5=`grep -e 'ProxyAccess' $INFO |cut -f 2 -d ">" | cut -f 1 -d "<"`
echo $CHECK5 >/dev/dull
if [ $? -eq 0 ];then
if [ $CHECK5 == true ];then
echo "4.协议代理服务状态............................[true]"
else
echo "4.协议代理服务状态...........................[false]"
continue
fi
fi
done
}
declare flag=0
clear
while [ "$flag" -eq 0 ]
do
echo "======================================================="
app_check
file_check
db_check
proxy_check
echo "0.exit"
echo "--------------------------------------------------------"
echo "|  输入  1-5 进入服务开关   /    输入  0 退出          |"
echo "--------------------------------------------------------"
echo "|  Enter       1        应用服务状态                   |"
echo "|  Enter       2        文件服务状态                   |"
echo "|  Enter       3        数据库服务状态                 |"
echo "|  Enter       4        协议代理服务状态               |"
echo "|  Enter       5        设置集中管理服务IP             |"
echo "|  Enter       6        设置服务器主机名称             |"
echo "--------------------------------------------------------"
read -p "|-----Please enter your choice [0-5] / [man]: " input
case $input in
#1.tomcat service stop/start
1)
clear
while [ "$flag" -eq 0 ]
do
cat << EOF
------------------------------------------------------
| Enter 1 true   /  Enter 2 false  / Enter 0 back    |
------------------------------------------------------
(1) Configure  应用服务状态 true
(2) Configure  应用服务状态 false
(0) Back
EOF
APP=`grep -e 'ifAppAccess' $INFO |cut -f 2 -d ">" | cut -f 1 -d "<"`
APP1=`grep -e 'appStatus' $INFO |cut -f 2 -d ">" | cut -f 1 -d "<"`
read -p "|----Please enter your choice[0-3]: " input1
case $input1 in
1)
echo -e "\n>>>>>>>>>>>$DATE Start $SERVER1">>/log.txt
sed -i "/ifAppAccess/s/$APP/true/" $INFO 2>>/log.txt
sed -i "/appStatus/s/$APP1/true/" $INFO 2>>/log.txt
if [ $? == 0 ];then
echo "Configure APPserver true..............................[OK]"
else
echo "Configure APPserver true..........................[FAILED]"
fi
sleep 1;
clear
;;
2)
echo -e "\n>>>>>>>>>>>$DATE Stop $SERVER1">>/log.txt
sed -i "/ifAppAccess/s/$APP/false/" $INFO 2>>/log.txt
sed -i "/appStatus/s/$APP1/false/" $INFO 2>>/log.txt
if [ $? == 0 ];then
echo "Configure APPserver false...............................[OK]"
else
echo "Configure APPserver false...........................[FAILED]"
fi
sleep 1;
clear
;;
0)
clear
break
;;
*)
echo "-----------------------------------------------------"
echo "|      Warning!!!  Please Enter Right Choice!       |"
echo "-----------------------------------------------------"
for i in `seq -w 3 -1 1`
do
echo -ne "\b\b$i";
sleep 1;
done
clear
;;
esac
done
;;
#mysql service start/stop/restart
2)
clear
while [ "$flag" -eq 0 ]
do
cat << EOF
------------------------------------------------------
| Enter 1 true   /  Enter 2 false  / Enter 0 back    |
------------------------------------------------------
(1) Configure  文件服务状态 true
(2) Configure  文件服务状态 false
(0) Back
EOF
FILE=`grep -e 'ifFileServiceAccess' $INFO |cut -f 2 -d ">" | cut -f 1 -d "<"`
FILE1=`grep -e 'fileServiceStatus' $INFO |cut -f 2 -d ">" | cut -f 1 -d "<"`
read -p "|----Please enter your Choice[0-2]: " input2
case $input2 in
1)
echo -e "\n>>>>>>>>>>>$DATE Start $SERVER2">>/log.txt
sed -i "/fileServiceStatus/s/$FILE1/true/" $INFO 2>>/log.txt
sed -i "/ifFileServiceAccess/s/$FILE/true/" $INFO 2>>/log.txt
if [ $? == 0 ];then
echo "Configure fileServer true............................[OK]"
else
echo "Configure fileServer true........................[FAILED]"
fi
sleep 1;
clear
;;
2)
echo -e "\n>>>>>>>>>>>$DATE Stop $SERVER2">>/log.txt
sed -i "/fileServiceStatus/s/$FILE1/false/" $INFO 2>>/log.txt
sed -i "/ifFileServiceAccess/s/$FILE/false/" $INFO 2>>/log.txt
if [ $? == 0 ];then
echo "Configure fileServer false.............................[OK]"
else
echo "Configure fileServer false.........................[FAILED]"
fi
sleep 1;
clear
;;
0)
clear
break
;;
*)
echo "-------------------------------------------------------"
echo "|       Warning!!!  Please Enter Right Choice!        |"
echo "-------------------------------------------------------"
for i in `seq -w 3 -1 1`
do
echo -ne "\b\b$i";
sleep 1;
done
clear
;;
esac
done
;;
#Audit guidelines ON/OFF
3)
clear
while [ "$flag" -eq 0 ]
do
cat << EOF
------------------------------------------------------
| Enter 1 true   /  Enter 2 false  / Enter 0 back    |
------------------------------------------------------
(1) Configure  数据库服务状态 true
(2) Configure  数据库服务状态 false
(0) Back
EOF
DB=`grep -e 'ifDbAccess' $INFO |cut -f 2 -d ">" | cut -f 1 -d "<"`
DB1=`grep -e 'dbStatus' $INFO |cut -f 2 -d ">" | cut -f 1 -d "<"`
read -p "|-----Please enter your Choice[0-2]: " input3
case $input3 in
1)
echo -e "\n>>>>>>>>>>>$DATE AUDIT ON">>/log.txt
sed -i "/ifDbAccess/s/$DB/true/" $INFO 2>>/log.txt
sed -i "/dbStatus/s/$DB1/true/" $INFO 2>>/log.txt
if [ $? == 0 ];then
echo "Configure DBServer true.....................[OK]"
else
echo "Configure DBServer true.................[FAILED]"
fi
sleep 1;
clear
;;
2)
echo -e "\n>>>>>>>>>>>$DATE AUDIT OFF">>/log.txt
sed -i "/ifDbAccess/s/$DB/false/" $INFO 2>>/log.txt
sed -i "/dbStatus/s/$DB1/false/" $INFO 2>>/log.txt
if [ $? == 0 ];then
echo "Configure DBServer false...............................[OK]"
else
echo "Configure DBServer false...........................[FAILED]"
fi
sleep 1;
clear
;;
0)
clear
break
;;
*)
echo "-------------------------------------------------------"
echo "|        Warning!!!  Please Enter Right Choice!       |"
echo "-------------------------------------------------------"
for i in `seq -w 3 -1 1`
do
echo -ne "\b\b$i";
sleep 1;
done
clear
;;
esac
done
;;
#Secret_version ON/OFF
4)
clear
while [ "$flag" -eq 0 ]
do
cat << EOF
------------------------------------------------------
| Enter 1 true   /  Enter 2 false  / Enter 0 back    |
------------------------------------------------------
(1) Configure  协议代理服务状态 true
(2) Configure  协议代理服务状态 false
(0) Back
EOF
PROXY=`grep -e 'ProxyAccess' $INFO |cut -f 2 -d ">" | cut -f 1 -d "<"`
PROXY1=`grep -e 'ProxyStatus' $INFO |cut -f 2 -d ">" | cut -f 1 -d "<"`
read -p "|-----Please enter your Choice[0-2]: " input4
case $input4 in
1)
echo -e "\n>>>>>>>>>>>$DATE Secret_version ON">>/log.txt
sed -i "/ifProtocolProxyAccess/s/$PROXY/true/" $INFO 2>>/log.txt
sed -i "/protocolProxyStatus/s/$PROXY1/true/" $INFO 2>>/log.txt
if [ $? == 0 ];then
echo "Secret_version ON.....................[OK]"
else
echo "Secret_version ON.................[FAILED]"
fi
sleep 1;
clear
;;
2)
echo -e "\n>>>>>>>>>>>$DATE Secret_version OFF">>/log.txt
sed -i "/ifProtocolProxyAccess/s/$PROXY/false/" $INFO 2>>/log.txt
sed -i "/protocolProxyStatus/s/$PROXY1/false/" $INFO 2>>/log.txt
if [ $? == 0 ];then
echo "Secret_version OFF....................[OK]"
else
echo "Secret_version OFF................[FAILED]"
fi
sleep 1;
clear
;;
0)
clear
break
;;
*)
echo "-------------------------------------------------------"
echo "|        Warning!!!  Please Enter Right Choice!       |"
echo "-------------------------------------------------------"
for i in `seq -w 3 -1 1`
do
echo -ne "\b\b$i";
sleep 1;
done
clear
;;
esac
done
;;
#Three_uniform ON/OFF
5)
clear
while [ "$flag" -eq 0 ]
do
cat << EOF
------------------------------------------------
| Enter 1  Configure  / Enter 0 back           |
------------------------------------------------
(1) Configure Centraliz server IP
(0) Back
EOF
read -p "|-----Please enter your Choice[0-2]: " input5
case $input5 in
1)
read -p "|------Please enter file system IP : " serverIP
CLIENTIP=`grep 'client_ip' $NODE | awk -F = '{print $2}'|cut -f 1 -d "^" | cut -f 1 -d "$"`
sed -i "/client_ip/s/$CLIENTIP/$IPADDR/" $NODE
SHELLIP=`cat -A $NODE | grep 'shell_ip'| awk -F = '{print $2}' | cut -f 1 -d "^"|cut -f 1 -d "$"`
sed -i "/shell_ip/s/$SHELLIP/$IPADDR/" $NODE
IP=`grep 'ip' $INFO | cut -f 2 -d ">"|cut -f 1 -d "<"`
sed -i "/ip/s/$IP/$IPADDR/" $INFO
ID=`grep 'id' $INFO | cut -f 2 -d ">"|cut -f 1 -d "<"`
sed -i "/id/s/$ID/$IPADDR/" $INFO
SERIP=`grep 'server_ip' $NODE | awk -F = '{print $2}'|grep -v '^$'|cut -f 1 -d "^" | cut -f 1 -d "$"`
sed -i "/server_ip/s/$SERIP/$serverIP/" $NODE
WEBSER=`cat -A $NODE |grep 'webservice.publish.address'  | awk -F = '{print $2}' |cut -f 1 -d "^" | cut -f 1 -d "$"`
sed -i "/webservice.publish.address/s/$WEBSER/127.0.0.1/" $NODE
if [ $? == 0 ];then
echo "Configure Cluster Edition.....................[OK]"
else
echo "Configure Cluster Edition.................[FAILED]"
fi
sleep 1;
clear
;;
0)
clear
break
;;
*)
echo "-------------------------------------------------------"
echo "|        Warning!!!  Please Enter Right Choice!       |"
echo "-------------------------------------------------------"
for i in `seq -w 3 -1 1`
do
echo -ne "\b\b$i";
sleep 1;
done
clear
;;
esac
done
;;
6)
clear
while [ "$flag" -eq 0 ]
do
cat << EOF
------------------------------------------------
| Enter 1  Configure    / Enter 0 back         |
------------------------------------------------
(1) Configure Hostname
(0) Back
EOF
read -p "|-----Please enter your Choice[0-2]: " input6
case $input6 in
1)
read -p "|------Please enter file system hostname : " HOSTS
echo $HOSTS >/etc/hostname
HOST=`cat -A  /etc/hosts| grep '127.0.0.1'| awk -F ^ '{print$2}' |grep -v 'localhost' |cut -f 2 -d "I" |cut -f 1 -d "$"`
sed -i "/$HOST/s/$HOST/$HOSTS/" /etc/hosts
if [ $? == 0 ];
then
/etc/init.d/hostname.sh
echo "|---------change hosts&&hostname Done "
else
echo "|---------change hosts&&hostname Failed"
fi
sleep 1;
clear
;;
0)
clear
break
;;
*)
echo "-------------------------------------------------------"
echo "|        Warning!!!  Please Enter Right Choice!       |"
echo "-------------------------------------------------------"
for i in `seq -w 3 -1 1`
do
echo -ne "\b\b$i";
sleep 1;
done
clear
;;
esac
done
;;
#everyone
0)
clear
exit 0
;;
*)
echo "-------------------------------------------------------"
echo "|      Warning !!!  Please Enter Right Choice!        |"
echo "-------------------------------------------------------"
for i in `seq -w 3 -1 1`
do
echo -ne "\b\b$i";
sleep 1;
done
clear
;;
#exit
esac
done