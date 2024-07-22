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
export EDITOR=vim
cd ~
cat << EOF | tee -a ~./bashrc
echo $EDITOR
alias k=kubectl
source < (kubectl completion bash)
EOF

# Installing Helm

dnf install -y helm