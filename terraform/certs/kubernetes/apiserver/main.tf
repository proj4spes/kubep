variable "ca_cert_pem" {}
variable "ca_private_key_pem" {}
variable "ip_addresses" {}
variable "master_count" {}

# Kubernetes apiserver certs
resource "tls_private_key" "apiserver" {
  algorithm = "RSA"
}

resource "tls_cert_request" "apiserver" {
  count           = "${var.master_count}"
  key_algorithm   = "RSA"
  private_key_pem = "${tls_private_key.apiserver.private_key_pem}"

  subject {
    common_name = "kube-apiserver"
  }

  dns_names = [
    "kubernetes",
    "kubernetes.default",
    "kubernetes.default.svc",
    "kubernetes.default.svc.cluster.local"
  ]
  ip_addresses = ["${element(split(\",\", var.ip_addresses), count.index)}"]
}

resource "tls_locally_signed_cert" "apiserver" {
  count              = "${var.master_count}"
  cert_request_pem   = "${element(tls_cert_request.apiserver.*.cert_request_pem, count.index)}"
  ca_key_algorithm   = "RSA"
  ca_private_key_pem = "${var.ca_private_key_pem}"
  ca_cert_pem        = "${var.ca_cert_pem}"

  # valid for 365 days
  validity_period_hours = 8760
  early_renewal_hours   = 720

  allowed_uses = [
    "server_auth",
    "client_auth",
    "digital_signature",
    "key_encipherment"
  ]
}

output "private_key" {
  value = "${tls_private_key.apiserver.private_key_pem}"
}
output "cert_pems" {
  value = "${join(",", tls_locally_signed_cert.apiserver.*.cert_pem)}"
}
