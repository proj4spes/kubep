variable "do_token" {}
variable "organization" { default = "apollo" }
variable "region" { default = "lon1" }
variable "masters" { default = "3" }
variable "workers" { default = "1" }
variable "master_instance_type" { default = "512mb" }
variable "worker_instance_type" { default = "512mb" }
variable "etcd_discovery_url_file" { default = "etcd_discovery_url.txt" }
/*
  we need to use at least beta because we need rkt version 0.15.0+ to run the
  kubelet wrapper script.
  See https://coreos.com/kubernetes/docs/latest/kubelet-wrapper.html
*/
variable "coreos_image" { default = "coreos-beta" }

# Provider
provider "digitalocean" {
  token = "${var.do_token}"
}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
}

resource "digitalocean_ssh_key" "default" {
  name       = "${var.organization}"
  public_key = "${tls_private_key.ssh.public_key_openssh}"
}

# Export ssh key so we can login with core@instance -i id_rsa
resource "null_resource" "keys" {
  depends_on = ["tls_private_key.ssh"]

  provisioner "local-exec" {
    command = "echo '${tls_private_key.ssh.private_key_pem}' > ${path.module}/id_rsa && chmod 600 ${path.module}/id_rsa"
  }
}

# Generate an etcd URL for the cluster
resource "template_file" "etcd_discovery_url" {
  template = "/dev/null"
  provisioner "local-exec" {
    command = "curl https://discovery.etcd.io/new?size=${var.masters} > ${var.etcd_discovery_url_file}"
  }
  # This will regenerate the discovery URL if the cluster size changes
  vars {
    size = "${var.masters}"
  }
}

module "ca" {
  source      = "../certs/ca"

  organization = "${var.organization}"
}

module "etcd_cert" {
  source             = "../certs/etcd"
  ca_cert_pem        = "${module.ca.ca_cert_pem}"
  ca_private_key_pem = "${module.ca.ca_private_key_pem}"
}

module "apiserver_cert" {
  source             = "../certs/kubernetes/apiserver"
  ca_cert_pem        = "${module.ca.ca_cert_pem}"
  ca_private_key_pem = "${module.ca.ca_private_key_pem}"
}

module "worker_cert" {
  source             = "../certs/kubernetes/worker"
  ca_cert_pem        = "${module.ca.ca_cert_pem}"
  ca_private_key_pem = "${module.ca.ca_private_key_pem}"
}

resource "template_file" "master_cloud_init" {
  template   = "master-cloud-config.yml.tpl"
  depends_on = ["template_file.etcd_discovery_url"]
  vars {
    etcd_discovery_url = "${file(var.etcd_discovery_url_file)}"
    size               = "${var.masters}"
    region             = "${var.region}"
    etcd_ca            = "${replace(module.ca.ca_cert_pem, \"\n\", \"\\n\")}"
    etcd_cert          = "${replace(module.etcd_cert.etcd_cert_pem, \"\n\", \"\\n\")}"
    etcd_key           = "${replace(module.etcd_cert.etcd_private_key, \"\n\", \"\\n\")}"
    apiserver_cert     = "${replace(module.apiserver_cert.apiserver_cert_pem, \"\n\", \"\\n\")}"
    apiserver_key      = "${replace(module.apiserver_cert.apiserver_private_key, \"\n\", \"\\n\")}"
    kubernetes_ca      = "${replace(module.ca.ca_cert_pem, \"\n\", \"\\n\")}"
  }
}

resource "template_file" "worker_cloud_init" {
  template   = "worker-cloud-config.yml.tpl"
  depends_on = ["template_file.etcd_discovery_url"]
  vars {
    etcd_discovery_url = "${file(var.etcd_discovery_url_file)}"
    size               = "${var.masters}"
    region             = "${var.region}"
    etcd_ca            = "${replace(module.ca.ca_cert_pem, \"\n\", \"\\n\")}"
    etcd_cert          = "${replace(module.etcd_cert.etcd_cert_pem, \"\n\", \"\\n\")}"
    etcd_key           = "${replace(module.etcd_cert.etcd_private_key, \"\n\", \"\\n\")}"
    worker_cert        = "${replace(module.apiserver_cert.apiserver_cert_pem, \"\n\", \"\\n\")}"
    worker_key         = "${replace(module.apiserver_cert.apiserver_private_key, \"\n\", \"\\n\")}"
    kubernetes_ca      = "${replace(module.ca.ca_cert_pem, \"\n\", \"\\n\")}"
  }
}

# Masters
resource "digitalocean_droplet" "master" {
  image              = "${var.coreos_image}"
  region             = "${var.region}"
  count              = "${var.masters}"
  name               = "k8s-master-${count.index}"
  size               = "${var.master_instance_type}"
  private_networking = true
  user_data          = "${template_file.master_cloud_init.rendered}"
  ssh_keys = [
    "${digitalocean_ssh_key.default.id}"
  ]

  # Do some early bootstrapping of the CoreOS machines. This will install
  # python and pip so we can use as the ansible_python_interpreter in our playbooks
  connection {
    user                = "core"
    private_key         = "${tls_private_key.ssh.private_key_pem}"
  }
  provisioner "file" {
    source      = "../scripts/coreos"
    destination = "/tmp"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo chmod -R +x /tmp/coreos",
      "/tmp/coreos/bootstrap.sh",
      "~/bin/python /tmp/coreos/get-pip.py",
      "sudo mv /tmp/coreos/runner ~/bin/pip && sudo chmod 0755 ~/bin/pip",
      "sudo rm -rf /tmp/coreos"
    ]
  }
}

# Workers
resource "digitalocean_droplet" "worker" {
  image              = "${var.coreos_image}"
  region             = "${var.region}"
  count              = "${var.workers}"
  name               = "k8s-worker-${count.index}"
  size               = "${var.worker_instance_type}"
  private_networking = true
  user_data          = "${template_file.worker_cloud_init.rendered}"
  ssh_keys = [
    "${digitalocean_ssh_key.default.id}"
  ]
  # Do some early bootstrapping of the CoreOS machines. This will install
  # python and pip so we can use as the ansible_python_interpreter in our playbooks
  connection {
    user                = "core"
    private_key         = "${tls_private_key.ssh.private_key_pem}"
  }
  provisioner "file" {
    source      = "../scripts/coreos"
    destination = "/tmp"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo chmod -R +x /tmp/coreos",
      "/tmp/coreos/bootstrap.sh",
      "~/bin/python /tmp/coreos/get-pip.py",
      "sudo mv /tmp/coreos/runner ~/bin/pip && sudo chmod 0755 ~/bin/pip",
      "sudo rm -rf /tmp/coreos"
    ]
  }
}

# Outputs
output "master_ips" {
  value = "${join(",", digitalocean_droplet.master.*.ipv4_address)}"
}
output "worker_ips" {
  value = "${join(",", digitalocean_droplet.worker.*.ipv4_address)}"
}
