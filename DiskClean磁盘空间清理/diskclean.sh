#!/bin/bash


#需要保存的月份数，默认保存3个月，如需半年，只需将SAVE_MONTHS这个变量改成对应月份的值即可
SAVE_MONTHS=3

if ! grep -i 'diskclean.sh' /etc/crontab;then
	echo -e "* *\t*/1 * *\troot\tbash /usr/local/bin/cron.d/diskclean.sh" >>/etc/crontab
fi
if [ ! -e '/usr/local/bin/cron.d/diskclean.sh' ];then
	[ -e /usr/local/bin/cron.d/diskclean.sh ]||mkdir -p /usr/local/bin/cron.d
	\cp -rf $0 /usr/local/bin/cron.d/diskclean.sh
	chmod a+x /usr/local/bin/cron.d/diskclean.sh
	[ -e /usr/local/bin/cron.d/diskclean.sh ]&&\rm -rf $0
	echo 'ok'
	exit 0
fi

LOG_PATH='/var/log/simp_fort/session'

for i in $(find ${LOG_PATH} -type d 2>/dev/null)
do
	day=$(echo $i|cut -d'/' -f-7)
	year=$(echo $i|cut -d'/' -f-6)
	DIR=$(echo $i|cut -d'/' -f7)
	del='yes'
	for days in $(seq 0 $(expr ${SAVE_MONTHS} - 1))
	do
		mm="$LOG_PATH/$(date -d"${days} month ago" +"%Y/%m")"
		if [ "$day" = "$mm" ];then
			del='no'
			break
		fi
	done
	if [ "$del" = 'yes' -a "$day" != "${LOG_PATH}" -a "${DIR}" != "" ];then
		echo "del $day"
		\rm -rf $day
	else
		echo "save $day"
	fi
done
