#!/bin/bash
#
# tomcat-{{env_app_name}}-cluster_{{project_cluster_name}}-server{{item.srv_num}}
#
# chkconfig: 345 96 30
# description:  Start up the Tomcat servlet engine.
#
# processname: tomcat-{{env_app_name}}-cluster_{{project_cluster_name}}-server{{item.srv_num}}
# pidfile: {{item.tomcat_base}}/catalina.pid
#
### BEGIN INIT INFO
# Provides: tomcat {{env_app_name}} cluster_{{project_cluster_name}} server{{item.srv_num}}
# Required-Start: $network $syslog
# Required-Stop: $network $syslog
# Should-Start: distcache
# Short-Description: start and stop Apache Tomcat Server
# Description: implementation for Servlet 2.5 and JSP 2.1
## END INIT INFO

# Source function library.
. /etc/init.d/functions

## tomcat installation directory
PROCESS_NAME="{{env_app_name}}-cluster_{{project_cluster_name}}-server{{item.srv_num}}"

CATALINA_BASE="{{item.tomcat_base}}"

## run as a diffent user
TOMCAT_USER={{tomcat_system_username}}

##  Path to the pid, runnning info file
pidfile={{item.tomcat_base}}/catalina.pid;
lockfile=/var/lock/subsys/{{env_app_name}}-cluster_{{project_cluster_name}}-server{{item.srv_num}};

RETVAL=0

case "$1" in
 start)
    PID=`pidofproc -p ${pidfile} ${PROCESS_NAME}`
    if [[ (-n ${PID}) && ($PID -gt 0) ]]; then
            logger -s "${PROCESS_NAME}(pid ${PID}) is  already running."
            exit;
    fi
    if [ -f $CATALINA_BASE/bin/startup.sh ];
      then
        logger -s "Starting ${PROCESS_NAME}"
        /bin/su -l ${TOMCAT_USER} -c "$CATALINA_BASE/bin/startup.sh -Dprocessname=${PROCESS_NAME}"
        PID=`ps -auxww|grep "catalina.base=${CATALINA_BASE}"|grep -v grep|awk '{print $2}'`
        echo "launched tomcat on PID=${PID}"
        RETVAL=$?
        [ $RETVAL = 0 ] && touch ${lockfile}
        [ $RETVAL = 0 ] && echo "${PID}" > ${pidfile}
    fi
    ;;
 profiling)
    PID=`pidofproc -p ${pidfile} ${PROCESS_NAME}`
    if [[ (-n ${PID}) && ($PID -gt 0) ]]; then
            logger -s "${PROCESS_NAME}(pid ${PID}) is  already running."
            exit;
    fi
    if [ -f $CATALINA_BASE/bin/startup.sh ];
      then
        logger -s "Starting ${PROCESS_NAME}"
        /bin/su -l ${TOMCAT_USER} -c "PROFILING_MODE=1 $CATALINA_BASE/bin/startup.sh -Dprocessname=${PROCESS_NAME}"
        PID=`ps -auxww|grep "catalina.base=${CATALINA_BASE}"|grep -v grep|awk '{print $2}'`
        echo "launched tomcat on PID=${PID}"
        RETVAL=$?
        [ $RETVAL = 0 ] && touch ${lockfile}
        [ $RETVAL = 0 ] && echo "${PID}" > ${pidfile}
    fi
    ;;
 stop)
    PID=`pidofproc -p ${pidfile} ${PROCESS_NAME}`
    ## if PID valid run shutdown.sh
    if [[ -z ${PID} ]];then
        logger -s "${PROCESS_NAME} is not running."
        exit;
    fi

    if [[ (${PID} -gt 0) && (-f $CATALINA_BASE/bin/shutdown.sh) ]];
      then
        logger -s "Stopping ${PROCESS_NAME}"
        /bin/su -l ${TOMCAT_USER} -c "$CATALINA_BASE/bin/shutdown.sh"
        RETVAL=$?
        [ $RETVAL = 0 ] && rm -f ${lockfile}
        [ $RETVAL = 0 ] && rm -f ${pidfile}
    fi
    ;;
 status)
    status -p ${pidfile} ${PROCESS_NAME}
    RETVAL=$?
    ;;
 restart)
     $0 stop
     $0 start
     ;;
 version)
    if [ -f $CATALINA_BASE/bin/version.sh ];
      then
        logger -s "Display ${PROCESS_NAME} Version"
        /bin/su -l ${TOMCAT_USER} -c "$CATALINA_BASE/bin/version.sh"
        RETVAL=$?
    fi
    ;;
 *)
    echo $"Usage: $0 {start|stop|restart|profiling|status|version}"
    exit 1
    ;;
esac
exit $RETVAL        