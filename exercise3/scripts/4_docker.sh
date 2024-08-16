#!/bin/bash

TASKS=2

# Title
echo "----------------------------------------------------------------------"
echo "DOCKER MPI IMAGES BUILDER"
echo "----------------------------------------------------------------------"

# Gain root access
sudo su

# Change default container registry
echo "----------------------------------------------------------------------"
echo "[1/${TASKS}] Changing default container registry"
echo "----------------------------------------------------------------------"
cat << EOF | tee /etc/containers/registries.conf
[registries.search]
registries = ['docker.io']
EOF

# Buildin the images
echo "----------------------------------------------------------------------"
echo "[2/${TASKS}] Building the images"
echo "----------------------------------------------------------------------"
cd /home/vagrant/docker
podman build -f openmpi-builder.Dockerfile -t my-builder
podman build -f osu-code-provider.Dockerfile -t osu-code-provider
podman build -f openmpi.Dockerfile -t my-operator
podman build -t my-osu-bench .
chown -R vagrant:vagrant /home/vagrant/docker