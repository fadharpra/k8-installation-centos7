#!/bin/sh
############################################################
# Kubernetes Install Script for Debian 9 (Stretch)
# 
# run as sudo 
############################################################

# determine if we run as sudo
userid="${SUDO_USER:-$USER}"
if [ "$userid" == 'root' ]
  then 
    echo "Please run the setup as sudo and not as root!"
    exit 1
fi
if [ "$EUID" -ne 0 ]
  then 
    echo "Please run setup as sudo!"
    exit 1
fi

echo "#############################################"
echo " adding repositories..."
echo "#############################################"
apt-get update
apt-get install -y apt-transport-https ca-certificates ne curl gnupg2 software-properties-common

# Add docker repositry
curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
add-apt-repository \
          "deb [arch=amd64] https://download.docker.com/linux/debian \
           $(lsb_release -cs) \
           stable"
           
# Add kubernetes repository           
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF | tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF


echo "#############################################"
echo " installing docker and kubernetes...."
echo "#############################################"
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io kubelet kubeadm kubectl

#####################################################################################
# Kubernetes is now installed. To setup a new kubernetes cluster with a master node 
# run:
#  $ kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=[YOUR-NODE-IP-ADDRESS]
#
# This command will setup a new cluster. Follow the instructions of the output.
# The output will show also the command how to join a worker node.
# You can use this script also to install a worker node. 
#####################################################################################
