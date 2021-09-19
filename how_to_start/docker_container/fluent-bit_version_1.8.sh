#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

#------------------------

app=fluent-bit
version=1.8
silent=""

#------------------------

if [ "$1" == "delete" ] || [ "$1" == "drop" ] || [ "$1" == "uninstall" ] || [ "$1" == "remove" ]; then
   docker rm -f $app > /dev/null 2>&1
   docker rmi fluent/fluent-bit:$version > /dev/null 2>&1
   echo ""
   echo "Fluent-bit was removed"
   echo ""
   exit 0
fi

#------------------------

docker run -d --restart always --name $app -v $(pwd)/config.conf:/fluent-bit/etc/fluent-bit.conf -p 24224:24224 -p 5170:5170 -p 8888:8888 fluent/$app:$version || exit 1

#------------------------

sleep 5

docker ps -a | grep $app

if [ "$(docker ps -a | grep $app | grep xit > /dev/null 2>&1; echo $?)" -eq "0" ]; then docker logs -n 30 $app; docker rm -f $app; exit 1; fi

docker logs $app

echo ""
echo "=================================="
echo "Fluent-bit started successfully =)"
echo "=================================="
echo ""

docker cp /bin/cat $app:/bin/cat > /dev/null 2>&1
docker cp /bin/ls $app:/bin/ls > /dev/null 2>&1
docker cp /bin/echo $app:/bin/echo > /dev/null 2>&1
docker cp /bin/pwd $app:/bin/pwd > /dev/null 2>&1

echo "With this configuration file: /fluent-bit/etc/fluent-bit.conf"
echo ""
docker exec -it $app cat /fluent-bit/etc/fluent-bit.conf
echo ""
