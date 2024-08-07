#!/bin/bash
cd $(dirname $0)

nodes=$1



if [ -n "$nodes" ]; then
    nodes=8
fi

# ./stop.sh
minikube delete

minikube start -n=$nodes --cpus=5 --memory=16384 --disk-size=32g

minikube addons enable metrics-server 

./start.sh

# minikube dashboard