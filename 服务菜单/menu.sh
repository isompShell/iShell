#!/bin/bash
#-----------------------------------------|
#Date     :2016/06/21
#Author   :Alger
#Mail     :alger_bin@foxmail.com
#Function :this script is Service Menu
#Version  :1.0
#-----------------------------------------|
#Variables
TOMCAT_DIR="/usr/local/tomcat"
MYSQL_DIR="/usr/local/mysql"
SERVER1="TOMCAT"
SERVER2="MYSQL"
SERVER1_START="start_tomcat.sh"
SERVER1_STOP="stop_tomcat.sh"
SERVER2_START="/etc/init.d/mysql start"
SERVER2_STOP="/etc/init.d/mysql stop"
SERVER2_RESTART="/etc/init.d/mysql restart"
FORT_FILE="/usr/local/tomcat/webapps/fort/WEB-INF/classes/fort.properties"
DATE=`date +"%y-%m-%d %H:%M:%S"`
#1.check tomcat process
function tomcat_check() {
for dir in $TOMCAT_DIR
do
process_count=$(ps -ef | grep "$dir" | grep -v grep | wc -l)
for service in Tomcat
do
echo "$dir" |grep -q "tomcat"
if [ $? -eq 0 ];then
if [ $process_count -eq 0 ];then
echo "1.Tomcat服务......................................[OFF]"
else
echo "1.tomcat服务.......................................[ON]"
continue
fi
fi
done
done
}
#2.check mysql process
function mysql_check() {
for dir1 in $MYSQL_DIR
do
process_count1=$(ps -ef | grep "$dir1" | grep -v grep | wc -l)
for service1 in Mysql
do
echo "$dir1" |grep -q "mysql"
if [ $? -eq 0 ];then
if [ $process_count1 -eq 0 ];then
echo "2.数据库服务......................................[OFF]"
else
echo "2.数据库服务.......................................[ON]"
continue
fi
fi
done
done
}
#3.Auditguidelines ON/OFF check
function Auditguidelines_check(){
for c in Audit_guidelines
do
CHECK3=`cat -A $FORT_FILE | grep '^fort.behavior' | awk -F = '{print$2}' |cut -f 1 -d "^"`
echo $CHECK3 >/dev/dull
if [ $? -eq 0 ];then
if [ $CHECK3 -eq 0 ];then
echo "3.审计指引........................................[OFF]"
else
echo "3.审计指引.........................................[ON]"
continue
fi
fi
done
}
#4.Secret version ON/OFF check
function Secret_check(){
for d in Secret_version
do
CHECK4=`cat -A $FORT_FILE | grep '^fort.page.change' | awk -F = '{print$2}' |cut -f 1 -d "^"`
echo $CHECK4 >/dev/dull
if [ $? -eq 0 ];then
if [ $CHECK4 -eq 1 ];then
echo "4.涉密版本........................................[OFF]"
else
echo "4.涉密版本.........................................[ON]"
continue
fi
fi
done
}
#5.threeuniform ON/OFF check
function threeuniform_check(){
for e in  Three_uniform
do
CHECK5=`cat -A $FORT_FILE | grep '^fort.three.uniform' | awk -F = '{print$2}' |cut -f 1 -d "^"`
echo $CHECK5 >/dev/dull
if [ $? -eq 0 ];then
if [ $CHECK5 -eq 0 ];then
echo "5.三统一接口......................................[OFF]"
else
echo "5.三统一接口.......................................[ON]"
continue
fi
fi
done
}
#6. Application ON/OFF check
function applicatio_check(){
for f in  Application
do
CHECK6=`cat -A $FORT_FILE | grep '^fort.huawei' | awk -F = '{print$2}' |cut -f 1 -d "^"`
echo $CHECK6 >/dev/dull
if [ $? -eq 0 ];then
if [ $CHECK6 -eq 0 ];then
echo "6.应用发布........................................[OFF]"
else
echo "6.应用发布.........................................[ON]"
continue
fi
fi
done
}
#7. strategy.password ON/OFF check
function strategypassword_check(){
for g in Strategy_password
do
CHECK7=`cat -A $FORT_FILE | grep '^fort.strategy.password' | awk -F = '{print$2}' |cut -f 1 -d "^"`
echo $CHECK7 >/dev/dull
if [ $? -eq 0 ];then
if [ $CHECK7 -eq 0 ];then
echo "7.密码策略........................................[OFF]"
else
echo "7.密码策略.........................................[ON]"
continue
fi
fi
done
}
#8. Emergency operation ON/OFF check
function emergencyoperation_check(){
for h in Emergency_operation
do
CHECK8=`cat -A $FORT_FILE | grep '^fort.sso.audit' | awk -F = '{print$2}' |cut -f 1 -d "^"`
echo $CHECK8 >/dev/dull
if [ $? -eq 0 ];then
if [ $CHECK8 -eq 0 ];then
echo "8.紧急运维........................................[OFF]"
else
echo "8.紧急运维.........................................[ON]"
continue
fi
fi
done
}
#9.cluster ON/OFF check
function cluster_check(){
for i in Cluster
do
CHECK9=`cat -A $FORT_FILE | grep '^fort.cluster' | awk -F = '{print$2}' |cut -f 1 -d "^"`
echo $CHECK9 >/dev/dull
if [ $? -eq 0 ];then
if [ $CHECK9 -eq 0 ];then
echo "9.集群设置.....................................[标准版]"
elif [ $CHECK9 -eq 1 ];then    
echo "9.集群设置.....................................[集群版]"
else
echo "9.集群设置.....................................[地铁版]"
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
tomcat_check
mysql_check
Auditguidelines_check
Secret_check
threeuniform_check
applicatio_check
strategypassword_check
emergencyoperation_check
cluster_check
echo "0.exit"
echo "--------------------------------------------------------"
echo "|      1-9 进入服务开关  /  man 进入帮助  /  0 退出     |"
echo "--------------------------------------------------------"
echo "|  Enter       10        地铁版                        |"
echo "|  Enter       11        标准版                        |"
echo "|  Enter       12        涉密版                        |"
echo "-------------------------------------------------------"
read -p "|-----Please enter your choice [0-9] / [man]: " input
case $input in
#1.tomcat service stop/start
1)
clear
while [ "$flag" -eq 0 ]
do
cat << EOF
------------------------------------------------------
| Enter 1 start   /  Enter 2 stop  / Enter 0 back    |
------------------------------------------------------
(1) Start $SERVER1 Service
(2) Stop  $SERVER1 Service
(0) Back
EOF
read -p "|----Please enter your choice[0-3]: " input1
case $input1 in
1)
echo -e "\n>>>>>>>>>>>$DATE Start $SERVER1">>/log.txt
$SERVER1_START 2>>/log.txt
if [ $? == 0 ];then
echo "Start $SERVER1..............................[OK]"
else
echo "Start $SERVER1..........................[FAILED]"
fi
sleep 1;
clear
;;
2)
echo -e "\n>>>>>>>>>>>$DATE Stop $SERVER1">>/log.txt
$SERVER1_STOP 2>>/log.txt
if [ $? == 0 ];then
echo "Stop $SERVER1...............................[OK]"
else
echo "Stop $SERVER1...........................[FAILED]"
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
| Enter 1 start   /  Enter 2 stop  / Enter 0 back    |
------------------------------------------------------
(1) Start $SERVER2 Service
(2) Stop  $SERVER2 Service
(0) Back
EOF
read -p "|----Please enter your Choice[0-2]: " input2
case $input2 in
1)
echo -e "\n>>>>>>>>>>>$DATE Start $SERVER2">>/log.txt
$SERVER2_START 2>>/log.txt
if [ $? == 0 ];then
echo "Start $SERVER2............................[OK]"
else
echo "Start $SERVER2........................[FAILED]"
fi
sleep 1;
clear
;;
2)
echo -e "\n>>>>>>>>>>>$DATE Stop $SERVER2">>/log.txt
$SERVER2_STOP 2>>/log.txt
if [ $? == 0 ];then
echo "Stop $SERVER2.............................[OK]"
else
echo "Stop $SERVER2.........................[FAILED]"
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
------------------------------------------------
| Enter 1  ON / Enter 2 OFF  / Enter 0 back    |
------------------------------------------------
(1) Configure Audit guidelines ON
(2) Configure Audit guidelines OFF
(0) Back
EOF
read -p "|-----Please enter your Choice[0-2]: " input3
case $input3 in
1)
echo -e "\n>>>>>>>>>>>$DATE AUDIT ON">>/log.txt
sed -i '/fort.behavior.guideline.status/s/0/1/' $FORT_FILE 2>>/log.txt
if [ $? == 0 ];then
echo "Audit guidelines ON.....................[OK]"
else
echo "Audit guidelines ON.................[FAILED]"
fi
sleep 1;
clear
;;
2)
echo -e "\n>>>>>>>>>>>$DATE AUDIT OFF">>/log.txt
sed -i '/fort.behavior.guideline.status/s/1/0/' $FORT_FILE 2>>/log.txt
if [ $? == 0 ];then
echo "AUDIT OFF...............................[OK]"
else
echo "AUDIT OFF...........................[FAILED]"
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
------------------------------------------------
| Enter 1  ON / Enter 2 OFF  / Enter 0 back    |
------------------------------------------------
(1) Configure Secret_version ON
(2) Configure Secret_version OFF
(0) Back
EOF
read -p "|-----Please enter your Choice[0-2]: " input4
case $input4 in
1)
echo -e "\n>>>>>>>>>>>$DATE Secret_version ON">>/log.txt
sed -i '/fort.page.change/s/1/2/' $FORT_FILE 2>>/log.txt
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
sed -i '/fort.page.change/s/2/1/' $FORT_FILE 2>>/log.txt
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
| Enter 1  ON / Enter 2 OFF  / Enter 0 back    |
------------------------------------------------
(1) Configure Three_uniform ON
(2) Configure Three_uniform OFF
(0) Back
EOF
read -p "|-----Please enter your Choice[0-2]: " input5
case $input5 in
1)
echo -e "\n>>>>>>>>>>>$DATE Three_uniform ON">>/log.txt
sed -i '/fort.three.uniform.status/s/0/1/g' $FORT_FILE 2>>/log.txt
if [ $? == 0 ];then
echo "Three_uniform ON.....................[OK]"
else
echo "Three_uniform ON.................[FAILED]"
fi
sleep 1;
clear
;;
2)
echo -e "\n>>>>>>>>>>>$DATE Three_uniform OFF">>/log.txt
sed -i '/fort.three.uniform.status/s/1/0/g' $FORT_FILE 2>>/log.txt
if [ $? == 0 ];then
echo "Three_uniform OFF....................[OK]"
else
echo "Three_uniform OFF................[FAILED]"
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
#Application ON/OFF
6)
clear
while [ "$flag" -eq 0 ]
do
cat << EOF
------------------------------------------------
| Enter 1  ON / Enter 2 OFF  / Enter 0 back    |
------------------------------------------------
(1) Configure Application ON
(2) Configure Application OFF
(0) Back
EOF
read -p "|-----Please enter your Choice[0-2]: " input6
case $input6 in
1)
echo -e "\n>>>>>>>>>>>$DATE Application ON">>/log.txt
sed -i '/fort.huawei.status/s/0/1/g' $FORT_FILE 2>>/log.txt
if [ $? == 0 ];then
echo "Application ON.....................[OK]"
else
echo "Application ON.................[FAILED]"
fi
sleep 1;
clear
;;
2)
echo -e "\n>>>>>>>>>>>$DATE Application OFF">>/log.txt
sed -i '/fort.huawei.status/s/1/0/g' $FORT_FILE 2>>/log.txt
if [ $? == 0 ];then
echo "Application OFF....................[OK]"
else
echo "Application OFF................[FAILED]"
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
#Strategy_password ON/OFF
7)
clear
while [ "$flag" -eq 0 ]
do
cat << EOF
------------------------------------------------
| Enter 1  ON / Enter 2 OFF  / Enter 0 back    |
------------------------------------------------
(1) Configure Strategy_password ON
(2) Configure Strategy_password OFF
(0) Back
EOF
read -p "|-----Please enter your Choice[0-2]: " input7
case $input7 in
1)
echo -e "\n>>>>>>>>>>>$DATE Strategy_password ON">>/log.txt
sed -i '/fort.strategy.password.status/s/0/1/g' $FORT_FILE 2>>/log.txt
if [ $? == 0 ];then
echo "Strategy_password ON.....................[OK]"
else
echo "Strategy_password ON.................[FAILED]"
fi
sleep 1;
clear
;;
2)
echo -e "\n>>>>>>>>>>>$DATE Strategy_password OFF">>/log.txt
sed -i '/fort.strategy.password.status/s/1/0/g' $FORT_FILE  2>>/log.txt
if [ $? == 0 ];then
echo "Strategy_password OFF....................[OK]"
else
echo "Strategy_password OFF................[FAILED]"
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
#Emergency_operation ON/OFF
8)
clear
while [ "$flag" -eq 0 ]
do
cat << EOF
------------------------------------------------
| Enter 1  ON / Enter 2 OFF  / Enter 0 back    |
------------------------------------------------
(1) Configure Emergency_operation ON
(2) Configure Emergency_operation OFF
(0) Back
EOF
read -p "|-----Please enter your Choice[0-2]: " input8
case $input8 in
1)
echo -e "\n>>>>>>>>>>>$DATE Emergency_operation ON">>/log.txt
sed -i '/fort.sso.audit.emergency/s/0/1/g' $FORT_FILE 2>>/log.txt
if [ $? == 0 ];then
echo "Emergency_operation ON.....................[OK]"
else
echo "Emergency_operation ON.................[FAILED]"
fi
sleep 1;
clear
;;
2)
echo -e "\n>>>>>>>>>>>$DATE Emergency_operation OFF">>/log.txt
sed -i '/fort.sso.audit.emergency/s/1/0/g' $FORT_FILE 2>>/log.txt
if [ $? == 0 ];then
echo "Emergency_operation OFF....................[OK]"
else
echo "Emergency_operation OFF................[FAILED]"
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
#Cluster /Metro /Standard
9)
clear
while [ "$flag" -eq 0 ]
do
cat << EOF
------------------------------------------------
| Enter 1  ON / Enter 2 OFF  / Enter 0 back    |
------------------------------------------------
(1) Configure Cluster Edition
(2) Configure Metro Edition
(3) Configure Standard Edition
(0) Back
EOF
read -p "|-----Please enter your Choice[0-2]: " input9
case $input9 in
1)
echo -e "\n>>>>>>>>>>>$DATE Cluster ON">>/log.txt
read -p "|------Please enter file system IP : " systemIP
SYSTEMIP=`cat -A $FORT_FILE | grep -e '^fort.file.system.ip'|awk -F = '{print$2}'|cut -f 1 -d "^"`
if [[ "$SYSTEMIP" == "" ]];then
sed -i "/fort.file.system.ip/s/.$/$systemIP\r/" $FORT_FILE
else
sed -i "/fort.file.system.ip/s/$SYSTEMIP/$systemIP/" $FORT_FILE
fi
read -p "|------Please enter local IP : " localIP
LOCALIP=`cat -A $FORT_FILE | grep -e '^fort.local.ip'  |awk -F = '{print$2}'|cut -f 1 -d "^"`
if [[ $LOCALIP == "" ]];then
sed -i "/fort.local.ip/s/.$/$localIP\r/" $FORT_FILE
else
sed -i "/fort.local.ip/s/$LOCALIP/$localIP/" $FORT_FILE
fi
CLUSTER1=`cat -A $FORT_FILE | grep '^fort.cluster' | awk -F = '{print$2}' |cut -f 1 -d "^"`
sed -i "/fort.cluster.environment/s/$CLUSTER1/1/g" $FORT_FILE 2>>/log.txt
if [ $? == 0 ];then
echo "Configure Cluster Edition.....................[OK]"
else
echo "Configure Cluster Edition.................[FAILED]"
fi
sleep 1;
clear
;;
2)
echo -e "\n>>>>>>>>>>>$DATE Cluster OFF">>/log.txt
CLUSTER2=`cat -A $FORT_FILE | grep '^fort.cluster' | awk -F = '{print$2}' |cut -f 1 -d "^"`
sed -i "/fort.cluster.environment/s/$CLUSTER2/2/g" $FORT_FILE 2>>/log.txt
if [ $? == 0 ];then
echo "Configure Standard Edition....................[OK]"
else
echo "Configure Standard Edition................[FAILED]"
fi
sleep 1;
clear
;;
3)
echo -e "\n>>>>>>>>>>>$DATE Cluster OFF">>/log.txt
CLUSTER3=`cat -A $FORT_FILE | grep '^fort.cluster' | awk -F = '{print$2}' |cut -f 1 -d "^"`
sed -i "/fort.cluster.environment/s/$CLUSTER3/0/g" $FORT_FILE 2>>/log.txt
if [ $? == 0 ];then
echo "Configure Metro Edition....................[OK]"
else
echo "Configure Metro Edition................[FAILED]"
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
#Metro Edition Configure
10)
clear
while [ "$flag" -eq 0 ]
do
cat << EOF
------------------------------------------------
| Enter 1  Configure   /  Enter 0 back         |
------------------------------------------------
(1) Configure Metro Edition
(0) Back
EOF
read -p "|-----Please enter your Choice[0-1]: " input10
case $input10 in
1)
sed -i '/fort.behavior.guideline.status/s/1/0/' $FORT_FILE 2>>/log.txt
sed -i '/fort.page.change/s/2/1/' $FORT_FILE 2>>/log.txt
sed -i '/fort.three.uniform.status/s/1/0/g' $FORT_FILE 2>>/log.txt
sed -i '/fort.huawei.status/s/1/0/g' $FORT_FILE 2>>/log.txt
sed -i '/fort.strategy.password.status/s/1/0/g' $FORT_FILE 2>>/log.txt
sed -i '/fort.sso.audit.emergency/s/1/0/g' $FORT_FILE 2>>/log.txt
CLUSTER4=`cat -A $FORT_FILE | grep '^fort.cluster' | awk -F = '{print$2}' |cut -f 1 -d "^"`
sed -i "/fort.cluster.environment/s/$CLUSTER4/2/g" $FORT_FILE 2>>/log.txt
if [ $? -eq 0 ]; then
     echo "Configure Metro Edition.....................[Done]"
else
     echo "Configure Metro Edition...................[failed]"
fi
sleep 1;
clear
break
;;
0)
clear
break
;;
*)
echo "-------------------------------------------------------"
echo "|       Warning !!!  Please Enter Right Choice!       |"
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
#man in help
11)
clear
while [ "$flag" -eq 0 ]
do
cat << EOF
------------------------------------------------
| Enter 1  Configure    /  Enter 0 back        |
------------------------------------------------
(1) Configure Standard Edition
(0) Back
EOF
read -p "|-----Please enter your Choice[0-1]: " input10
case $input10 in
1)
sed -i '/fort.behavior.guideline.status/s/1/0/' $FORT_FILE 2>>/log.txt
sed -i '/fort.page.change/s/2/1/' $FORT_FILE 2>>/log.txt
sed -i '/fort.three.uniform.status/s/1/0/g' $FORT_FILE 2>>/log.txt
sed -i '/fort.huawei.status/s/1/0/g' $FORT_FILE 2>>/log.txt
sed -i '/fort.strategy.password.status/s/1/0/g' $FORT_FILE 2>>/log.txt
sed -i '/fort.sso.audit.emergency/s/1/0/g' $FORT_FILE 2>>/log.txt
CLUSTER5=`cat -A $FORT_FILE | grep '^fort.cluster' | awk -F = '{print$2}' |cut -f 1 -d "^"`
sed -i "/fort.cluster.environment/s/$CLUSTER5/0/g" $FORT_FILE 2>>/log.txt
if [ $? -eq 0 ]; then
     echo "Configure Standard Edition.....................[Done]"
else
     echo "Configure Standard Edition...................[failed]"
fi
sleep 1;
clear
break
;;
0)
clear
break
;;
*)
echo "-------------------------------------------------------"
echo "|       Warning !!!  Please Enter Right Choice!       |"
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
12)
clear
while [ "$flag" -eq 0 ]
do
cat << EOF
------------------------------------------------
| Enter 1  Configure    /  Enter 0 back        |
------------------------------------------------
(1) Configure Secret Edition
(0) Back
EOF
read -p "|-----Please enter your Choice[0-1]: " input10
case $input10 in
1)
sed -i '/fort.behavior.guideline.status/s/1/0/' $FORT_FILE 2>>/log.txt
sed -i '/fort.page.change/s/1/2/' $FORT_FILE 2>>/log.txt
sed -i '/fort.three.uniform.status/s/1/0/g' $FORT_FILE 2>>/log.txt
sed -i '/fort.huawei.status/s/1/0/g' $FORT_FILE 2>>/log.txt
sed -i '/fort.strategy.password.status/s/0/1/g' $FORT_FILE 2>>/log.txt
sed -i '/fort.sso.audit.emergency/s/1/0/g' $FORT_FILE 2>>/log.txt
CLUSTER6=`cat -A $FORT_FILE | grep '^fort.cluster' | awk -F = '{print$2}' |cut -f 1 -d "^"`
sed -i "/fort.cluster.environment/s/$CLUSTER6/0/g" $FORT_FILE 2>>/log.txt
if [ $? -eq 0 ]; then
     echo "Configure Secret Edition.....................[Done]"
else
     echo "Configure Secret Edition...................[failed]"
fi
sleep 1;
clear
break
;;
0)
clear
break
;;
*)
echo "-------------------------------------------------------"
echo "|       Warning !!!  Please Enter Right Choice!       |"
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
man)
clear
while [ "$flag" -eq 0 ]
do
cat << EOF
--------------------------------------------------------
|----------------Service menu help---------------------|
--------------------------------------------------------
1 this script is used to control the opening and closing
of each service in the fortress system.
2 Input menu enter, can be directly run this script
3 enter the digital access service interface in front of
each service.
4 input man, enter this help interface, enter 0 to return
to the upper menu or exit
5 if there is an input error, press the shift+backspace
key to delete the case.
|------------------------------------------------------|
EOF
read -p "|-----Please enter number 0 exit: " inputman
case $inputman in
0)
clear
break
;;
*)
echo "-------------------------------------------------------"
echo "|       Warning !!!  Please Enter Right Choice!       |"
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