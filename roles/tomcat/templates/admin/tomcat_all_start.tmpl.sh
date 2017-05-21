for INST in `ls /etc/init.d/tomcat-*`
do
  ${INST} start
done