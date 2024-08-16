#!/bin/bash

TASKS=2
MASTER_NAME="k01"

# Title
echo "----------------------------------------------------------------------"
echo "MASTER NODE SET-UP"
echo "----------------------------------------------------------------------"

# Gain root access
sudo su

# Kubeadmin init
echo "----------------------------------------------------------------------"
echo "[1/${TASKS}] Initializing kubernetes for master node"
echo "----------------------------------------------------------------------"
kubeadm init --pod-network-cidr=10.17.0.0/16 --service-cidr=10.96.0.0/12 > /root/kubeinit.log

# Create join command for workers
cat /root/kubeinit.log | grep -A 1 "kubeadm join" > /root/join.sh
chmod +777 /root/join.sh

# Copy the admin.conf file to the user's home directory
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Garant access from second node
sudo cp /etc/kubernetes/admin.conf /home/vagrant/admin.conf
sudo chmod 666 /home/vagrant/admin.conf

# Remove taint from the master node
echo "----------------------------------------------------------------------"
echo "[2/${TASKS}] Removing taint from the master node"
echo "----------------------------------------------------------------------"
kubectl wait --for=condition=ready node $MASTER_NAME --timeout=120s
kubectl taint nodes $MASTER_NAME node-role.kubernetes.io/control-plane-