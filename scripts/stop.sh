#!/bin/bash

cd $(dirname $0)/..

# kubectl delete -f release/gen.yaml
# skaffold delete

YAMLS=release/generated/*

for f in $YAMLS
do
  kubectl delete -f $f
done

# kubectl delete -f release/my_kube.yaml
./scripts/del_scale.sh
