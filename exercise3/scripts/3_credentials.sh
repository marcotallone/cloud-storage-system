#!/bin/bash

# Title
echo "----------------------------------------------------------------------"
echo "CREDENTIALS FOR NON ROOT USER"
echo "----------------------------------------------------------------------"

# Copy the credentials for non-root user
cd /home/vagrant
mkdir -p .kube
sudo cp /home/vagrant/admin.conf .kube/config
sudo chown $(id -u vagrant):$(id -g vagrant) .kube/config