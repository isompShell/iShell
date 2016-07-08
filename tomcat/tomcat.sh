#!/bin/bash
#--------------
#--------------
JAVA_HOME=/usr/local/java/jdk1.8.0_25
export  JAVA_HOME

start() {
	/usr/local/tomcat/bin/startup.sh
	RETVAL=$?
	return $RETVAL
}

stop() {
	pid_ary=(`ps -ef | grep tomcat | grep java | grep jdk | grep -v grep | mawk '{ print $2 }'`)
	kill -9 ${pid_ary[@]}
	RETVAL=$?
	return $RETVAL
}

restart() {
	pid_ary=(`ps -ef | grep tomcat | grep java | grep jdk | grep -v grep | mawk '{ print $2 }'`)
	kill -9 ${pid_ary[@]}
	sleep 2
	/usr/local/tomcat/bin/startup.sh
	RETVAL=$?
	return $RETVAL
}

case "$1" in
 start)
	start
	;;
 stop)
	stop
	;;
 restart)
	restart
	;;
 *)
	echo $"Usage: $0 {start|stop|restart|condrestart|status}"
	exit 1
esac

exit $RETVAL