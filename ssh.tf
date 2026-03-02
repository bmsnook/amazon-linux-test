## Generate a new SSH key pair
resource "tls_private_key" "project_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

## Save the generated SSH keys to local files
resource "local_file" "private_key" {
  content              = tls_private_key.project_ssh_key.private_key_pem
  filename             = pathexpand("~/.ssh/${local.key_name}")
  file_permission      = "0600"
  directory_permission = "0700"
  provisioner "local-exec" {
    when        = destroy
    command     = "rm -f ${self.filename}"
    interpreter = ["bash", "-c"]
    on_failure  = continue
  }
}
resource "local_file" "public_key" {
  content              = tls_private_key.project_ssh_key.public_key_openssh
  filename             = pathexpand("~/.ssh/${local.key_name}.pub")
  file_permission      = "0644"
  directory_permission = "0700"
  provisioner "local-exec" {
    when        = destroy
    command     = "rm -f ${self.filename}"
    interpreter = ["bash", "-c"]
    on_failure  = continue
  }
}

## Create an AWS Key Pair using the generated public key
resource "aws_key_pair" "project_key_pair" {
  key_name   = local.key_name
  public_key = tls_private_key.project_ssh_key.public_key_openssh
  depends_on = [tls_private_key.project_ssh_key]
}
