#!/bin/bash
#-------------------------------------------------------------------
#Filename:	change_heartbeat_config.sh
#Revision:	2.0.0
#Author:	chunyunzeng@hotmail.com
#Date:		2015-8-02 01:00 CST
#Description: Config heartbeat service
#------------------------------------------------------------------

HA_VIP=$1
HA_NIC=$2
HA_IP=$3
PING_IP=$4
MASTER_HA=$5

function helpDoc()
{
	printf "\tVersion:\t2.0.0"
	printf "\n语法: bash $0 \$1 \$2 \$3 \$4 \$5\n"
	printf "示例: bash $0 192.168.23.130/24/eth0 eth1 1.1.1.2 192.168.23.125 0\n"
	printf "\$1\t虚拟对外服务IP地址/虚拟IP子网掩码/对外服务工作网卡名称\n\t示例:\t192.168.1.1/24/eth0\n"
	printf "\$2\t本机与对端Heartbeat心跳线同网段的网卡名称\n\t示例:\teth1\n"
	printf "\$3\t对端Heartbeat心跳线的IP地址\n\t示例:\t1.1.1.2\n"
	printf "\$4\t用来检测网络是否正常连通的参考IP\n\t示例:\t192.168.1.11\n"
	printf "\$5\t如果希望本机是master则值为0\t如果希望本机设置为slave则值为1\t默认值为0\n\t示例:\t0\n"
	printf "返回值参照: \n返回值\t描述信息\n"
	printf "1\t++++++Heartbeat服务配置成功++++++\n"
	printf "2\t++++++上一次配置未完成，请等待10s再进行修改++++++\n"
	printf "3\t++++++Heartbeat虚拟VIP已经被占用，请更换其它可用IP++++++\n\t第一个参数需要修改\n"
	printf "4\t++++++Heartbeat心跳线IP地址无法连接++++++\n\t第三个参数需要修改\n"
	printf "5\t++++++请不要使用本机IP地址作为Heartbeat心跳线IP++++++\n\t第三个参数需要修改\n"
	printf "6\t++++++Heartbeat的工作网卡和工作网段不匹配++++++\n\t第一个参数需要修改\n"
	printf "7\t++++++Heartbeat的心跳线网卡和心跳线网段不匹配++++++\n\t第二个参数网卡对应的网段应和第三个参数为同一网段\n"
	printf "8\t++++++IP地址格式不正确++++++\n\t第一，三，四个参数必须符合IP标准格式\n"
	printf "9\t++++++SSH双向互信服务配置不正确++++++\n\t第三个参数需要修改\n"
	printf "haerr\t++++++本机Heartbeat服务没有正确安装++++++\n"
	printf "phaerr\t++++++对端Heartbeat服务没有正确安装++++++\n"
	printf "hosterr\t++++++本地主机名与对端主机名不能相同++++++\n"
	printf "pingerr\t++++++参考IP地址不可达++++++\n\t第四个参数需要修改\n"
	printf "nicerr\t++++++请检查本机是否存在该网卡名称++++++\n\t第二个参数需要修改\n"
	printf "neterr\t++++++请检查Heartbeat虚拟VIP掩码格式是否正确++++++\n\t第一个参数需要修改\n"
	printf "experr\t++++++请检查软件包expect是否安装正确++++++\n\n"
}

#检测参数是否传递完整
if [ "$#" -ne 5 ];then
	helpDoc
	exit 1
fi

#检测Heartbeat服务是否安装
HA_DIR='/etc/ha.d'
HA_DIR_U='/usr'
HA_CONF="${HA_DIR}/ha.cf"
HA_CONF_S="${HA_DIR}/haresources"
HA_DAEMON='/etc/init.d/heartbeat'
HA_LOG='/var/log/ha-log'
if [ ! -e "${HA_DIR}" ];then
	echo 'haerr'
	exit 1
fi

#检测参数IP地址格式是否正确
for ip in "${HA_IP}" "${PING_IP}" "`echo ${HA_VIP}|sed -r 's/\/.*$//'`"
do 
	echo "${ip}"|grep "^[0-9]\{1,3\}\.\([0-9]\{1,3\}\.\)\{2\}[0-9]\{1,3\}$" >/dev/null 2>&1
	if [ "$?" -ne 0 ];then
		echo 8
		exit 1
	else
		read a b c d < <(echo "${ip}" |awk -F'.' '{print $1,$2,$3,$4}')
		for num in $a $b $c $d
		do
			if [ "${num}" -gt 255 ]||[ "${num}" -lt 0 ]||[ "${a}" -lt 1 -o "${d}" -lt 1 ]||[ "${d}" -gt 254 ];then
					echo 8
					exit 1
			fi
		done
	fi
done

#判断工作接口是否和工作IP在同一个网段
HA_WORK_NET="`echo ${HA_VIP}|sed -r 's/\/.*$//'|cut -d'.' -f-3`"
HA_WORK_NIC="`echo ${HA_VIP}|cut -d'/' -f3`"
CHECK_RETURN="`ifconfig ${HA_WORK_NIC} 2>/dev/null|grep -wi "${HA_WORK_NET}" >/dev/null 2>&1`"
if [ "$?" -ne 0 ];then
	echo 6
	exit 1
fi

#检测Heartbeat服务虚拟IP是否可用
ifconfig |grep -wi "${HA_WORK_NET}" >/dev/null 2>&1
if [ "$?" -ne 0 ];then
	echo 3
	exit 1
fi

#检查本机是否存在HA NIC这块网卡设备，不存在则退出
ifconfig -s |grep -wi "${HA_NIC}" >/dev/null 2>&1
if [ "$?" -ne 0 ];then
	echo nicerr
	exit 1
fi

#检查虚拟VIP掩码输入是否正确
CHECK_HA_VIP_NET=`echo "${HA_VIP}"|cut -d'/' -f2|grep '^[0-9]\{1,2\}$' 2>/dev/null`
if [ "$?" -ne 0 ];then
	echo neterr
	exit 1
elif [ "${CHECK_HA_VIP_NET}" -gt 32 ]||[ "${CHECK_HA_VIP_NET}" -lt 1 ];then
	echo neterr
	exit 1
fi	

#检测对端心跳地址是否在线
HA_IP_NET="`echo ${HA_IP}|cut -d'.' -f-3`"
ifconfig |grep -wi "${HA_IP_NET}" >/dev/null 2>&1
if [ "$?" -ne 0 ];then
	echo 4
	exit 1
else
	ping -c3 "${HA_IP}" >/dev/null 2>&1
	if [ "$?" -ne 0 ];then
		echo 4
		exit 1
	fi
fi

#检测该心跳地址是否为本机IP地址，如果是，则退出
CHECK_HA_IP="`ifconfig ${HA_NIC}|grep -wi "${HA_IP}"`"
if [ "${CHECK_HA_IP}" != "" ];then
	echo 5
	exit 1
fi

#检测PING IP是否在线
PING_IP_NET="`echo ${PING_IP}|cut -d'.' -f-3`"
ifconfig |grep -wi "${PING_IP_NET}" >/dev/null 2>&1
if [ $? -ne 0 ];then
	echo pingerr
	exit 1
else
	ping -c3 "${PING_IP}" >/dev/null 2>&1
	if [ "$?" -ne 0 ];then
		echo pingerr
		exit 1
	fi
fi

#检测是否配置双机互信，以及判断是否安装expect软件包
if `which expect >/dev/null2>&1`;then
	env expect -c "
		set timeout 7
		spawn ssh -o VerifyHostKeyDNS=no -o StrictHostKeyChecking=no -o CheckHostIP=no -o ConnectTimeout=4 root@${HA_IP} 'echo 1 >/dev/null' >/dev/null 2>&1
		expect {
				timeout {
					exit 1
				}
				\"Connection refused\" {
					exit 1
				}
				\"assword:\" {
					exit 1
				}
		}
	">/dev/null
	if [ "$?" -ne 0 ];then
		echo 9
		exit 1
	fi
else
	echo experr
	exit 1
fi

#检查对端Heartbeat服务是否安装
ssh -o StrictHostKeyChecking=no 'root'@${HA_IP} '[ -e '${HA_DIR}' ]' >/dev/null 2>&1
if [ "$?" -ne 0 ];then
	echo 'phaerr'
	exit 1
fi

#检测Heartbeat服务工作状态
if [ -e "${HA_DAEMON}" ];then
	HA_STATUS="`${HA_DAEMON} status 2>/dev/null|awk '{print $2}'`"
	NEW_VIP="`echo ${HA_VIP}|sed -r 's/\/.*$//'`"
	
	#检测Heartbeat服务虚拟IP是否已经启用，没有启用，则需要等待10s
	if [ "${HA_STATUS}" = "OK" ];then
		LOCAL_IP=("`ifconfig |egrep -A2 "[[:alpha:]].*[[:digit:]]:[[:digit:]].*"|grep -wi 'inet'|awk '{print $2}'|sed -r 's/.*\://g'`")
		for ip in ${LOCAL_IP}
		do
			VIP_RETURN="`grep -v '^#' "${HA_CONF_S}"|grep -wi "${ip}"`"
			if [ $? -eq 0 ];then
				VIP="`echo ${VIP_RETURN}|awk '{print $2}'|sed 's/\/.*$//g'`"
			fi
		done

		if [ "${VIP}" = "" ];then
			REMOTE_IP="`ssh -o StrictHostKeyChecking=no 'root'@${HA_IP} 'ifconfig |egrep -A2 "[[:alpha:]].*[[:digit:]]:[[:digit:]].*"|grep -wi 'inet'|xargs |sed -r 's/[[:alpha:]]//g'|sed "s/[0-9]\{1,3\}\.\([0-9]\{1,3\}\.\)\{2\}\(255\|0\)//g"|sed -r 's/\://g''`"
			for ip in ${REMOTE_IP}
			do
				VIP_RETURN="`ssh -o StrictHostKeyChecking=no 'root'@${HA_IP} 'grep -v '^#' '${HA_CONF_S}'|grep -wi '${ip}''`"
				if [ $? -eq 0 ];then
					VIP="`echo ${VIP_RETURN}|awk '{print $2}'|sed 's/\/.*$//g'`"
				fi
			done
		fi
	
		#检测Heartbeat服务工作是否正常，请确保服务日志存放位置
		cat ${HA_LOG} >> "${HA_LOG}.`date +'%Y%m'`"
		echo > ${HA_LOG}
		sleep 2
		HA_RETURN="`grep -wi 'ERROR' ${HA_LOG}`"

        	if [ "${VIP}" = "" -a "${HA_RETURN}" = "" ];then
                	echo 2
                	exit 1
        	fi
		if [ "${HA_RETURN}" != "" ];then
			HA_WORK_NIC=("`grep -v '^#' "${HA_CONF_S}" |awk '{print $2}'|sed 's/.*\///'`")
			for nic in ${HA_WORK_NIC}
			do
				LOCAL_NIC=("`ifconfig |cut -d' ' -f1|grep  '\:[[:digit:]]'|grep -wi "${nic}"`")
				if [ "${LOCAL_NIC}" != "" ];then
					for active_nic in ${LOCAL_NIC}
					do 
						if [ "${active_nic}" != "" ];then
							ifconfig ${active_nic} down
						fi
					done

					for active_nic in `ssh -o StrictHostKeyChecking=no 'root'@${HA_IP} 'ifconfig -s' |awk '{print $1}'|egrep '\:'`
					do
						if [ "${active_nic}" != "" ];then
							ssh -o StrictHostKeyChecking=no 'root'@${HA_IP} 'ifconfig '${active_nic}' down'
						fi
					done
				fi
			done
			ssh -o StrictHostKeyChecking=no 'root'@${HA_IP} 'killall -9 heartbeat' >/dev/null 2>&1
			killall -9 heartbeat >/dev/null 2>&1
		fi
		VIP_RETURN="`grep -v '^#' "${HA_CONF_S}"|grep -wi "${NEW_VIP}"`"
		if [ "${VIP_RETURN}" = "" ];then
			#检测Heartbeat服务虚拟IP是否可用
			ping -c3 ${NEW_VIP} >/dev/null 2>&1
			if [ "$?" -eq 0 ];then
				echo 3
				exit 1
			fi
		fi
	else
		#检测Heartbeat服务虚拟IP是否可用
		ping -c3 ${NEW_VIP} >/dev/null 2>&1
		if [ "$?" -eq 0 ];then
			echo 3
			exit 1
		fi
	fi
else
	echo haerr
	exit 1
fi

#判断心跳网卡是否和心跳IP在同一个网段
HA_IP_NET="`echo ${HA_IP}|cut -d'.' -f-3`"
CHECK_RETURN="`ifconfig ${HA_NIC} 2>/dev/null|grep -wi "${HA_IP_NET}" >/dev/null 2>&1`"
if [ "$?" -ne 0 ];then
	echo 7
	exit 1
fi


#创建Heartbeat配置文件
function createHaConf() 
{	
cat > $FILE <<EOF
logfacility     local0
auto_failback on
logfile /var/log/ha-log
logfacility local0
autojoin none
ucast ${HA_NIC} ${IP}
ping ${PING_IP}
respawn hacluster /usr/lib/heartbeat/ipfail
udpport 694
deadtime 3
initdead 5
keepalive 1
node ${LOCAL_NAME}
node ${REMOTE_NAME}
EOF
cat >$FILE2<<EOF
${MASTER_HA} ${HA_VIP}
EOF
}

function configHosts()
{
	LOCAL_NAME=`cat /etc/hostname`
	LOCAL_HA_IP="`ifconfig ${HA_NIC}|grep -wi 'inet'|awk '{print $2}'|sed -r 's/.*\://g'`"
	REMOTE_NAME=`ssh -o StrictHostKeyChecking=no 'root'@${HA_IP} 'cat /etc/hostname'`
	#检查两台主机名是否相同，相同则退出
	if [ "${LOCAL_NAME}" = "${REMOTE_NAME}" ];then
		echo hosterr
		exit 1
	fi	
	#修改本机hosts文件
	for ip in `egrep -v '^#|^127|^$' /etc/hosts|grep -wi "${LOCAL_NAME}"|awk '{print $1}'`
	do 
		if [ "${ip}" != "" ];then
			sed -r -i 's/'${ip}'/'${LOCAL_HA_IP}'/' /etc/hosts
		fi
	done

	for ip in `egrep -v '^#|^127|^$' /etc/hosts|grep -wi "${REMOTE_NAME}"|awk '{print $1}'`
	do
		if [ "${ip}" != "" ];then
			sed -r -i 's/'${ip}'/'${HA_IP}'/' /etc/hosts
		fi
	done
	
	GET_CONF=`grep -wi "${HA_IP}" /etc/hosts`
	if [ "${GET_CONF}" = "" ];then
		echo -e "${HA_IP}\t${REMOTE_NAME}" >>/etc/hosts
	fi

	GET_CONF=`ssh -o StrictHostKeyChecking=no 'root'@${HA_IP} 'grep -wi '${HA_IP}' /etc/hosts'`
	if [ "${GET_CONF}" = "" ];then
		ssh -o StrictHostKeyChecking=no 'root'@${HA_IP} "echo -e '${HA_IP}\t${REMOTE_NAME}' >>/etc/hosts"
	fi
	#修改对端主机hosts文件
	for ip in `ssh -o StrictHostKeyChecking=no 'root'@${HA_IP} "egrep -v '^#|^127|^$' /etc/hosts"|grep -wi "${REMOTE_NAME}"|awk '{print $1}'`
	do
		if [ "${ip}" != "" ];then
			ssh -o StrictHostKeyChecking=no 'root'@${HA_IP} "sed -r -i 's/'${ip}'/'${HA_IP}'/' /etc/hosts"
		fi
	done

	for ip in `ssh -o StrictHostKeyChecking=no 'root'@${HA_IP} "egrep -v '^#|^127|^$' /etc/hosts"|grep -wi "${LOCAL_NAME}"|awk '{print $1}'`
	do
		if [ "${ip}" != "" ];then
			ssh -o StrictHostKeyChecking=no 'root'@${HA_IP} "sed -r -i 's/'${ip}'/'${LOCAL_HA_IP}'/' /etc/hosts"
		fi
	done

	GET_CONF=`grep -wi "${LOCAL_HA_IP}" /etc/hosts`
	if [ "${GET_CONF}" = "" ];then
		echo -e "${LOCAL_HA_IP}\t${LOCAL_NAME}" >>/etc/hosts
	fi

	GET_CONF=`ssh -o StrictHostKeyChecking=no 'root'@${HA_IP} 'grep -wi '${LOCAL_HA_IP}' /etc/hosts'`
	if [ "${GET_CONF}" = "" ];then
		ssh -o StrictHostKeyChecking=no 'root'@${HA_IP} "echo -e '${LOCAL_HA_IP}\t${LOCAL_NAME}' >>/etc/hosts"
	fi
}

configHosts

#如果第五个参数为0，则本机为主，如果参数为1，则本机为从，否则本机为从
if [ "${MASTER_HA}" = 0 ];then
        MASTER_HA=${LOCAL_NAME}
elif [ "${MASTER_HA}" = 1 ];then
        MASTER_HA=${REMOTE_NAME}
else
        MASTER_HA=${LOCAL_NAME}
fi

FILE="${HA_CONF}"
FILE2="${HA_CONF_S}"
IP=${LOCAL_HA_IP}
ssh -o StrictHostKeyChecking=no 'root'@${HA_IP} ''${HA_DAEMON}' stop' >/dev/null 2>&1
${HA_DAEMON} stop >/dev/null 2>&1

createHaConf
scp ${FILE} 'root'@${HA_IP}:${FILE} >/dev/null 2>&1
scp ${FILE} 'root'@${HA_IP}:${HA_DIR_U}${FILE} >/dev/null 2>&1
scp ${FILE2} 'root'@${HA_IP}:${FILE2} >/dev/null 2>&1
scp ${FILE2} 'root'@${HA_IP}:${HA_DIR_U}${FILE2} >/dev/null 2>&1
ssh -o StrictHostKeyChecking=no 'root'@${HA_IP} ''${HA_DAEMON}' start' >/dev/null 2>&1
IP=${HA_IP}
createHaConf
\cp -rf ${FILE} ${HA_DIR_U}${FILE}
\cp -rf ${FILE2} ${HA_DIR_U}${FILE2}

${HA_DAEMON} start >/dev/null 2>&1

echo 1
exit 0
