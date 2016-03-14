variable "ca_cert_pem" {}
variable "ca_private_key_pem" {}

# Kubernetes worker cert
resource "tls_private_key" "worker" {
  algorithm = "RSA"
}

resource "tls_cert_request" "worker" {
  key_algorithm = "RSA"

  private_key_pem = "${tls_private_key.worker.private_key_pem}"

  subject {
    common_name = "*"
    organization = "worker"
  }
}

resource "tls_locally_signed_cert" "worker" {
  cert_request_pem = "${tls_cert_request.worker.cert_request_pem}"

  ca_key_algorithm = "RSA"
  ca_private_key_pem = "${var.ca_private_key_pem}"
  ca_cert_pem = "${var.ca_cert_pem}"

  validity_period_hours = 43800

  early_renewal_hours = 720

  allowed_uses = [
    "key_encipherment",
    "server_auth",
    "client_auth"
  ]
}

output "worker_private_key" {
  value = "${tls_private_key.worker.private_key_pem}"
}
output "worker_cert_pem" {
  value = "${tls_locally_signed_cert.worker.cert_pem}"
}
