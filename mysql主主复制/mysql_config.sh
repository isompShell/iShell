#!/bin/bash
#
#Name           :mysql config
#Version        :2.0.0
#Release        :1.el7_1
#Architecture   :x86,x86_64
#Date           :2015-9-18 09:00
#Release By     :chunyunzeng@hotmail.com
#Summary        :for auto config mysql replication
#Description    :this script has testing with mysql-5.6.21&mysql-5.6.22 platform.
#Notice         :mysql server has no password for super account of root,if need please modify script


SERVER[0]='1.1.1.1'
SERVER[1]='1.1.1.2'
REMOTE_SYSTEM_USER='root'
REMOTE_SYSTEM_PWD='m2a1s2u3000'

MYSQL_USER='mysql'
MYSQL_PWD='m2a1s2u!@#'
MYSQL_PORT='3306'
MYSQL_LOCAL='127.0.0.1'
MYSQL_HOST='localhost'
REPL_USER='mysql'
REPL_PWD='m2a1s2u!@#'
REPL_DB='fort'
IGNORE_REPL_DB='mysql'

BASEDIR='/usr/local/mysql'
DATADIR='/usr/local/mysql/data'
UUID_FILE="${DATADIR}/auto.cnf"
MYSQL_DAEMON='/etc/init.d/mysql'
TIMEOUT='15'
ACTION=0


TMP_FILE="/tmp/`date +"%Y%m%d%S%s"`.server"
touch ${TMP_FILE}
which mysql &>/dev/null||exit 1
which expect &>/dev/null|| exit 1
pgrep mysql &>/dev/null||exit 1
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

#是否删除uuid文件，如果是第二次运行该脚本，可以选择不删除
#0为删除，1为不删除
UUID_FILE_DEL='0'

#是否重启mysql服务，如果第二次运行该脚本，可以选择不重启
#0为重启，1为不重启
MYSQL_SERVICE_RESTART='0'



function configMysql()
{
	case $1 in
		grant)
			#本机mysql用户授权
			GRANT_REPL_IP="GRANT ALL PRIVILEGES ON *.* TO '${REPL_USER}'@'${REPL_IP}' IDENTIFIED BY '${REPL_PWD}' WITH GRANT OPTION;"
			mysql -u"${MYSQL_USER}" -p"${MYSQL_PWD}" -h"${MYSQL_HOST}" -P"${MYSQL_PORT}" <<END 2>/dev/null
${GRANT_REPL_IP}
${GRANT_MYSQL_HOST}
${GRANT_MYSQL_LOCAL}
${FLUSH}
END
			if [ "${UUID_FILE_DEL}" = '0' ];then
				rm -rf ${UUID_FILE} >/dev/null 2>&1
			fi
			if [ "${MYSQL_SERVICE_RESTART}" = '0' ];then
				${MYSQL_DAEMON} restart >/dev/null 2>&1
			fi
		;;
		revoke)
			mysql -u"${MYSQL_USER}" -p"${MYSQL_PWD}" -h"${MYSQL_HOST}" -P"${MYSQL_PORT}" <<END 2>/dev/null
${REMOVE_MYSQL_USER}
${REMOVE_MYSQL_ALL}
END
		;;
		status)
			#查询master信息
			LOG_FILE=`mysql -u"${REPL_USER}" -p"${REPL_PWD}" -h"${REMOTE_IP}" -P"${MYSQL_PORT}" <<END 2>/dev/null|grep -i 'file' |awk '{print $2}'
show master status\G;
END`

			LOG_POS=`mysql -u"${REPL_USER}" -p"${REPL_PWD}" -h"${REMOTE_IP}" -P"${MYSQL_PORT}" <<END 2>/dev/null|grep -i 'pos' |awk '{print $2}'
show master status\G;
END`
		;;
		set_slave)
			CHANGE="CHANGE MASTER TO MASTER_USER='${REPL_USER}',MASTER_PASSWORD='${REPL_PWD}',MASTER_HOST='${REPL_IP}',MASTER_LOG_FILE='${LOG_FILE}',MASTER_LOG_POS=${LOG_POS};"
			mysql -u"${REPL_USER}" -p"${REPL_PWD}" -h"${REMOTE_IP}" -P"${MYSQL_PORT}"<<END 2>/dev/null
STOP SLAVE;
${CHANGE}
START SLAVE;
END
		;;
		show_result)
		mysql -u"${REPL_USER}" -p"${REPL_PWD}" -h"${REMOTE_IP}" -P"${MYSQL_PORT}" <<END 2>/dev/null |grep -i 'running'
SHOW SLAVE STATUS\G;
END
		;;
		my_cnf)
			cat >/tmp/my.cnf <<END
[client]
default-character-set=UTF8
port            = ${MYSQL_PORT}
socket          = /tmp/mysql.sock
default-character-set=UTF8

[mysqld]
log_bin_trust_function_creators=1
character-set-server=UTF8
event_scheduler = 1
max_connections=1000
group_concat_max_len = 20000
basedir = ${BASEDIR}
datadir = ${DATADIR}
port = ${MYSQL_PORT}
socket = /tmp/mysql.sock
key_buffer = 384M
max_allowed_packet = 1M
sort_buffer_size = 2M
read_buffer_size = 2M
read_rnd_buffer_size = 8M
myisam_sort_buffer_size = 64M
thread_cache_size = 8
query_cache_size = 32M
thread_concurrency = 8
sql_mode=NO_ENGINE_SUBSTITUTION
server-id=${SERVER_ID}
log-bin=mysql-bin
binlog-do-db=${REPL_DB}
binlog-ignore-db=${IGNORE_REPL_DB}
log-slave-updates
sync-binlog=1
auto-increment-increment=2
auto-increment-offset=1
replicate-do-db=${REPL_DB}
replicate-ignore-db=${IGNORE_REPL_DB}

[mysqldump]
quick
max_allowed_packet = 16M

[mysql]
no-auto-rehash

[isamchk]
key_buffer = 256M
sort_buffer_size = 256M
read_buffer = 2M
write_buffer = 2M

[myisamchk]
key_buffer = 256M
sort_buffer_size = 256M
read_buffer = 2M
write_buffer = 2M

[mysqlhotcopy]
interactive-timeout,STRICT_TRANS_TABLES
END
		;;
esac
}
function execShell()
{
	case $1 in
		ssh)
			GRANT_REPL_IP="GRANT ALL PRIVILEGES ON *.* TO '${REPL_USER}'@'${REPL_IP}' IDENTIFIED BY '${REPL_PWD}' WITH GRANT OPTION;"
			REMOTE_HOST=$2
			CMD="ssh -o CheckHostIP=no -o PubkeyAuthentication=no -o PasswordAuthentication=yes -o StrictHostKeyChecking=no ${REMOTE_SYSTEM_USER}@${REMOTE_HOST}"
			ACTION=$3
			/usr/bin/env expect -c"
        			set timeout ${TIMEOUT}
        			spawn ${CMD}
        			expect \"assword\" { send \"${REMOTE_SYSTEM_PWD}\r\" }

			if { ${ACTION} == 1 } {
				expect \"#\" {
        				send \"rm -rf ${UUID_FILE}\n\"
					send \"mysql -u${MYSQL_USER} -p\'${MYSQL_PWD}\' -P${MYSQL_PORT} -h${MYSQL_HOST} <<END 2>/dev/null\n${GRANT_REPL_IP}\n${GRANT_MYSQL_HOST}\n${GRANT_MYSQL_LOCAL}\n${FLUSH}\nEND\n\"
        				send \"nohup ${MYSQL_DAEMON} restart &\n\"
					send \"exit\n\"
				}
				expect  timeout { send_user \"Connection timeout\n\"}
			}
			if { ${ACTION} == 2 } {
				expect \"#\" {
					send \"mysql -u${MYSQL_USER} -p\'${MYSQL_PWD}\' -P${MYSQL_PORT} -h${MYSQL_HOST} <<END 2>/dev/null\n${REMOVE_MYSQL_USER}\n${REMOVE_MYSQL_ALL}\nEND\n\"
					send \"exit\n\"
				}
				expect  timeout { send_user \"Connection timeout\n\"}
			}
"
		;;
		scp)
			FILE_NAME=$2
			REMOTE_HOST=$3
			REMOTE_PATH=$4
			CMD="scp -o CheckHostIP=no -o PubkeyAuthentication=no -o PasswordAuthentication=yes -o StrictHostKeyChecking=no ${FILE_NAME} ${REMOTE_SYSTEM_USER}@${REMOTE_HOST}:${REMOTE_PATH}"
			/usr/bin/env expect -c"
        		set timeout ${TIMEOUT}
        		spawn ${CMD}
        		expect \"assword\" { send \"${REMOTE_SYSTEM_PWD}\r\" }
			expect  timeout { send_user \"Connection timeout\n\"}
		"
		;;
	esac
}

#授予复制用户所有权限，以及授予mysql用户127.0.0.1和localhost登陆权限
GRANT_MYSQL_HOST="GRANT ALL PRIVILEGES ON *.* TO '${MYSQL_USER}'@'${MYSQL_HOST}' IDENTIFIED BY '${MYSQL_PWD}' WITH GRANT OPTION;"
GRANT_MYSQL_LOCAL="GRANT ALL PRIVILEGES ON *.* TO '${MYSQL_USER}'@'${MYSQL_LOCAL}' IDENTIFIED BY '${MYSQL_PWD}' WITH GRANT OPTION;"
FLUSH="FLUSH PRIVILEGES;"
#移除非mysql登陆用户，以及非授权用户
REMOVE_MYSQL_USER="DELETE FROM mysql.user WHERE user!='${MYSQL_USER}';"
REMOVE_MYSQL_ALL="DELETE FROM mysql.user WHERE host='' or host='%';"
#生成远程主机mysql配置文件
SERVER_ID=`echo ${REMOTE_HOST} |awk -F'.' '{print $4}'`

configMysql my_cnf >/dev/null 2>&1
execShell scp /tmp/my.cnf ${REMOTE_HOST} /etc/my.cnf >/dev/null 2>&1
#生成本地主机mysql配置文件
SERVER_ID=`echo ${LOCAL_HOST} |awk -F'.' '{print $4}'`
configMysql my_cnf >/dev/null 2>&1
mv -f /tmp/my.cnf /etc/my.cnf >/dev/null 2>&1

# 远程主机mysql授权操作
REPL_IP="${LOCAL_HOST}"
execShell ssh ${REMOTE_HOST} 1 >/dev/null 2>&1
ACTION=0
sleep 20

#本地主机mysql授权操作
REPL_IP="${REMOTE_HOST}"
configMysql grant >/dev/null 2>&1

#查询远程mysql master状态信息
REMOTE_IP=${REMOTE_HOST}
configMysql status >/dev/null 2>&1

#配置本地主机mysql复制
REMOTE_IP=${MYSQL_HOST}
REPL_IP=${REMOTE_HOST}
configMysql set_slave >/dev/null 2>&1

#查询mysql配置复制服务状态
REMOTE_IP=${MYSQL_HOST}
echo "${LOCAL_HOST} server status as below"
configMysql show_result 2>/dev/null

#查询本地mysql master状态信息
configMysql status >/dev/null 2>&1

#配置远程主机mysql复制
REMOTE_IP=${REMOTE_HOST}
REPL_IP=${LOCAL_HOST}
configMysql set_slave >/dev/null 2>&1

#查询mysql配置复制服务状态
echo "${REMOTE_HOST} server status as below"
configMysql show_result 2>/dev/null
#移除mysql非授予权限
configMysql revoke >/dev/null 2>&1
execShell ssh ${REMOTE_HOST} 2 >/dev/null 2>&1
