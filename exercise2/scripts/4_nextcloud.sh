#!/bin/bash

# Release name
NAME=my-nextcloud
NAMESPACE=nextcloud

# Create a namespace for Nextcloud
kubectl create namespace $NAMESPACE
kubectl create namespace ingress-nginx

# Apply persistent volumes
kubectl apply -f nextcloud/volumes/local-path.yaml
kubectl apply -f nextcloud/volumes/nextcloud-pv.yaml -n $NAMESPACE
kubectl apply -f nextcloud/volumes/nextcloud-pvc.yaml -n $NAMESPACE
kubectl apply -f nextcloud/volumes/postgresql-pv.yaml -n $NAMESPACE
kubectl apply -f nextcloud/volumes/postgresql-pvc.yaml -n $NAMESPACE

# Apply the secrets
kubectl apply -f nextcloud/secrets/nextcloud-secret.yaml -n $NAMESPACE
kubectl apply -f nextcloud/secrets/postgresql-secret.yaml -n $NAMESPACE
kubectl apply -f nextcloud/secrets/redis-secret.yaml -n $NAMESPACE

# Download the Ingress Nginx Helm chart and install it
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx -f nextcloud/ingress/values.yaml -n ingress-nginx

# Apply the MetalLB chart
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.8/config/manifests/metallb-native.yaml

# Wait until the MetalLB controller is up and running
echo "Waiting for MetalLB controller to be ready..."
kubectl wait --for=condition=available --timeout=600s deployment/controller -n metallb-system

# Apply the MetalLB configuration
kubectl apply -f nextcloud/metallb/metallb-config.yaml

# Wait until the ingress-nginx controller is up and running
echo "Waiting for ingress-nginx controller to be ready..."
kubectl wait --for=condition=available --timeout=600s deployment/ingress-nginx-controller -n ingress-nginx

# Download the Nextcloud Helm chart and install it
helm repo add nextcloud https://nextcloud.github.io/helm/
helm repo update
helm install $NAME nextcloud/nextcloud -f nextcloud/values.yaml -n $NAMESPACE
