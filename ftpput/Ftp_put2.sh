#!/bin/bash
#---------------------------------------------------------------------------------
#Filename:      ftp_transfer_file.sh
#Revision:      2.0.0
#Author:        chunyunzeng@hotmail.com
#Date: 2015-10-10 12:00 CST
#Description: ftp transfer file
#---------------------------------------------------------------------------------

#用户名，密码，ip地址
user="${1}"
password="${2}"
ip="${3}"
#local_dir="/var/log/simp_fort/session/${backup_time}"
local_dir="${4}"
remote_dir="${5:-'/'}"
before_time='1'


if ! echo ${remote_dir}|grep '/' >/dev/null 2>&1;then
	remote_dir="/${remote_dir}"
fi

#检查参数是否传递正确
if [ $# != 5 ];then
	echo "Usage: bash  $0 username password ip local_dir remote_dir "
	exit 1
fi
if ! which nmap >/dev/null 2>&1;then
	echo "nmap package not found"
	exit 1
fi


#定义当前执行时间，精确到纳秒
cur_time="`date +"%Y%m%d%N"`"

#日志文件名字定义
log_name='isomper'

#用于模拟ftp环境目录的临时目录结构，运行完脚本会自动删除
temp_folder="/tmp/${cur_time}"

#备份多少天前的数据，目录结构为:15/09/28
backup_time=`date -d"${before_time} day ago" +"%Y/%m/%d"|cut -b3-`

#需要备份的目录位置，注意：不能填写文件路径
upload_dir="${local_dir}"

#需要上传到ftp服务器上的具体目录
target_dir="${remote_dir}"
temp_dir=`echo ${target_dir}|cut -d'/' -f-2`

#临时纪录ftp上传的日志文件，用于作后续，如文件上传失败，文件少上传，作记录查询
log_file="/tmp/${log_name}_${cur_time}.log"


#定义临时存储新增文件列表的文件,用作增量上传处理
new_backup_file_list="/tmp/backup_list_${cur_time}.log"


function login_check_result()
{
	echo "0 backup failed..."
	echo "1 backup successed..."
	echo "2 ftp service unavailable"
	echo "3 login failed"
	echo "4 no data for backup"
}


function clean_temp_file()
{
	[ -e "${login_status_log}" ]&&rm -rf ${login_status_log} >/dev/null 2>&1
	[ -e "${new_backup_file_list}" ]&&rm -rf ${new_backup_file_list} >/dev/null 2>&1
	[ -e "${temp_upload_list}" ]&&rm -rf ${temp_upload_list} >/dev/null 2>&1
	[ -e "${temp_folder}" ]&&rm -rf ${temp_folder} >/dev/null 2>&1
    [ -e "${local_temp_dir}" ]&&rm -rf ${local_temp_dir} >/dev/null 2>&1
	[ -e "${log_file}" ]&&rm -rf ${log_file} >/dev/null 2>&1
}


#检测发送的是文件还是目录
local_temp_dir="/var/log/${cur_time}_tmp_dir"
if [ -e "${4}" ];then
        if [ -f "${4}" ];then
                [ -e "${local_temp_dir}" ]||mkdir -p ${local_temp_dir}
                rm -rf "${local_temp_dir}/*"
                cp -rf $4 ${local_temp_dir}
#需要备份的目录位置
                upload_dir="${local_temp_dir}"
        fi
fi



#上传前，记录文件的md5值，用于后续作增量比对用
last_md5sum_file_list="/var/log/${log_name}`echo "${upload_dir}"|sed 's#/#_#g'`.log"

if [ $# = 5 ];then
	rm -rf ${last_md5sum_file_list} >/dev/null 2>&1
fi


#检测ftp服务器21号端口是否处于工作状态，如果不是，则退出脚本，否则继续执行备份任务
status=$(nmap -n -p21 ${ip} 2>/dev/null|grep -i 'ftp'|cut -d' ' -f2)
if [ "${status}" != 'open' ];then
	#echo "`date |cut -d' ' -f2-4` ${ip} ftp service not open"
	clean_temp_file
	echo "2"
	exit 1
else
	#echo "`date |cut -d' ' -f2-4` ${ip} ftp service work well"
	#echo "`date |cut -d' ' -f2-4` will backup ${upload_dir} now ..."
	sleep 1
fi

#判断是否做过完整备份，如果做过，则进行增量对比，将改动或新增的文件，放在一个新的列表
if [ -e "${last_md5sum_file_list}" ];then
	[ -e "${new_backup_file_list}" ]&&rm -rf ${new_backup_file_list}
	cat ${last_md5sum_file_list} |while read line
	do
		echo "${line}"|md5sum -c >/dev/null 2>&1
		if [ $? != 0 ];then
#检查之前备份的文件是否有改动，如果有，则加入到备份列表
			new_file="$(echo ${line} |awk '{print $2}')"
			[ -e "${new_file}" ]&&echo ${line} |awk '{print $2}' >>${new_backup_file_list}
		fi
	done
	for file in $(find ${upload_dir} -type f 2>/dev/null)
	do
#检查是否有新增的文件，如果有，则加入到备份列表
		grep "${file}" ${last_md5sum_file_list} >/dev/null 2>&1||echo "${file}" >>${new_backup_file_list}
	done
	if [ ! -s "${new_backup_file_list}" ];then
		#echo "`date |cut -d' ' -f2-4` no data for backup..."
		clean_temp_file
		echo "4"
		exit 0
	fi
fi




#创建模拟ftp环境目录
[ -e "${temp_folder}/${target_dir}" ]||mkdir -p "${temp_folder}/${target_dir}"

#检查ftp目标目录是否存在，不存在则创建该目录
check_target=`find "${temp_folder}${temp_dir}" -type d -printf ${temp_dir}/'%P\n' 2>/dev/null|awk '{if ($0 == "")next;print "mkdir "$0}'`

#在ftp上创建本地需要上传的文件目录
check_dir=`find ${upload_dir} -type d -printf ${target_dir}/'%P\n' 2>/dev/null|awk '{if ($0 == "")next;print "mkdir "$0}'`


function ftp_upload()
{
ftp -nv ${ip} <<EOF
user ${user} ${password}
type binary
prompt
cd ${target_dir}
put "${file}" "${target_dir}/${target}"
quit
EOF
}

function ftp_check()
{
ftp -nv ${ip} <<EOF
user ${user} ${password}
type binary
prompt
${check_target}
${check_dir}
quit
EOF
}

function ftp_status_check()
{
	status=$(nmap -n -p21 ${ip} 2>/dev/null |grep -i 'ftp'|cut -d' ' -f2)
	if [ "${status}" != 'open' ];then
		#echo "`date |cut -d' ' -f2-4` ${ip} ftp service not open"
		clean_temp_file
		echo "2"
		exit 1
	fi
}

function file_md5_check()
{

	check_md5=$(md5sum $1)
	grep "${check_md5}" ${last_md5sum_file_list} >/dev/null 2>&1
	if [ $? != 0 ];then
		sed -r -i "s#.*${1}#${check_md5}#g" ${last_md5sum_file_list}
	fi
}


#检查登陆用户名或密码是否正确
login_status_log="/tmp/login_check_${cur_time}.log"
ftp_check >${login_status_log}
if cat ${login_status_log}|grep -i 'Login failed' >/dev/null 2>&1;then
	#echo "`date |cut -d' ' -f2-4` username or password incorrent..."
	clean_temp_file
	echo "3"
	exit 1
fi

#检测备份目录是否存在文件，存在则记录md5值
if [ -e ${upload_dir} ];then
	find ${upload_dir} -type f -exec md5sum {} \; >${last_md5sum_file_list}
else
	#echo "`date |cut -d' ' -f2-4` no data for backup..."
	clean_temp_file
	echo "4"
	exit 0
fi


function once_backup()
{

	if [ -e ${new_backup_file_list} ];then
		upload_list="${new_backup_file_list}"
	elif [ -e ${last_md5sum_file_list} ];then
		temp_upload_list="/tmp/temp_upload_list_${cur_time}.log"
		cat ${last_md5sum_file_list}|awk '{print $2}' > ${temp_upload_list} 2>/dev/null
		upload_list="${temp_upload_list}"
	else
		#echo "`date |cut -d' ' -f2-4` no data for backup..."
		clean_temp_file
		echo "4"
		exit 0
	fi
#统计需要上传的文件数目，用于作后续文件上传成功与否比对

	total_files=$(cat ${upload_list} 2>/dev/null|wc -l)

	cat ${upload_list} |while read file
	do
		file_md5_check ${file}
		ftp_status_check 2>/dev/null
		target=`echo ${file}|sed 's#'${upload_dir}'##'`
		ftp_upload >>${log_file} 2>/dev/null
		grep "^226 Transfer complete" ${log_file} >/dev/null 2>&1
                if [ $? != 0 ];then
                        sed -r -i "s#^local.*${file}##;/^$/d" ${log_file}
                        sed -r -i "s#.*${file}##g;/^$/d" ${last_md5sum_file_list}
			#echo "`date |cut -d' ' -f2-4` ${file} upload failed..."
                else
			#echo "`date |cut -d' ' -f2-4` ${file} upload success..."
                        sed -r -i "s/^226\ Transfer\ complete.*$//g" ${log_file}
                fi
		grep -E "^550" ${log_file} >/dev/null 2>&1
                if [ $? = 0 ];then
                        sed -r -i "s/^550\ .*$//g" ${log_file}
                fi

	done

}


once_backup

backup_success_files=$(egrep -i '^local:' ${log_file} |wc -l)
if [ "${backup_success_files}" = 0 ];then
	echo 5
	exit 1
fi

if [ "${total_files}" != "${backup_success_files}" ];then
	#echo "`date |cut -d' ' -f2-4` some files backup failed!!!"
	echo "0"
else
	#echo "`date |cut -d' ' -f2-4` backup successed!!!"
	echo "1"
fi

clean_temp_file
