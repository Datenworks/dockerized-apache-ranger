#!/bin/sh -e
# Copyright 2019 Datenworks
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e # Stop on any error

# Execute the setup through init-setup.sh, responsible for 
#   setting the install.properties values
init-setup.sh

XAPOLICYMGR_EWS_DIR=`find $RANGER_ADMIN_HOME/ -name ews`
XAPOLICYMGR_EWS_CONF_DIR="${XAPOLICYMGR_EWS_DIR}/webapp/WEB-INF/classes/conf"
RANGER_JAAS_LIB_DIR="${XAPOLICYMGR_EWS_DIR}/ranger_jaas"
RANGER_JAAS_CONF_DIR="${XAPOLICYMGR_EWS_CONF_DIR}/ranger_jaas"

echo "${JAVA_OPTS}" | grep "\-Duser.timezone" || \
	export JAVA_OPTS="${JAVA_OPTS} -Duser.timezone=UTC"

[ -e ${XAPOLICYMGR_EWS_CONF_DIR}/java_home.sh ] && \
	. ${XAPOLICYMGR_EWS_CONF_DIR}/java_home.sh

for custom_env_script in `find ${XAPOLICYMGR_EWS_CONF_DIR}/ -name "ranger-admin-env*"`; do
	[ -e $custom_env_script ] && . $custom_env_script
done

COMPLETE_CLASSPATH=${XAPOLICYMGR_EWS_CONF_DIR}:${XAPOLICYMGR_EWS_DIR}/lib/*:${RANGER_JAAS_LIB_DIR}/*:${RANGER_JAAS_CONF_DIR}:${JAVA_HOME}/lib/*:${RANGER_HADOOP_CONF_DIR}/*:$CLASSPATH

java -Dproc_rangeradmin ${JAVA_OPTS} ${JAVA_HEAP_SIZE} \
    -Duser=${USER} \
    -Dhostname=${HOSTNAME} ${DB_SSL_PARAM} \
    -Dservername=${SERVER_NAME} \
    -Dlogdir=${RANGER_ADMIN_LOG_DIR} \
    -Dcatalina.base=${XAPOLICYMGR_EWS_DIR} \
    -cp ${COMPLETE_CLASSPATH} \
    org.apache.ranger.server.tomcat.EmbeddedServer
