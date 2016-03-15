variable "organization" { default = "apollo" }

resource "tls_private_key" "ca" {
  algorithm = "RSA"
}

resource "tls_self_signed_cert" "ca" {
  key_algorithm   = "RSA"
  private_key_pem = "${tls_private_key.ca.private_key_pem}"

  subject {
    common_name  = "*"
    organization = "${var.organization}"
  }

  allowed_uses = [
    "key_encipherment",
    "cert_signing",
    "server_auth",
    "client_auth"
  ]

  validity_period_hours = 43800

  early_renewal_hours = 720

  is_ca_certificate = true
}

output "ca_cert_pem" {
  value = "${tls_self_signed_cert.ca.cert_pem}"
}
output "ca_private_key_pem" {
  value = "${tls_private_key.ca.private_key_pem}"
}
