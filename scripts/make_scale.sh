#!/bin/bash

hpa_flags=' --min=1 --max=20 --cpu-percent=65'

kubectl autoscale deployment adservice $hpa_flags
kubectl autoscale deployment cartservice $hpa_flags
kubectl autoscale deployment checkoutservice $hpa_flags
kubectl autoscale deployment currencyservice $hpa_flags
kubectl autoscale deployment emailservice $hpa_flags
kubectl autoscale deployment frontend $hpa_flags
kubectl autoscale deployment paymentservice $hpa_flags
kubectl autoscale deployment productcatalogservice $hpa_flags
kubectl autoscale deployment recommendationservice $hpa_flags
kubectl autoscale deployment shippingservice $hpa_flags

