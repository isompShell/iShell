#!/bin/bash
#--------------------------------------------------|
#Date     :2016/07/01
#Author   :Alger
#Mail     :alger_bin@foxmail.com
#Function :this script is mgrclient.sh start/stop
#Version  :1.0
#--------------------------------------------------|

PID=`ps -ef | grep mgr_client.jar|grep -v grep|awk '{print$2}'`
start() {
	# Start daemons.
	echo -n $"Starting mgr_client.jar daemons: "
	cd /usr/local/client
	java -jar mgr_client.jar &>/dev/null
	RETVAL=$?
	return $RETVAL
}
stop() {
	# Stop daemons.
	echo -n $"Shutting down mgr_client.jar daemons: "
	kill -9 $PID
	RETVAL=$?
	return $RETVAL
}
# See how we were called.
case "$1" in
  start)
	start
	;;
  stop)
	stop
	;;
  *)
	echo $"Usage: $0 {start|stop}"
	exit 1
esac
exit $RETVAL