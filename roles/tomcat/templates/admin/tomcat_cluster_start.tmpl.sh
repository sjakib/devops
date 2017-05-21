for INST in `ls /etc/init.d/tomcat-{{env_app}}-{{project_cluster_name}}-server*`
do
  ${INST} start
done
