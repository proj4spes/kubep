# kubep
KubEPform by Nublando
========
[![wercker
status](https://app.wercker.com/status/d51be2fb5ae796055969b74d7924a059/s/master
"wercker
status")](https://app.wercker.com/project/bykey/d51be2fb5ae796055969b74d7924a059)

Deploy yourself a high-availability Kubernetes cluster, in minutes.
Built on Terraform, CoreOS and Ansible.
Forked by Kubeform/CapGemini
Upgraded to support Terraform 0.7 for the AWS/public cluster solution.(to merge with CAPGemini private/aws)
A recipes for bootstrapping HA Kubernetes clusters on any cloud or on-premise.

Includes the following -

* CoreOS as the base operating system
* Kubernetes (in HA) mode (leader election using Podmaster)
* SSL certs/security for Kubernetes cluster components
* Flannel for networking
* Kubernetes Dashboard
** [Traefik](https://docs.traefik.io/toml/#kubernetes-ingress-backend) as the ingress controller for the edge-routers. For configuring it to use [letsencrypt](https://letsencrypt.org/) you can [edit this file](https://github.com/Capgemini/kubeform/blob/master/roles/addons/files/traefik.toml). Sky/KubeDNS

and optionally -

* Prometheus for cluster monitoring (coming soon!)
* Fluentd, elasticsearch for cluster logging



## Getting started

Check out the instructions for provisioning on different clouds including:

* [AWS](/docs/getting-started-guides/aws/public.md)

## Demo


## Keep up to date...

Check out the [Nublando blog](http://proj4spes.github.io/) to find out more about the stuff Nublando does!
# kubep
