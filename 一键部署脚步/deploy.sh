#!/bin/bash


SERVER[0]='1.1.1.1'
SERVER[1]='1.1.1.2'
REMOTE_SYSTEM_USER='root'

TMP_FILE="/tmp/`date +"%Y%m%d%S%s"`.server"
touch ${TMP_FILE}
which expect &>/dev/null|| exit 1
n=0
for i in ${SERVER[@]}
do
        GET_IP=`ifconfig |grep -iwo $i`
        if [ $? -eq 0 ];then
                LOCAL_HOST=${SERVER[$n]}
        else
                ping -c2 ${SERVER[$n]} &>/dev/null
                [ $? -eq 0 ]&&echo ${SERVER[$n]} >>${TMP_FILE}
                REMOTE_HOST=${SERVER[$n]}
        fi
        let n++
done
if [ `expr $n - 1` -eq `wc -l ${TMP_FILE} |cut -d' ' -f1` ];then
        rm -rf ${TMP_FILE}
else
        rm -rf ${TMP_FILE}
        exit
fi


#执行mysql双向复制script
bash mysql_config.sh 



#执行ssh双向信任

bash ssh_config.sh 




#检测是否配置双机互信，以及判断是否安装expect软件包
function sshCheck()
{
	if `which expect >/dev/null2>&1`;then
        	env expect -c "
                	set timeout 7
                	spawn ssh -o VerifyHostKeyDNS=no -o StrictHostKeyChecking=no -o ConnectTimeout=4 root@${REMOTE_HOST} 'echo 1 >/dev/null' >/dev/null 2>&1
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
					\"#\" {
						exit 0
					}
                	}
        	">/dev/null
        	if [ "$?" -ne 0 ];then
                	exit 1
        	fi
	else
        	echo experr
        	exit 1
	fi
}

sshCheck
while [ $? -ne 0 ]
do
	sleep 1
	sshCheck
	
	if [ $? -eq 0 ];then
		break
	fi
done

if [ "${LOCAL_HOST}" = '1.1.1.1' ];then
	dpkg -i fort_master_rsync_1.0_amd64.deb
	scp fort_slave_rsync_1.0_amd64.deb ${REMOTE_SYSTEM_USER}@${REMOTE_HOST}:/root
	ssh ${REMOTE_HOST} 'dpkg -i /root/fort_slave_rsync_1.0_amd64.deb'
        	env expect -c "
                	set timeout 7
                	spawn ssh -o VerifyHostKeyDNS=no -o StrictHostKeyChecking=no -o ConnectTimeout=4 root@${REMOTE_HOST} 
                	expect 	\"#\" {
						send \"cd /usr/local/GNU-Linux-x86\n\"
						send \"./sersync2 -d -r ./confxml.xml\n\"
						send \"./sersync2 -d -r -o ./confxml1.xml\n\"
						send \"exit\n\"
					}
			expect  timeout { send_user \"Connection timeout\n\"}
		"
	if [ $? = 0 ];then
		cd /usr/local/GNU-Linux-x86/
		./sersync2 -d -r ./confxml.xml
		sleep 1
		./sersync2 -d -r -o ./confxml1.xml
	fi
else
	dpkg -i fort_slave_rsync_1.0_amd64.deb
	scp fort_master_rsync_1.0_amd64.deb ${REMOTE_SYSTEM_USER}@${REMOTE_HOST}:/root
	ssh ${REMOTE_HOST} 'dpkg -i /root/fort_master_rsync_1.0_amd64.deb'
        	env expect -c "
                	set timeout 7
                	spawn ssh -o VerifyHostKeyDNS=no -o StrictHostKeyChecking=no -o ConnectTimeout=4 root@${REMOTE_HOST} 
                	expect 	\"#\" {
						send \"cd /usr/local/GNU-Linux-x86\n\"
						send \"./sersync2 -d -r ./confxml.xml\n\"
						send \"./sersync2 -d -r -o ./confxml1.xml\n\"
						send \"exit\n\"
					}
			expect  timeout { send_user \"Connection timeout\n\"}
		"
	if [ $? = 0 ];then
		cd /usr/local/GNU-Linux-x86/
		./sersync2 -d -r ./confxml.xml
		sleep 1
		./sersync2 -d -r -o ./confxml1.xml
	fi
fi
