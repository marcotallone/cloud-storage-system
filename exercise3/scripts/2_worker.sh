#!/bin/bash

TASKS=2
MASTER_NAME="k01"
MASTER_IP=192.168.133.80
export MASTER_IP

# Title
echo "----------------------------------------------------------------------"
echo "WORKER NODE SET-UP"
echo "----------------------------------------------------------------------"

# Gain root access
sudo su

# Copy the credentials
echo "----------------------------------------------------------------------"
echo "[1/${TASKS}] Copying the credentials from the master node"
echo "----------------------------------------------------------------------"
scp -o stricthostkeychecking=no root@$MASTER_IP:/home/vagrant/admin.conf /home/vagrant/admin.conf

# Copy the admin.conf file
mkdir -p $HOME/.kube
sudo cp -i /home/vagrant/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Join the cluster
echo "----------------------------------------------------------------------"
echo "[2/${TASKS}] Joining the cluster with provided script"
echo "----------------------------------------------------------------------"
scp -o StrictHostKeyChecking=no root@$MASTER_IP:/root/join.sh /root/join.sh
/root/join.sh