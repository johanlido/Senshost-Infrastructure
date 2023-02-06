#!/bin/bash

# Update the system
yum update -y &
pid=$!
wait $pid

# Install the necessary packages
yum install -y wget git &
pid=$!
wait $pid

# Disable swap
swapoff -a
sed -i '/ swap / s/^/#/' /etc/fstab

# Install Docker
amazon-linux-extras install docker -y
systemctl enable --now docker

# Add the Kubernetes repo
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

# Install Kubernetes
yum install -y kubelet kubeadm &
pid=$!
wait $pid
systemctl enable --now kubelet

mkdir -p $HOME/.kube
touch $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

cp -i /etc/kubernetes/admin.conf $HOME/.kube/config


echo '\nInstall complete, now join the cluster with command from Control plane installation\n\n'
echo 'Need to copy admin.config file from Control plane /etc/kubernetes/admin.conf to $HOME/.kube/config\n\n'
echo 'Setup AWS configuration for keys and region with AWS configure'


