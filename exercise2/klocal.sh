#!/bin/bash

# Script to set up kubectl of vagrant vm locally
# NOTE: Run after having set up the vagrant vm
# NOTE: This requires kubectl installed locally
# WARNING: If you're running vagrant in docker you have to edit the first line
# of the $HOME/.kube/config file removing the UID and GID of the user

# Name of the master node
MASTER_NAME=k01

mkdir -p $HOME/.kube
vagrant ssh $MASTER_NAME -c "sudo cat /etc/kubernetes/admin.conf" > $HOME/.kube/config.demo

echo "export KUBECONFIG=$HOME/.kube/config.demo" | tee -a ~/.zshrc
cat ~/.zshrc

source ~/.zshrc
