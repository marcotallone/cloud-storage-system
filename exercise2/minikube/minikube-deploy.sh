#!/bin/bash

# Check that we're in the right directory (we should find this script in it)
if [ ! -f "minikube-deploy.sh" ]; then
		echo "Please run this script from the nextcloud/minikube directory"
		exit 1
fi

# Check that minikube has been installed
if ! command -v minikube &> /dev/null
then
		echo "Minikube could not be found. Please install it first."
		exit 1
fi

# Enable metallb and ingress addons
minikube addons enable metallb
minikube addons enable ingress

# Apply the MetalLB chart
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.8/config/manifests/metallb-native.yaml

# Wait until the MetalLB controller is up and running
echo "Waiting for MetalLB controller to be ready..."
kubectl wait --for=condition=available --timeout=600s deployment/controller -n metallb-system

# Wait for the MetalLB speaker to be ready
echo "Waiting for MetalLB speaker to be ready..."
kubectl wait --for=condition=ready --timeout=600s pod -l app=speaker -n metallb-system

# Apply the MetalLB configuration
kubectl apply -f metallb/metallb-config-minikube.yaml

# Install nginx ingress controller cdr
rm -rf nginx-ingress # to avoid eventual conflicts
helm pull oci://ghcr.io/nginxinc/charts/nginx-ingress --untar --version 0.17.1
kubectl apply -f nginx-ingress/crds/

# Create nextcloud namespace
kubectl create namespace nextcloud

# Apply persistent volumes
kubectl apply -f volumes/local-path.yaml
kubectl apply -f volumes/nextcloud-pv.yaml -n nextcloud
kubectl apply -f volumes/nextcloud-pvc.yaml -n nextcloud
kubectl apply -f volumes/postgresql-pv.yaml -n nextcloud
kubectl apply -f volumes/postgresql-pvc.yaml -n nextcloud

# Apply the secrets
kubectl apply -f secrets/nextcloud-secret.yaml -n nextcloud
kubectl apply -f secrets/postgresql-secret.yaml -n nextcloud
kubectl apply -f secrets/redis-secret.yaml -n nextcloud

# Download the Nextcloud Helm chart and install it
helm repo add nextcloud https://nextcloud.github.io/helm/
helm repo update
helm install my-nextcloud nextcloud/nextcloud -f values.yaml -n nextcloud
