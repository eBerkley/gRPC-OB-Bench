#!/bin/bash

cd $(dirname $0)/..

./scripts/stop.sh

YAMLS=release/generated/*

for f in $YAMLS
do
  if [ ! "$f" = "release/generated/loadgenerator.yaml" ]; then
    kubectl apply -f $f
  fi
done

./scripts/make_scale.sh

if [[ "$1" = "test" ]]; then
  echo waiting to port-forward frontend... ^C to cancel.
  
  sleep 12
  kubectl port-forward service/frontend-external 8080:80


  echo kubectl port-forward service/frontend-external 8080:80
else
  
  kubectl apply -f release/generated/loadgen.yaml

  # echo waiting to port-forward loadgenerator... ^C to cancel.
  # sleep 5
  # podname=$(kubectl get pod | grep 'loadgenerator-[a-z0-9]\+-[a-z0-9]\+ ' | awk '{print $1}')
  # kubectl wait --timeout=1h --for=condition=Ready pod/$podname
  echo Done!

  # echo frontend address:
  # echo http://frontend-external:80

  # kubectl port-forward deployment/loadgenerator 8089:8089


  # echo kubectl port-forward deployment/loadgenerator 8089:8089
fi