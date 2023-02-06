#!/bin/bash

export GITHUB_TOKEN={get secret}
export GITHUB_USER=johanlido
export GITHUB_USER_MAIL=johan.lido@gmail.com

# Update the system
yum update -y &
pid=$!
wait $pid

# Install the necessary packages
yum install -y wget git &
pid=$!
wait $pid

# Install tree
yum install -y tree
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
yum install -y kubelet kubeadm kubectl 
systemctl enable --now kubelet

# Initialize the cluster
kubeadm init --pod-network-cidr=10.244.0.0/16 

# Configure kubectl
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

kubectl create secret docker-registry ghcr-secret \
  --docker-server=ghcr.io \
  --docker-username=${GITHUB_USER} \
  --docker-password=${GITHUB_TOKEN} \
  --docker-email=${GITHUB_USER_MAIL}

echo 'Kubernetes base installation done, please run the following commands on worker nodes to join the nodes to the cluster:\n'
join_command=$(kubeadm token create --print-join-command)
echo  $join_command $' --ignore-preflight-errors='all''
echo 'configure AWS keys and region with AWS configure'

