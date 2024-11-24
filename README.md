# Home Server

This README covers setting up the Walton Home Server on a Raspberry Pi running Ubuntu Server.

## Setting up a new Pi

### Update system

```bash
sudo apt upgrade
sudo apt update
```

### Install oh-my-zsh

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

### Update .zshrc file

Add the following plugins to the .zshrc file:

- docker
- docker-compose
- git
- kubectl
- microk8s
- npm
- nvm
- pip
- pylint
- python
- terraform
- yarn

Change the ZSH_THEME to "clean"

Add the following to the end of the file:

```bash
alias tffr='terraform fmt --recursive'

export KUBECONFIG=~/.kube/config
```

### Enable cgroups

```bash
sudo vi /boot/firmware/cmdline.txt
```

add the following to the end of the line:

```code
cgroup_enable=memory cgroup_memory=1
```

### Install microk8s

```bash
sudo snap install microk8s --classic
```

### Add hal to microk8s group

```bash
sudo usermod -a -G microk8s hal
```

### Copy kubeconfig to home directory

```bash
mkdir ~/.kube
mco > ~/.kube/config
```

### Create root CA and certificate

```bash
mkdir ~/certs
cd ~/certs

openssl req -x509 -newkey rsa:4096 -sha256 -days 3650 -nodes -keyout waltonCA.key \
-out waltonCA.crt -subj "/C=US/ST=Iowa/L=Indianola/O=Walton Farms/OU=Home/CN=walton.farms" \
-addext "subjectAltName=DNS:walton.farms,DNS:www.walton.farms"
```

### Enable Dashboard and Ingress

```bash
me dashboard ingress
```
