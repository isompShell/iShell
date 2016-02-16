#!/bin/bash
#
#Name		:ssh config
#Version	:1.0.0
#Release	:1.el7_1
#Architecture	:x86,x86_64
#Date		:2015-6-24 14:00
#Release By	:chunyunzeng@hotmail.com
#Summary	:for auto config ssh server
#Description	:this script has testing with debian 7.5.
#Notice		:


TMP_FILE="/tmp/`date +"%Y%m%d"`.server"
touch ${TMP_FILE}
SERVER[0]="1.1.1.1"
SERVER[1]="1.1.1.2"

REMOTE_SYSTEM_USER="root"
REMOTE_SYSTEM_PWD="m2a1s2u3000"
FILE1='/etc/ssh/sshd_config'
FILE2='/etc/ssh/ssh_config'
FILE3='/root/.ssh/'
ACTION=0


which expect &>/dev/null|| exit 1
n=0
for i in ${SERVER[@]}
do
	GET_IP=`ifconfig |grep -iwo $i`
	if [ $? -eq 0 ];then
		LOCAL_IP=${SERVER[$n]}
	else
		ping -c2 ${SERVER[$n]} &>/dev/null
		[ $? -eq 0 ]&&echo ${SERVER[$n]} >>${TMP_FILE}
		REMOTE_IP=${SERVER[$n]}
	fi
	let n++
done
if [ `expr $n - 1` -eq `wc -l ${TMP_FILE} |cut -d' ' -f1` ];then
	rm -rf ${TMP_FILE}
else
	rm -rf ${TMP_FILE}
	exit 8
fi

function execSSH {
case $1 in
	ssh)
		REMOTE_IP=$2
		CMD="ssh ${REMOTE_SYSTEM_USER}@${REMOTE_IP}"
		ACTION=$3
	;;
	scp)
		FILE_NAME=$2
		REMOTE_IP=$3
		REMOTE_PATH=$4
		CMD="scp ${FILE_NAME} ${REMOTE_SYSTEM_USER}@${REMOTE_IP}:${REMOTE_PATH}"
	;;
esac
/usr/bin/env expect -c"
	set timeout 10
	spawn $CMD
	expect {
                timeout {
                        send_user \"\nFirewall issue\n\"
			exit 2
                        }
                \"Connection refused\" {
                        send_user \"\nSSH service has not open\n\"
                        exit 3
                        }
                "yes/no" {
                        send \"yes\r\";exp_continue
                        }
                \"assword:\" {
                        send \"${REMOTE_SYSTEM_PWD}\r\"
                        }
                }
                expect  \"assword:\" {
                        send_user \"Password is incorrect\n\"
                        exit 4
                }
if { ${ACTION} == 1 } {
	send \"rm -rf ${FILE3}id_rsa ${FILE3}id_rsa.pub ${FILE3}known_hosts\r\"
	send \"ssh-keygen -t rsa -P '' -f ${FILE3}id_rsa\r\"
	expect eof
}
"
}

sed -i -r 's/^#AuthorizedKeysFile/AuthorizedKeysFile/g' ${FILE1}
#sed -i -r 's/^.*PasswordAuthentication.*$/PasswordAuthentication\tno/g' ${FILE1}
sed -i -r 's/^.*PasswordAuthentication.*(yes|no)$/PasswordAuthentication\tyes/g' ${FILE1}
sed -i -r 's/^[[:space:]].*GSSAPIAuthentication/#&/g' ${FILE2}
sed -i -r 's/^[[:space:]].*GSSAPIDelegateCredentials/#&/g' ${FILE2}
sed -i -r 's/^#.*[[:space:]]StrictHostKeyChecking.*$/StrictHostKeyChecking\tno/g' ${FILE2}


#if ssh ${REMOTE_SYSTEM_USER}@${REMOTE_IP} 'echo -n';then
#	echo -e "\e[0;31mSSH service has configured\e[0m"
#	exit 0
#fi

rm -rf ${FILE3}
ssh-keygen -t rsa -P '' -f ${FILE3}id_rsa >/dev/null2>/dev/null


echo "${LOCAL_IP} server status as below"
/etc/init.d/ssh restart
execSSH ssh ${REMOTE_IP} 1 >/dev/null2>/dev/null
[ $? != 0 ]&&exit 4
ACTION=0
execSSH scp ${FILE1} ${REMOTE_IP} ${FILE1} >/dev/null2>/dev/null
execSSH scp ${FILE2} ${REMOTE_IP} ${FILE2} >/dev/null2>/dev/null
execSSH scp ${FILE3}id_rsa.pub ${REMOTE_IP} ${FILE3}authorized_keys >/dev/null2>/dev/null
scp ${REMOTE_IP}:${FILE3}id_rsa.pub ${FILE3}authorized_keys >/dev/null2>/dev/null
chmod 600 ${FILE3}authorized_keys
ssh ${REMOTE_SYSTEM_USER}@${REMOTE_IP} "chmod 600 ${FILE3}authorized_keys" >/dev/null2>/dev/null
echo "${REMOTE_IP} server status as below"
echo -e -n "[\e[0;31m ok \e[0m] "
ssh ${REMOTE_SYSTEM_USER}@${REMOTE_IP} '/etc/init.d/ssh restart'
