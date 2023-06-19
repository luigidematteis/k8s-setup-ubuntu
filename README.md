⚠️
This repository may be outdated!
Some of the steps listed here may need to be revised to bring the tools up to current versions.


### Kubernetes setup on Ubuntu ^20.04
This script will install all the necessary tools to run up a Kubernetes cluster from the offical k8s repository.

It works with Kubernetes version ^1.24.

#### Note:
It could be necessary to check Go and the container runtime versions for future Kuberentes releases. \
Actual versions:
* Go version: 1.19
* Container runtime: CRIO 1.23

***
### Launch the script:
```
bash k8s-setup.sh
```
It will check if you run on a cloud vm instance or on your local machine, and it will execute the opportune actions consequently.
***
### Update Go and the container runtime versions:
#### In case you need to update these versions for future Kubernetes release, you should check up the following sections within the script.

### Go
> Update the go version
```
## Install Golang v.1.19
wget https://go.dev/dl/go1.19.linux-amd64.tar.gz
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.19.linux-amd64.tar.gz
```

### CRI-O
> Update these variable accordingly to the OS and the CRIO version you require
```
## Install CRI-O v1.23
OS=xUbuntu_20.04
CRIO_VERSION=1.23
```
***
Please, always refer to the offical docs:
https://github.com/kubernetes/community/blob/master/contributors/devel/development.md
