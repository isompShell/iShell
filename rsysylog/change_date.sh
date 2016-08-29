#!/bin/bash
today=`date +%Y_%m_%d`
#syslog cut
 declare logs_path="/var/log/isomp_syslog";
 #declare need_delete_path=${logs_path}/$(date -d "7 days ago" "+%Y_%m_%d");
# declare yestoday_log_path=${logs_path}/$(date -d "yesterday" "+%Y_%m_%d");
 #rm -rf ${need_delete_path}
 #rm -rf ${yestoday_log_path}
# mv ${logs_path}/$today ${yestoday_log_path}
mkdir -p ${logs_path}/$today
