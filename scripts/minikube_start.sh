#!/bin/bash
cd $(dirname $0)

# ./stop.sh
# minikube delete

flags=" --cpus=max"

flags+=' --extra-config=kubelet.cpu-manager-policy=static'
flags+=' --extra-config=kubelet.reserved-cpus=0'

minikube start $flags

minikube addons enable metrics-server

# minikube dashboard
