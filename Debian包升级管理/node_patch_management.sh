#!/bin/bash
#------------------------------------------------
#Filename:	config_deb_package.sh
#Revision:	1.0
#Date:		2015/10/23
#Author:	zengchunyun
#Description:	config and management deb package
#------------------------------------------------
#Version 1.0
#The first one,config and management deb package


PATCH_ACTION="${1}"
PATCH_FILE="${2}"

PATCH_DIR='/usr/local/fort_nonsyn/config/concentrationManagement/patch'
PACKAGE=`dpkg -I "${PATCH_DIR}/${PATCH_FILE}" 2>/dev/null|sed 's/^[[:space:]]*//g;s/[[:space:]]*$//g'|grep -i '^package'|awk -F':' '{print $2}'`
PATCH_VERSION=`dpkg -I "${PATCH_DIR}/${PATCH_FILE}" 2>/dev/null|sed 's/^[[:space:]]*//g;s/[[:space:]]*$//g'|grep -i '^version'|awk -F':' '{print $2}'`

CONF_DIR='/etc/fort/'
CONF_FILE="${CONF_DIR}fort.ini"

BACKUP_DIR='/var/lib/fort'
INFO_DIR='/tmp/shell/file'

#查找描述文件位置
DETAIL_DIR="${BACKUP_DIR}/${PACKAGE}/${PACKAGE}_${PATCH_VERSION}${INFO_DIR}"
if [ -e "${DETAIL_DIR}" ];then
	for file in `find ${DETAIL_DIR} -type f`
	do
		grep -i 'description' ${file} >/dev/null 2>&1
		if [ $? = 0 ];then
			DETAIL_FILE="${file}"
			break
		fi
	done
fi

#检测传进来的软件包是否是标准的DEBIAN软件包格式
dpkg -I "${PATCH_DIR}/${PATCH_FILE}" >/dev/null 2>&1
if [ $? -ne 0 -a "${PATCH_ACTION}" != "uninstallall" -a "${PATCH_ACTION}" != "remove" ];then
	echo 'deberr'
	exit 1
fi


#setup deb package information
function setDebInfo()
{
	case $1 in
		detail)
			dpkg -s ${PACKAGE} 2>/dev/null |grep -i '^version' >/dev/null 2>&1
			if [ $? = 0 ];then
				CUR_VERSION=`dpkg -s ${PACKAGE} 2>/dev/null|grep -i '^versio'|awk -F':' '{print $2}'|sed 's/^[[:space:]]*//g;s/[[:space:]]*$//g'`
				PRE_CUR=`echo ${CUR_VERSION}|cut -d'.' -f1`
				MID_CUR=`echo ${CUR_VERSION}|cut -d'.' -f2`
				POST_CUR=`echo ${CUR_VERSION}|cut -d'.' -f3`
				PRE_PATCH=`echo ${PATCH_VERSION}|cut -d'.' -f1`
				MID_PATCH=`echo ${PATCH_VERSION}|cut -d'.' -f2`
				POST_PATCH=`echo ${PATCH_VERSION}|cut -d'.' -f3`
				
				if [ "${PRE_PATCH}" -lt "${PRE_CUR}" ];then
					STATUS='true'
				elif [ "${PRE_PATCH}" -eq "${PRE_CUR}" ];then
					if [ "${MID_PATCH}" -lt "${MID_CUR}" ];then
						STATUS='true'
					elif [ "${MID_PATCH}" -eq "${MID_CUR}" ];then
						if [ "${POST_PATCH}" -le "${POST_CUR}" ];then
							STATUS='true'
						else
							STATUS='false'
						fi
					else
						STATUS='false'
					fi
				else
					STATUS='false'
				fi
					
			else
				STATUS='false'
			fi
			if [ "${STATUS}" = 'false' ];then
				INFO_TMP='/tmp/info.tmp'
				dpkg -I "${PATCH_DIR}/${PATCH_FILE}" >${INFO_TMP} 2>/dev/null
				if [ $? = 0 ];then
					grep -A10 -i 'Description:' ${INFO_TMP} >/dev/null 2>&1
					if [ $? = 0 ];then
        					COUNT=`grep -A10 -i 'Description:' ${INFO_TMP}|wc -l`
        					INIT=0
        					grep -A10 -i 'Description' ${INFO_TMP}|while read LINE
        					do
                					if [ "${INIT}" -ne 0 ];then
                        					echo ${LINE}|grep ':' >/dev/null 2>&1
                        					if [ $? = 1 ];then
									NEWLINE=${LINE}
                                					RESULT=${RESULT}${NEWLINE}
                                					RESULT=${RESULT}
                        					fi
							fi
                					if [ "${INIT}" = 0 ];then
                        					read PRE POST < <(echo $LINE|awk -F':' '{print $1,$2}')
                					fi
                					let INIT++
                					if [ "${INIT}" -eq "${COUNT}" ];then
                        					echo "{\"${PRE}\":\"${POST} ${RESULT}\"}"
                        					break
                					fi
        					done
						rm -rf ${INFO_TMP}
					fi
				else
					echo "failed"
				fi
			else
				cat ${DETAIL_FILE}|egrep -v -i '(^del|^add|^replace)'|while read LINE
					do
						echo "${LINE}" |grep ':' >/dev/null 2>&1
						if [ $? = 0 ];then
							PRE=`echo ${LINE}|cut -d':' -f1`
							POST=`echo ${LINE}|cut -d':' -f2-`
							TMP="\"${PRE}\""":""\"${POST}\""","
						else
							RESULT=`echo ${RESULT}|sed 's/\"\,$//'`
							TMP="${LINE}\""","
							
						fi
							RESULT=${RESULT}${TMP}
							RESULT=${RESULT}
							LAST=`sed -n '$p' ${DETAIL_FILE}|sed 's/[[:space:]]*$//g'`
						if [ "${LINE}" = "${LAST}" ];then
							RESULT=`echo ${RESULT}|sed 's/\,$//'`
							echo "{"$RESULT"}"
						fi
					done
			fi
		;;
		install)
			INSTALL_STATUS=`dpkg -i "${PATCH_DIR}/${PATCH_FILE}" 2>/dev/null`
			if [ $? -ne 0 ];then
				echo failed
				exit 1
			fi
			if [ "${INSTALL_STATUS}" = "" ];then
				echo "failed"
			else
				echo "successed"
				TIME=`date +'%Y-%m-%d %H:%M:%S'`
				[ -e "${CONF_DIR}" ]||mkdir -p ${CONF_DIR}
				echo ${TIME}>${CONF_FILE}
			fi
		;;
		uninstall)
			VERSION=`dpkg -s ${PACKAGE} 2>/dev/null|grep -i '^version'|awk -F':' '{print $2}'|sed 's/^[[:space:]]*//g;s/[[:space:]]*$//g'`
			if [ "${PATCH_VERSION}" = "${VERSION}" ];then
				UNINSTALL_STATUS=`dpkg --purge ${PACKAGE} 2>/dev/null`
				if [ "${UNINSTALL_STATUS}" = "" ];then
					echo "failed"
				else
					echo "successed"
				fi
			else
				echo "uninstallerr"
			fi
		;;
		uninstallall)
			for PATCH_FILE in `find ${PATCH_DIR} -type f`
			do
				dpkg -I ${PATCH_FILE} >/dev/null 2>/dev/null
				if [ $? = 0 ];then
					PACKAGE=`dpkg -I "${PATCH_FILE}" 2>/dev/null |sed 's/^[[:space:]]*//g;s/[[:space:]]*$//g' |grep -i '^package' |awk -F':' '{print $2}'`
					STATUS=`dpkg -s ${PACKAGE} 2>/dev/null`
					while [ "${STATUS}" != "" ]
					do
						STATUS="`dpkg -s ${PACKAGE} 2>/dev/null`"
						dpkg --purge ${PACKAGE} >/dev/null 2>&1
						if [ $? -ne 0 ];then
							echo 'failed'
							break
						fi
						sleep 2
						if [ "${STATUS}" = "" ];then
							break
						fi
					done
				fi
			done
			if [ "${STATUS}" = "" ];then
				rm -rf ${PATCH_DIR}/*
				echo "successed"
			else
				echo "failed"
			fi
		;;
		remove)
			rm -rf "${PATCH_DIR}/${PATCH_FILE}"
			if [ -e "${PATCH_DIR}/${PATCH_FILE}" ];then
				echo "failed"
			else
				echo "successed"
			fi
		;;
		status)
			STATUS=`dpkg -s ${PACKAGE} 2>/dev/null`
			if [ "${STATUS}" = "" ];then
				echo "failed"
			else
				echo "successed"
			fi
		;;
		install_info)
			PA="`cat ${DETAIL_FILE}|egrep -wi 'PA[[:space:]].*version' |cut -d':' -f2`"
			WS="`cat ${DETAIL_FILE}|egrep -wi 'WS[[:space:]].*version' |cut -d':' -f2`"
			INFO=`cat ${CONF_FILE} 2>/dev/null`
			if [ "${INFO}" = "" ];then
				echo "failed"
			else
				echo "${INFO},${PA},${WS}"
			fi
		;;
		*)
			echo 'action error'
		;;
	esac
}

setDebInfo ${PATCH_ACTION} ${PATCH_FILE}
