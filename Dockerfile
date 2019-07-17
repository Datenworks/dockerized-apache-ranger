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

FROM openjdk:8u212-b04-jdk-stretch

RUN apt-get update && \
    apt-get install bsdtar gcc git -yq && \
    wget -qO- "http://mirror.nbtelecom.com.br/apache/maven/maven-3/3.6.1/binaries/apache-maven-3.6.1-bin.tar.gz" \
        | bsdtar -xf- -C /usr/local/lib && \
    ln -s /usr/local/lib/apache-maven-3.6.1/bin/mvn /usr/local/bin/mvn && \
    wget -qO- "https://github.com/apache/ranger/archive/release-ranger-1.2.0.tar.gz" \
        | bsdtar -xf- -C /usr/local/lib && \
    cd /usr/local/lib/ranger-release-ranger-1.2.0 && \
    mvn clean compile package assembly:assembly install

RUN bsdtar -xf /usr/local/lib/ranger-release-ranger-1.2.0/target/ranger-1.2.0-admin.tar.gz \
        -C /usr/local/lib/ && \
    ln -s /usr/local/lib/ranger-1.2.0-admin /usr/local/lib/apache-ranger && \
    apt-get install bc -yq && \
    [ ! -d "/usr/share/java" ] && mkdir -p "/usr/share/java" && \
    wget -qO- https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-8.0.16.tar.gz \
        | bsdtar -xf- -C "/usr/share/java/" && \
    ln -s "/usr/share/java/mysql-connector-java-8.0.16/mysql-connector-java-8.0.16.jar" \
        "/usr/share/java/mysql-connector-java.jar"

COPY *.sh /usr/local/bin/

ENV RANGER_ADMIN_HOME=/usr/local/lib/apache-ranger \
    JAVA_HEAP_SIZE="-Xmx512m -Xms512m" \
    DATABASE_ROOT_USER=root \
    DATABASE_ROOT_PASSWORD=root \
    DATABASE_HOST=localhost \
    DATABASE_USER=ranger \
    DATABASE_PASSWORD=ranger \
    AUDIT_DATABASE_NAME=ranger_audits \
    AUDIT_DATABASE_USER=ranger \
    AUDIT_DATABASE_PASSWORD=ranger \
    AUDIT_SOLR_URL=http://${SOLR_HOST:-localhost}:${SOLR_PORT:-6083}/solr/ranger_audits \
    AUDIT_SOLR_USER=ranger \
    AUDIT_SOLR_PASSWORD=ranger \
    RANGER_PASSWORD=topsecret1 \
    RANGER_TAG_SYNC=ranger2tagsync \
    USER_SYNC_PASSWORD=ranger3usersyncpassword \
    KEY_PASSWORD=another4topsecret

# Ref: https://docs.hortonworks.com/HDPDocuments/HDP2/HDP-2.6.4/bk_reference/content/ranger-ports.html
EXPOSE 6080 6182

ENTRYPOINT [ "sh", "/usr/local/bin/docker-entrypoint.sh" ]
