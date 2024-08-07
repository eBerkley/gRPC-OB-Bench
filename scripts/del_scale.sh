#!/bin/bash

cd $(dirname $0)

kubectl delete hpa frontend
kubectl delete hpa adservice
kubectl delete hpa cartservice 
kubectl delete hpa checkoutservice
kubectl delete hpa currencyservice
kubectl delete hpa emailservice
kubectl delete hpa paymentservice 
kubectl delete hpa productcatalogservice 
kubectl delete hpa recommendationservice 
kubectl delete hpa shippingservice 

