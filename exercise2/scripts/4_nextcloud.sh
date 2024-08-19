#!/bin/bash

# Apply the MetalLB chart
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.8/config/manifests/metallb-native.yaml

# Wait until the MetalLB controller is up and running
echo "Waiting for MetalLB controller to be ready..."
kubectl wait --for=condition=available --timeout=600s deployment/controller -n metallb-system

# Apply the MetalLB configuration
kubectl apply -f nextcloud/metallb/metallb-config.yaml

# Deploy the ingress nginx controller and its resources
helm pull oci://ghcr.io/nginxinc/charts/nginx-ingress --untar --version 0.17.1
kubectl apply -f nginx-ingress/crds
helm install nginx-ingress oci://ghcr.io/nginxinc/charts/nginx-ingress --version 0.17.1

# Wait until the ingress-nginx controller is up and running
echo "Waiting for ingress-nginx controller to be ready..."
kubectl wait --for=condition=available --timeout=120s deployment/nginx-ingress-controller

# Create a namespace for Nextcloud
kubectl create namespace nextcloud

# Apply persistent volumes
kubectl apply -f nextcloud/volumes/local-path.yaml
kubectl apply -f nextcloud/volumes/nextcloud-pv.yaml -n nextcloud
kubectl apply -f nextcloud/volumes/nextcloud-pvc.yaml -n nextcloud
kubectl apply -f nextcloud/volumes/postgresql-pv.yaml -n nextcloud
kubectl apply -f nextcloud/volumes/postgresql-pvc.yaml -n nextcloud

# Apply the secrets
kubectl apply -f nextcloud/secrets/nextcloud-secret.yaml -n nextcloud
kubectl apply -f nextcloud/secrets/postgresql-secret.yaml -n nextcloud
kubectl apply -f nextcloud/secrets/redis-secret.yaml -n nextcloud

# Download the Nextcloud Helm chart and install it
helm repo add nextcloud https://nextcloud.github.io/helm/
helm repo update
helm install my-nextcloud nextcloud/nextcloud -f nextcloud/values.yaml -n nextcloud
