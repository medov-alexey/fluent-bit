#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

#------------------------

if [ "$1" == "delete" ] || [ "$1" == "drop" ] || [ "$1" == "uninstall" ] || [ "$1" == "remove" ]; then
   docker rm -f fluent-bit mongo elasticsearch graylog testnginxlog > /dev/null 2>&1
   rm -rf mkdir /tmp/var/log/nginx > /dev/null 2>&1
   docker network rm demonstration
   echo ""
   echo "Containers for demonstrations was removed"
   echo ""
   exit 0
fi

docker network create demonstration > /dev/null 2>&1

mkdir -p /tmp/var/log/nginx > /dev/null 2>&1

chmod -R 777 /tmp/var/log/nginx > /dev/null 2>&1

docker run -d --name testnginxlog -v /tmp/var/log/nginx:/var/log/nginx nginx:latest

#------------------------

./fluent-bit_version_1.8.9.sh

#------------------------

docker run --name mongo --network=demonstration -d mongo:4.2

sleep 10

docker run --name elasticsearch --network=demonstration \
    -e "http.host=0.0.0.0" \
    -e "discovery.type=single-node" \
    -e "ES_JAVA_OPTS=-Xms512m -Xmx512m" \
    -d docker.elastic.co/elasticsearch/elasticsearch-oss:7.10.2

sleep 10

docker run --name graylog --link mongo --link elasticsearch --link fluent-bit --network=demonstration\
    -p 9000:9000 -p 12201:12201 -p 1514:1514 \
    -e GRAYLOG_HTTP_EXTERNAL_URI="http://127.0.0.1:9000/" \
    -e GRAYLOG_CONTENT_PACKS_AUTO_INSTALL="gelf-tcp-input-12201.json" \
    -e GRAYLOG_CONTENT_PACKS_LOADER_ENABLED="true" \
    -e GRAYLOG_CONTENT_PACKS_DIR="/usr/share/graylog/data/contentpacks" \
    -v $(pwd)/configs/gelf-tcp-input-12201.json:/usr/share/graylog/data/contentpacks/gelf-tcp-input-12201.json \
    -d graylog/graylog:4.0

sleep 60
echo ""

docker ps -a --format "table {{.Names}} \t {{.Status}} \t {{.Ports}}" | grep "fluent-bit\|mongo\|elasticsearch\|graylog\|testnginxlog"

echo ""
echo "Please visit http://127.0.0.1:9000 for open Graylog Web Interface in your Browser"
echo "login: admin"
echo "pass: admin"
echo ""

for (( i=1; i <= 10; i++ ))
do
docker exec -it testnginxlog curl localhost:80 2>/dev/null > /dev/null;
sleep 1
done

echo "Done."
