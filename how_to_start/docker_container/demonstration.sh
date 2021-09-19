#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

#------------------------

if [ "$1" == "delete" ] || [ "$1" == "drop" ] || [ "$1" == "uninstall" ] || [ "$1" == "remove" ]; then
   docker rm -f fluent-bit mongo elasticsearch graylog > /dev/null 2>&1
   echo ""
   echo "Containers for demonstrations was removed"
   echo ""
   exit 0
fi

#------------------------

./fluent-bit_version_1.8.sh

#------------------------

docker run --name mongo -d mongo:4.2

sleep 10

docker run --name elasticsearch \
    -e "http.host=0.0.0.0" \
    -e "discovery.type=single-node" \
    -e "ES_JAVA_OPTS=-Xms512m -Xmx512m" \
    -d docker.elastic.co/elasticsearch/elasticsearch-oss:7.10.2

sleep 10

docker run --name graylog --link mongo --link elasticsearch \
    -p 9000:9000 -p 12201:12201 -p 1514:1514 \
    -e GRAYLOG_HTTP_EXTERNAL_URI="http://127.0.0.1:9000/" \
    -d graylog/graylog:4.0

sleep 15

docker ps -a --format "table {{.Names}} \t {{.Status}} \t {{.Ports}}" | grep "fluent-bit\|mongo\|elasticsearch\|graylog"
