#!/bin/bash

APP=$1
T4_HOME=$2
ACTION=$3
CLUSTER=$4
INSTANCE=$5

tomcatUser="{{tomcat_system_username}}"
if [ "$USER" != "$tomcatUser" ]; then
  echo "must be started as $tomcatUser !"
  exit 1
fi


function usage() {
	echo "usage : $0 APP CATALINA_HOME ACTION [CLUSTER INSTANCE]"
	echo " - APP                 : application name, ex: wolf"
	echo " - CATALINA_HOME       : ex: /opt/wolf/tomcat7"
	echo " - ACTION              : action on tomcat, start/stop/status"
	echo " - CLUSTER (optional)  : name of the cluster in application, if not present, action is done over all the instances found in all clusters found"
	echo " - INSTANCE (optional) : action on tomcat, start/stop/status, if not present, action is done over all the instances found in the required cluster"
}

function handleCluster() {
  CLUSTER_NAME=$1
  echo "**** ${ACTION} cluster ${CLUSTER_NAME}"
  CLUSTER_DIR=${T4_HOME}/${CLUSTER}
  cd ${CLUSTER_DIR}
  if [ "$#" -eq 2 ]; then
    INSTANCE_NAME=$2
    handleInstance ${T4_HOME} ${CLUSTER} ${INSTANCE_NAME}
  else 
    INSTANCES=($(ls -d server*))
    for INSTANCE_NAME in "${INSTANCES[@]}"
    do
      handleInstance ${T4_HOME} ${CLUSTER} ${INSTANCE_NAME}
    done
  fi
}

function tomcatStatus() {
  PID_FILE=$1
  if [ ! -f ${PID_FILE} ]; then
    echo -e "${APP}/${CLUSTER_NAME}/${INSTANCE_NAME} : stopped"
  else 
    T4_PID=`cat ${PID_FILE}`
    ps -p ${T4_PID} >/dev/null 2>&1
    if [ $? -eq 0 ] ; then
#      LISTENING_PORTS=`netstat -nlp 2>/dev/null | grep "${T4_PID}/java" | tr -s " " | tr -s ":" | cut -d":" -f2 | tr -s " " | cut -d " " -f1 | paste -sd","`
      LISTENING_PORTS=`ss -tlapn | grep LISTEN |  grep ",${T4_PID}," | tr -s " " | cut -d" " -f4 | rev | cut -d":" -f1 | rev | paste -sd","`
      echo -e "${APP}/${CLUSTER_NAME}/${INSTANCE_NAME} : running (pid=${T4_PID}|ports=${LISTENING_PORTS})"
    else
      echo -e "${APP}/${CLUSTER_NAME}/${INSTANCE_NAME} : stopped, pid ${T4_PID} not found"
    fi
  fi
}

function handleInstance() {
  TOMCAT_BIN_DIR=$1
  CLUSTER_NAME=$2
  INSTANCE_NAME=$3
  INSTANCE_DIR=${TOMCAT_BIN_DIR}/${CLUSTER_NAME}/${INSTANCE_NAME}
  if [ ! -d "${INSTANCE_DIR}" ]; then
  	echo "Unknown instance ${INSTANCE_NAME} in cluster ${CLUSTER_NAME} of application ${APP}"
  	usage
  	exit 1
  fi  
  CATALINA_HOME=${T4_HOME}
  CATALINA_BASE=${INSTANCE_DIR}
  CATALINA_PID="${CATALINA_BASE}/catalina.pid"
  export CATALINA_HOME
  export CATALINA_BASE
  export CATALINA_PID
  if [ "${ACTION}" == "start" ]; then
  echo "****************** starting instance ${INSTANCE_NAME} in cluster ${CLUSTER_NAME} of ${APP}..."
    ${CATALINA_BASE}/bin/startup.sh
    tomcatStatus ${CATALINA_PID}
  elif [ "${ACTION}" == "stop" ]; then  
  echo "****************** stopping instance ${INSTANCE_NAME} in cluster ${CLUSTER_NAME} of ${APP}..."
    ${CATALINA_BASE}/bin/shutdown.sh
    tomcatStatus ${CATALINA_PID}
  else
    tomcatStatus ${CATALINA_PID}
  fi
}

if [ "$#" -le 2 ]; then
	echo "Invalid number of parameters ($#), at least 3 are mandatory"
	usage
	exit 1
fi

if [ "${ACTION}" != "start" ] && [ "${ACTION}" != "stop" ] && [ "${ACTION}" != "status" ]; then
	echo "Unknown action ${ACTION} !!"
	usage
	exit 1
fi

if [ ! -d "${T4_HOME}" ]; then
	echo "Invalid tomcat home directory ${T4_HOME}"
	usage
	exit 1
fi


if [ "$#" -eq 3 ]; then
  # no cluster name specified as parameter (only 3 scripts arguments), going to actionate all instances in all clusters
  cd ${T4_HOME}
  CLUSTERS=($(ls -d cluster_*))
  for CLUSTER in "${CLUSTERS[@]}"
  do
    handleCluster ${CLUSTER}
  done
else
  # a cluster name is specified (at least 4 scripts arguments), trying to use it
  CLUSTER_DIR=${T4_HOME}/${CLUSTER}
  if [ ! -d "${CLUSTER_DIR}" ]; then
	  echo "Unknown cluster ${CLUSTER} in application ${APP}"
	  usage
	  exit 1
  fi  
  
  if [ "$#" -eq 5 ]; then
    # an instance name is specified, trying to use it
    INSTANCE_DIR=${T4_HOME}/${CLUSTER_NAME}/${INSTANCE_NAME}
    if [ ! -d "${INSTANCE_DIR}" ]; then
    	echo "Unknown instance ${INSTANCE_NAME} in cluster ${CLUSTER_NAME} of application ${APP}"
    	usage
    	exit 1
    fi
    handleInstance ${T4_HOME} ${CLUSTER} ${INSTANCE}
  else
    # no server instance name specified as parameter
    handleCluster ${CLUSTER}
  fi
fi




