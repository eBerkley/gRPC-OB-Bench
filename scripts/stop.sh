#!/bin/bash

cd $(dirname $0)/..

YAMLS=release/generated/*

for f in $YAMLS
do
  kubectl delete -f $f
done

./scripts/del_scale.sh
