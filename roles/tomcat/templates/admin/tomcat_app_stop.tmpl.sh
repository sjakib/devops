for INST in `ls /etc/init.d/tomcat-{{env_app}}-*`
do
  ${INST} stop
done
