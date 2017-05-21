#!/usr/bin/env bash
export JAVA_HOME={{jdk_home}}
export CATALINA_HOME={{item.tomcat_home}}
export CATALINA_BASE={{item.tomcat_base}}

$CATALINA_HOME/bin/shutdown.sh
