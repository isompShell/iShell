#!/bin/bash
#------------------------------------------------------
#Filename:     tel_huawei.sh
#Revision:     1.1
#Date:         2015/09/24
#Author:       liuhao
#Description:  
#------------------------------------------------------
COMMAND=$1
USER=$2
IP=$3
PASSWD=$4


Extract_configuration ()
{
expect -c "
spawn telnet $IP
expect \"Username:\"  { send \"$USER\n\" }
         
expect  \"*assword:\"  { send \"$PASSWD\n\"}




expect \"*>\"  { send \"display current-configuration\n\"}

log_file $IP.test.log

while {1} {
        sleep 0.5
        expect "More" { send \ ;continue }
        sleep 0.5
        expect \"*>\" { break }
}
expect \">\"
send \"quit\n\"
expect eof
"

cat $IP.test.log |col -b |sed -r 's/^[[:space:]].*42D\#$//g'|sed -r 's/^[[:space:]].*42D//'|sed -r 's/\#//g'|sed '$d'|sed '$d'|sed '$d'|sed '$d'|sed '1d' >$IP.log
rm -rf $IP.test.log
}

Changing_configuration ()
{
CONF=$(cat $IP.log |sed 's/$/\\\\r/g'|sed '/!/'d|xargs)
#A=$(cat $IP.log)
expect -c "


spawn telnet $IP
expect  \"Username:\"  { send \"$USER\n\" }
expect  \"*assword:\"  { send \"$PASSWD\n\"}
expect  \"*>\"   { send \"system-view\n\"}
 expect \"*]\"                   
 send  \"$CONF\"                              
 send \"quit\n\"
expect \"*>\"
"
}
returns_the_result

case $COMMAND in

    extract)
            Extract_configuration
            ;;
    change)
            Changing_configuration
            ;;

esac

#END









