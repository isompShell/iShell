#!/bin/bash
#-----------------------------------------|
#Date     :2016/07/07
#Author   :Alger
#Mail     :alger_bin@foxmail.com
#Function :this script is backup session
#Version  :1.0
#-----------------------------------------|

#定义备份路径为当天的前一天
#log_path=`TZ=aaa16 date +%y/%m/%d`    #昨天
log_path=`date +%y/%m/%d`			   #今天
#判定目录是否存在
if [ ! -e "/var/log/simp_fort/session/$log_path" ]; then
	echo "No such file or directory"
	exit 0
fi
read -p "Compressed video file yes/no: " press
#查询目录内的会话名称
name=(`ls -lSr /var/log/simp_fort/session/$log_path |grep -v 'total'|awk '{print$9}'`)
#判断会话是否为空
if [ "$name" == "" ]; then
	echo "No such file or directory"
	exit 0
fi
#循环备份会话
for i in ${name[*]}; do
	sid=$i
	if [[ -z $sid ]] ; then
		echo "sid is null"
		exit 0
	fi
#设置mysql连接IP
IP=`netstat -antlp |grep 3306|grep -v 127 |grep -v "*" |awk '{print$5}'|cut -f 1 -d ":"|head -1`
#查询mysql字段，定义取值信息
cmd="use fort; select fort_operations_protocol_name,fort_user_account,fort_ip,fort_resource_name,fort_start_time from fort_audit_log where fort_session='$sid'"
ary=(`mysql -umysql -h ${IP-localhost} -p'm2a1s2u!@#' -e "$cmd" | grep -v fort_user_account`)
DATE=`date +"%y%m%d%H%M%S"`
TYPE=${ary[0]}
uid=${ary[1]}
aip=${ary[2]}
acc=${ary[3]}
path=`echo ${ary[4]}|sed '/-/s/-/\//g'|sed 's/^..//'`
#进入录像目录
cd /var/log/simp_fort/session/$path/$sid
#判定协议类型
	if [[ $TYEP == "ssh" || $TYPE == "ssh1" || $TYPE == "ssh2" || $TYPE == "telnet" ]] ; then
		type="cmd"
	elif [[ $TYPE == "vnc" ]] ; then
		type="vnc"
	elif [[ $TYPE == "xwin" ]] ; then
		type="xwin"
	else
		type="rdp"
	fi
#创建type,title文件
echo $TYPE > type
echo "$uid->$aip.$acc" > title
cd ..
#生成录像文件
tar cf $sid.vnc.logvd $sid
rm -rf /var/log/simp_fort/session/$path/$sid/type
rm -rf /var/log/simp_fort/session/$path/$sid/title
#打包录像文件
tar cf $sid.tar $sid $sid.vnc.logvd
rm -rf $sid.vnc.logvd
#是否压缩录像文件
	if [ "$press" == "yes" ]; then
		gzip -c $sid.tar > $sid.tar.gz
		mv $sid.tar.gz /temporary/
		echo "$sid Backup success!"
	else
		echo "Your video is not compressed."
		echo "$sid Backup success!"
	fi
done