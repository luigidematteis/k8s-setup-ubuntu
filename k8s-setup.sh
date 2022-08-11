#!/bin/bash

## Instructions to fork Kubernetes repository and clone it locally
echo "This script assume that you already know how to fork the official Kubernetes repository locally."
echo "If you haven't done it yet, please check up the following link:"
echo
echo "https://github.com/kubernetes/community/blob/master/contributors/guide/github-workflow.md"
echo
echo "Clone Kubernetes repository..."
echo
echo "Please, fork the official repository later and run the build commands from there."
echo

sudo apt -y install git
mkdir ~/go && cd ~/go
mkdir src && cd src
mkdir k8s.io && cd k8s.io
git clone https://github.com/kubernetes/kubernetes.git

## Install wget
sudo apt update
sudo apt -y install wget

## GNU Development Tools
sudo apt -y update 
sudo apt -y install build-essential 

## Install gnome-terminal
sudo apt -y install gnome-terminal 

## Install rsync
sudo apt -y install rsync

## Install JQ
sudo apt -y install jq

## Install Python-YAML
sudo apt -y install python3-pip
sudo pip3 install PyYAML 
python3 -m pip show PyYAML 

## Install OpenSSL
sudo apt -y update
sudo apt -y install openssl 

## Install CFSSL
sudo apt -y update
sudo apt -y install golang-cfssl

## Install Golang v.1.19
wget https://go.dev/dl/go1.19.linux-amd64.tar.gz
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.19.linux-amd64.tar.gz

## Install CRI-O v1.23
OS=xUbuntu_20.04
CRIO_VERSION=1.23
echo "deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/ /"|sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
echo "deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$CRIO_VERSION/$OS/ /"|sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:$CRIO_VERSION.list
url -L https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable:cri-o:$CRIO_VERSION/$OS/Release.key | sudo apt-key add -
curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/Release.key | sudo apt-key add -
sudo apt -y update
sudo apt -y install -y cri-o cri-o-runc
sudo apt -y install cri-tools
sudo systemctl daemon-reload
sudo systemctl enable crio
sudo systemctl start crio
sudo systemctl --no-pager status crio

## Setup CRI-O default config
cd /etc/crio
sudo touch crio.conf
sudo su -c 'crio config --default > /etc/crio/crio.conf'

USERNAME=$(whoami)
export _USER=$USERNAME
## Export Golang paths
echo "export PATH=\$PATH:/usr/local/go/bin" >> /home/$_USER/.bashrc
echo "export PATH=\$PATH:\$GOPATH/bin" >> /home/$_USER/.bashrc
echo "export PATH=\$PATH:/usr/local/go/bin:/home/$_USER/go/bin" >> /home/$_USER/.bashrc

sudo su -c 'echo "export PATH=\$PATH:/usr/local/go/bin" >> /root/.bashrc'
sudo su -c 'echo "export PATH=\$PATH:\$GOPATH/bin" >> /root/.bashrc'
sudo -Eu root bash -c 'echo "export PATH=\$PATH:/usr/local/go/bin:/home/$_USER/go/bin" >> /root/.bashrc'

## Export ETCD path
echo "export PATH="/home/$_USER/go/src/k8s.io/kubernetes/third_party/etcd:\${PATH}"" >> /home/$_USER/.bashrc
sudo su -c 'touch /home/etcd.env'
sudo -Eu root bash -c 'echo "export PATH="/home/$_USER/go/src/k8s.io/kubernetes/third_party/etcd:\${PATH}"" >> /home/etcd.env'
sudo su -c 'cat /home/etcd.env >> /root/.bashrc'
sudo su -c 'rm -rf /home/etcd.env'

## Export Container Runtime endpoint
echo "export CONTAINER_RUNTIME_ENDPOINT="unix:///var/run/crio/crio.sock"" >> /home/$_USER/.bashrc
sudo su -c 'echo "export CONTAINER_RUNTIME_ENDPOINT="unix:///var/run/crio/crio.sock"" >> /root/.bashrc'

## Export CGROUP Driver
echo "export CGROUP_DRIVER=systemd" >> /home/$_USER/.bashrc
sudo su -c 'echo "export CGROUP_DRIVER=systemd" >> /root/.bashrc'

cd /home/$_USER/go/src/k8s.io/kubernetes

## Install ETCD
sudo su -c './hack/install-etcd.sh'

## Reload systemd
sudo systemctl daemon-reexec

sudo dmidecode -s bios-version | grep -io -e 'google' -e 'amazon'
case $? in
(0) ## Build and run Kubernetes cluster on Cloud
    echo 
    echo "Kubernetes is ready to be compiled."
    echo
    echo "Since you are running on a cloud instance, you should open "
    echo "a new SSH connection and execute the following commands by yourself: "
    echo
    echo "sudo su"
    echo "make all"
    echo
    echo "Please, be aware that it could be necessary time to build it."
    echo
    echo "Once Kubernetes is built, you can run up the cluster: "
    echo
    echo "./hack/local-up-cluster.sh -O"
    echo
    echo "You will be asked to open a new SSH session for kubectl."
    echo "Please, paste the following command into the new terminal session."
    echo
    echo "export KUBECONFIG=/var/run/kubernetes/admin.kubeconfig"
    echo
    echo "Then you can run kubectl: "
    echo
    echo "./cluster/kubectl.sh config view"
    echo
    echo "*** Note: ***"
    echo "Running all the  e2e tests can takes a long time."
    echo 
    echo "Please, always refer to the offical docs:"
    echo
    echo "https://github.com/kubernetes/community/blob/master/contributors/devel/development.md"
    echo
    ;;
(*) echo "You are unning on local machine :"
    source ~/.bashrc
    sudo su -c 'source /root/.bashrc'
    cd ~/go/src/k8s.io/kubernetes
    echo "Kubernetes is ready to be compiled."
    echo "Please, be aware that it could be necessary time to build it."
    make all
    echo
    echo "*** NOTE ***"
    echo "SWAP will be disabled to run Kubernetes: "
    echo "swapoff -a"
    echo
    echo "You can re-enable it using: "
    echo "swapon -a"
    echo 
    sudo swapoff -a
    export DIR="/home/$_USER/go/src/k8s.io/kubernetes"
    gnome-terminal --tab --working-directory=$DIR -- /bin/bash -e -c "pwd && sudo -i -- /bin/bash -e -c 'pwd && bash $DIR/hack/local-up-cluster.sh -O' && exec bash || exec bash"
    gnome-terminal --tab --working-directory=$DIR -- /bin/bash -e -c "pwd && export KUBECONFIG=/var/run/kubernetes/admin.kubeconfig && bash ./cluster/kubectl.sh config view && exec bash || exec bash"
    ;;
esac