# Home Server

This README covers setting up the Walton Home Server on a Raspberry Pi running Ubuntu Server.

## Current Domains

| Domain          | Description              |
|-----------------|--------------------------|
| dashboard.local | The Kubernetes Dashboard |

## Deploying Terraform

Ensure the kubeconfig for the server is at `~/.kube/config`

```bash
export KUBECONFIG=~/.kube/config
cd terraform
terraform plan -out out.tfplan
terraform apply out.tfplan
```

## Setting up a Pi as a server

### Update system

```bash
sudo apt upgrade
sudo apt update
sudo apt install zsh nfs-common
```

### Install oh-my-zsh

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

### Update .zshrc file

Add the following plugins to the .zshrc file:

- microk8s

Change the ZSH_THEME to "clean"

Add the following to the end of the file:

```bash
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

### Enable Dashboard and Ingress

```bash
me dashboard ingress
```

### Mount external hdd

```bash
# Get the drive information
lsblk -o NAME,FSTYPE,UUID

# Add to fstab
sudo vi /etc/fstab

# Add this line with information for NAME
# UUID=<UUID> /nfs <FSTYPE> defaults 0 0
```

### Add storage label to master

```bash
microk8s.kubectl label node master hdd=enabled
```

### Install Node-Exporter

Download

```bash
curl -SL https://github.com/prometheus/node_exporter/releases/download/v1.8.2/node_exporter-1.8.2.linux-arm64.tar.gz > node_exporter.tar.gz && sudo tar -xvf node_exporter.tar.gz -C /usr/local/bin/ --strip-components=1
```

Create service file at `/etc/systemd/system/nodeexporter.service`

```ini
[Unit]
Description=NodeExporter

[Service]
TimeoutStartSec=0
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
```

Register the service

```bash
sudo systemctl daemon-reload \
&& sudo systemctl enable nodeexporter \
&& sudo systemctl start nodeexporter
```
