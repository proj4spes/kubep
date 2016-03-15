variable "ca_cert_pem" {}
variable "ca_private_key_pem" {}

# Kubernetes apiserver cert
resource "tls_private_key" "apiserver" {
  algorithm = "RSA"
}

resource "tls_cert_request" "apiserver" {
  key_algorithm = "RSA"

  private_key_pem = "${tls_private_key.apiserver.private_key_pem}"

  subject {
    common_name  = "*"
    organization = "apiserver"
  }

  dns_names = [
    "kubernetes",
    "kubernetes.default",
    "kubernetes.default.svc",
    "kubernetes.default.svc.cluster.local",
    "10.3.0.1", # k8s Service IP
  ]
}

resource "tls_locally_signed_cert" "apiserver" {
  cert_request_pem = "${tls_cert_request.apiserver.cert_request_pem}"

  ca_key_algorithm   = "RSA"
  ca_private_key_pem = "${var.ca_private_key_pem}"
  ca_cert_pem        = "${var.ca_cert_pem}"

  validity_period_hours = 43800

  early_renewal_hours = 720

  allowed_uses = [
    "server_auth",
    "client_auth",
    "digital_signature",
    "key_encipherment"
  ]
}

output "apiserver_private_key" {
  value = "${tls_private_key.apiserver.private_key_pem}"
}
output "apiserver_cert_pem" {
  value = "${tls_locally_signed_cert.apiserver.cert_pem}"
}
