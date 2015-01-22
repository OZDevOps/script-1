#!/usr/bin/env bash

# pre-request
# 1. script tested on Ubuntu
# 2. passwordless ssh has been set to all input ipaddress
# 3. nc command is available.

USAGE="Usage: $0 ip port1 port2 ... portN"

if [ "$#" -lt "2" ]; then
	echo "$USAGE"
	exit 1
fi

ipaddress=$1
shift

while (( "$#" )); do

  port=$1

  if [ "$ipaddress" == "127.0.0.1" ]; then
      SUDO="sudo"
  else
      SUDO="ssh $ipaddress sudo"
  fi

  nc "$ipaddress" "$port" < /dev/null
  status="$?"

  if [ "$status" == "0" ]; then
     echo "port $port is runnnig well on $ipaddress"
  else
      case $port in
          "80" | "443" ) echo "webservice is down, restarting ...."
                         $SUDO service apache2 restart
                         ;;
          "22" ) echo "ssh service is down, restart ..."
                 if [ "$port" == "127.0.0.1" ]; then
                      sudo service ssh restart
                 else
                     echo "Can't help to start ssh instance on remote client $ipaddress"
                 fi
                 ;;
           * )   echo "not sure which service running on port $port"
                 ;;
     esac
  fi

  shift

done |tee output.txt
