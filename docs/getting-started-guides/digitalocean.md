# Getting started on Digitalocean

The cluster is provisioned in separate stages as follows:

* [Terraform](https://terraform.io) to provision the cluster instances, security groups, firewalls, cloud infrastructure and security (SSL) certificates.
* [Ansible](https://ansible.com) to configure the cluster, including installing Kubernetes, addons and platform level configuration (files, directories etc...)

## Prerequisites

1. You need a Digitalocean account. Visit [https://cloud.digitalocean.com/registrations/new](https://cloud.digitalocean.com/registrations/new) to get started
2. You need to have installed and configured Terraform (>= 0.6.16 recommended). Visit [https://www.terraform.io/intro/getting-started/install.html](https://www.terraform.io/intro/getting-started/install.html) to get started.
3. You need to have [Python](https://www.python.org/) >= 2.7.5 installed along with [pip](https://pip.pypa.io/en/latest/installing.html).

## Cluster Turnup

### Download Kubeform (install from source at head)
```
git clone https://github.com/Capgemini/kubeform.git /tmp/kubeform
cd /tmp/kubeform
pip install -r requirements.txt
```

### Set config

Configuration can be set via environment variables. As a minimum you will need to set these environment variables:

```
export TF_VAR_do_token=$DO_API_TOKEN
export TF_VAR_STATE_ROOT=~/kubeform/terraform/digitalocean
```

### Provision the cluster infrastructure

```
cd /tmp/kubeform/terraform/digitalocean
terraform apply
```

### Configure the cluster

To install the role dependencies for Ansible execute:

```
cd /tmp/kubeform
ansible-galaxy install -r requirements.yml
```

To run the Ansible playbook (to configure the cluster):

```
ansible-playbook -u core --ssh-common-args="-F /tmp/kubeform/terraform/digitalocean/ssh.config -i /tmp/kubeform/terraform/digitalocean/id_rsa -q" --inventory-file=inventory site.yml
```

This will run the playbook (using the credentials output by terraform and the terraform state as a dynamic inventory).

## Cluster Destroy

```
cd /tmp/kubeform/terraform/digitalocean
terraform destroy
```
