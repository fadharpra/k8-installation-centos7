#!/bin/sh
############################################################
# Kubernetes Install Script for CentOS 7          
#
# run as sudo
############################################################

echo "#############################################"
echo " Disabled Selinux "
echo "#############################################"
setenforce 0
sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux

echo "#############################################"
echo " Enable br_netfilter Kernel Module "
echo "#############################################"
modprobe br_netfilter
echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables

echo "#############################################"
echo " Disable SWAP "
echo "#############################################"
swapoff -a

echo "#############################################"
echo " Install Docker CE "
echo "#############################################"
yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install -y docker-ce
 
echo "#############################################"
echo " adding repositories kubernetes "
echo "#############################################"
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

yum install -y kubelet kubeadm kubectl

echo "#############################################"
echo " Start and Enabled Kubernetes Service "
echo "#############################################"
systemctl start docker && systemctl enable docker 
systemctl start kubelet && systemctl enable kubelet

echo "#############################################"
echo " Change the cgroup-driver "
echo "#############################################"
docker info | grep -i cgroup
sed -i 's/cgroup-driver=systemd/cgroup-driver=cgroupfs/g' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
systemctl daemon-reload
systemctl restart kubelet

#####################################################################################
# Kubernetes is now installed. To setup a new kubernetes cluster with a master node
# run:
#  $ kubeadm init --apiserver-advertise-address=[YOUR-NODE-IP-ADDRESS] --pod-network-cidr=10.244.0.0/16
#
# This command will setup a new cluster. Follow the instructions of the output.
# The output will show also the command how to join a worker node.
# You can use this script also to install a worker node.
#####################################################################################

