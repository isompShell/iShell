#!/bin/bash
#----------
JAVA_HOME=/usr/local/java/jdk1.8.0_25
export  JAVA_HOME
pid_ary=(`ps -ef | grep tomcat | grep java | grep jdk | grep -v grep | mawk '{ print $2 }'`)
if [ "$pid_ary" == "" ]; then
	/usr/local/tomcat/bin/startup.sh
else
	kill -9 ${pid_ary[@]}
	sleep 2
	/usr/local/tomcat/bin/startup.sh
fi