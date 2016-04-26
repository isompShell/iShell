#!/bin/bash
YEAR=`date +%y`
MONTH=`date +%m`
Y_MONTH=`date -d"1 month ago" +%m`
DATE=`date +%d`
Y_DATE=`date -d"1 day ago" +%d`
Y_YEAR=`date -d"1 year ago" +%y`
R_DIR=/var/log/simp_fort/session
SERVER_IP=$1

if [ -d "${R_DIR}"/"${YEAR}"/"${MONTH}"/"${Y_DATE}"/ ]
then


rsync -av --include="*/" --exclude="*" "${R_DIR}"/ root@"${SERVER_IP}":"${R_DIR}"/ 


rsync -azv --exclude ""${DATE}"" "${R_DIR}"/"${YEAR}"/"${MONTH}"/"${Y_DATE}" --progress root@"${SERVER_IP}":"${R_DIR}"/"${YEAR}"/"${MONTH}"/

rsync -av   root@"${SERVER_IP}":"${R_DIR}"/ "${R_DIR}"/

elif [ -d "${R_DIR}"/"${YEAR}"/"${Y_MONTH}"/"${Y_DATE}"/  ]
then


rsync -av --include="*/" --exclude="*" "${R_DIR}"/ root@"${SERVER_IP}":"${R_DIR}"/ 

rsync -azv --exclude ""${MONTH}/${DATE}"" "${R_DIR}"/"${YEAR}"/"${Y_MONTH}"/"${Y_DATE}"   --progress root@"${SERVER_IP}":"${R_DIR}"/"${YEAR}"/"${Y_MONTH}"/ 

rsync -av   root@"${SERVER_IP}":"${R_DIR}"/ "${R_DIR}"/

elif [ -d "${R_DIR}"/"${Y_YEAR}"/"${Y_MONTH}"/"${Y_DATE}"/ ]
then


rsync -av --include="*/" --exclude="*" "${R_DIR}"/ root@"${SERVER_IP}":"${R_DIR}"/ 


rsync -azv --exclude ""${YEAR}/${MONTH}/${DATE}"" "${R_DIR}"/"${Y_YEAR}"/"${Y_MONTH}"/"${Y_DATE}" --progress root@"${SERVER_IP}":"${R_DIR}"/"${Y_YEAR}"/"${Y_MONTH}"  

rsync -av   root@"${SERVER_IP}":"${R_DIR}"/ "${R_DIR}"/
else
    echo "2,,Directory does not exist,or no file";exit 2
fi
