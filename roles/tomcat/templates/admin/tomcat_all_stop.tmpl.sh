for INST in `ls /etc/init.d/tomcat-*`
do
  ${INST} stop
done