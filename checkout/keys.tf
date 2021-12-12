resource "tls_private_key" "webserver_private_key" {
  algorithm = var.pk_algo
  rsa_bits  = var.pk_bits
}

resource "local_file" "private_key" {
  content         = tls_private_key.webserver_private_key.private_key_pem
  filename        = var.cert_name
  file_permission = 0400
}

resource "aws_key_pair" "webserver_key" {
  key_name   = var.key_pair_name
  public_key = tls_private_key.webserver_private_key.public_key_openssh
}
