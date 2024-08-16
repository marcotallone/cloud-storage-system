#!/bin/bash

# Copy the credentials (normal user)
cd /home/vagrant
mkdir -p .kube
sudo cp /etc/kubernetes/admin.conf .kube/config
sudo chown $(id -u vagrant):$(id -g vagrant) .kube/config

# Installing k9s
dnf install wget -y
cd /tmp
wget https://github.com/derailed/k9s/releases/download/v0.28.2/k9s_Linux_amd64.tar.gz
tar -xvf k9s_Linux_amd64.tar.gz
chmod +x k9s
sudo mv k9s /usr/local/bin

# Select vim as the default editor
cd /home/vagrant
echo "export EDITOR=vim" >> .bashrc

# Aliases and .bashrc configuration
cd ~
echo "export EDITOR=vim" >> /home/vagrant/.bashrc
echo "alias k=kubectl" >> /home/vagrant/.bashrc
echo "alias c=clear" >> /home/vagrant/.bashrc
source /home/vagrant/.bashrc

# Installing Helm
dnf install -y helm