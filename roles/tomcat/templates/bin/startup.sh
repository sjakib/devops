#!/usr/bin/env bash
export JAVA_HOME={{jdk_home}}
export CATALINA_HOME={{item.tomcat_home}}
export CATALINA_BASE={{item.tomcat_base}}

export JAVA_OPTS=$JAVA_OPTS" -Dcom.sun.management.jmxremote=true
-Dcom.sun.management.jmxremote.port={{item.jmx_port}}
-Dcom.sun.management.jmxremote.ssl=false
-Djava.rmi.server.hostname={{ ansible_default_ipv4.address }}
-XX:ErrorFile={{item.cores_dir}}/hs_err_pid_%p.log 
-XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath={{item.cores_dir}}"

{% if tomcat_with_jmx_secure %}
export JAVA_OPTS=$JAVA_OPTS"
-Dcom.sun.management.jmxremote.authenticate=true
-Dcom.sun.management.jmxremote.password.file={{item.tomcat_base}}/conf/jmxremote.password
-Dcom.sun.management.jmxremote.access.file={{item.tomcat_base}}/conf/jmxremote.access "
{% else %}
export JAVA_OPTS=$JAVA_OPTS" -Dcom.sun.management.jmxremote.authenticate=false "
{% endif %}

{% if with_appdynamics is defined and with_appdynamics %}
# APP DYNAMICS AGENT
export JAVA_OPTS=$JAVA_OPTS"
-javaagent:{{appdynamics_agent_install_dir}}/javaagent.jar
-Dappdynamics.agent.nodeName={{item.agent_node_name}}
-Dappdynamics.agent.applicationName={{agent_application_name}}
"
{% endif %}

{% if with_pinpoint is defined and with_pinpoint %}
# PINPOINT AGENT - requires ansible role gl.pinpoint-agent to be executed for agent installation
export JAVA_OPTS=$JAVA_OPTS" -javaagent:{{pp_agent_jar_file}} -Dpinpoint.agentId={{item.agent_node_name}} -Dpinpoint.applicationName={{agent_application_name}} "
{% endif %}

$CATALINA_HOME/bin/startup.sh
