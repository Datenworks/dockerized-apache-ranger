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

. common.sh

# Set values for the Ranger's Security Admin
RANGER_INSTALL_PROPS="${RANGER_ADMIN_HOME}/install.properties"
## Configuration of the database (MySQL, Postgres, MS SQL Server, etc) for Ranger security admin
prop_replace "db_root_user"         	"${DATABASE_ROOT_USER}"      "${RANGER_INSTALL_PROPS}"
prop_replace "db_root_password"     	"${DATABASE_ROOT_PASSWORD}"  "${RANGER_INSTALL_PROPS}"
prop_replace "db_host"              	"${DATABASE_HOST}"           "${RANGER_INSTALL_PROPS}"
prop_replace "db_user"              	"${DATABASE_USER}"           "${RANGER_INSTALL_PROPS}"
prop_replace "db_password"          	"${DATABASE_PASSWORD}"       "${RANGER_INSTALL_PROPS}"

## Configuration of the Apache Ranger's Audit store
RANGER_ADMIN_AUDIT_STORE="${AUDIT_STORE:-solr}"

prop_replace "audit_store"          	"${RANGER_ADMIN_AUDIT_STORE}"               "${RANGER_INSTALL_PROPS}"

if test "$RANGER_ADMIN_AUDIT_STORE" = "solr"; then
    prop_replace "audit_solr_urls"      "${AUDIT_SOLR_URL}"          "${RANGER_INSTALL_PROPS}"
    prop_replace "audit_solr_user"      "${AUDIT_SOLR_USER}"         "${RANGER_INSTALL_PROPS}"
    prop_replace "audit_solr_password"  "${AUDIT_SOLR_PASSWORD}"     "${RANGER_INSTALL_PROPS}"
    # prop_replace "audit_solr_zookeepers"
else
    prop_replace "audit_db_name"        "${AUDIT_DATABASE_NAME}"     "${RANGER_INSTALL_PROPS}"
    prop_replace "audit_db_user"        "${AUDIT_DATABASE_USER}"     "${RANGER_INSTALL_PROPS}"
    prop_replace "audit_db_password"    "${AUDIT_DATABASE_PASSWORD}" "${RANGER_INSTALL_PROPS}"
fi

prop_replace "rangerAdmin_password"		"${RANGER_PASSWORD}"			"${RANGER_INSTALL_PROPS}"
prop_replace "rangerTagsync_password"	"${RANGER_TAG_SYNC}"			"${RANGER_INSTALL_PROPS}"
prop_replace "rangerUsersync_password" 	"${USER_SYNC_PASSWORD}"		"${RANGER_INSTALL_PROPS}"
prop_replace "keyadmin_password" 		"${KEY_PASSWORD}"			"${RANGER_INSTALL_PROPS}"

cd $RANGER_ADMIN_HOME
"${RANGER_ADMIN_HOME}/setup.sh" 
