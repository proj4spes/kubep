resource "tls_cert_request" "example" {
    key_algorithm = "ECDSA"
    private_key_pem = "${file("/home/enri/east_key.pem")}"

    subject {
        common_name = "example.com"
        organization = "ACME Examples, Inc"
    }
    ip_addresses =[ "10.101.0.1", "10.10.20.10", "10.10.20.30"]
    dns_names = ["server.pinco.pallo", "pippo.pluto"]
}

