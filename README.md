# Home Server

This README covers setting up the Walton Home Server on any number of Raspberry Pi's running Ubuntu Server.

## Building Nodes

Preparing the Raspberry Pi's for kubernetes is handled by Ansible. To build the nodes, run:

```bash
make build
```

This will install all required packages and add docker, helm and the external HDD to the master node.
After microk8s has been installed, the kubeconfig will be copied from the master node to the home directory of the local user.

To create persistent storage directories, run:

```bash
make directories
```

This will ensure that the directories exist on the external HDD used by the NFS server.

## Deployment

Terraform handles deployment to the kubernetes cluster. To deploy Terraform changes first switch to the terraform directory and run:

```bash
terraform plan
```

This will create a plan of the changes to be made. If everything looks good, run:

```bash
terraform apply
```
