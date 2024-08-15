#!/bin/bash

LOCUST=locust



allowed () {
  cat /proc/$1/status | grep Cpus_allowed_list | awk '{print $2}'
}

echo

loads=($(mpstat -P ALL 1 1 | awk '/Average:/ && $2 ~ /[0-9]/ {print $12}'))

for PROC in "/src/checkoutservice" "/app/cartservice" "node server.js" "/app/build/install/hipstershop" "python email_server.py" "node index.js" "/src/frontend" "/src/catalog" "redis-server" "/src/shippingservice" "python recommendation_server.py"; do

  for PROC_ID in $(ps -ef | grep "$PROC" | grep -v grep | awk '{print $2}'); do
    core=$(allowed $PROC_ID)
    echo $PROC: Core $core, usage: $(echo 100.00 - ${loads[$core]} | bc )%
  done
done

echo 

for PROC_ID in $(ps -ef | grep $LOCUST | grep -v grep | awk '{print $2}'); do
  PARENT_ID=$(ps -o ppid= $PROC_ID)
  core=$(allowed $PROC_ID)
  echo $(cat /proc/${PROC_ID}/cmdline | xargs -0 echo | awk '{print $2 $3}'): Core $core, usage: $(echo 100.00 - ${loads[$core]} | bc )%
done
