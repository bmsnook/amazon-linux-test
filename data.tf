## Find the latest Ubuntu 24.04 AMI
data "aws_ami" "ubuntu_server_ami" {
  most_recent = true

  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

## IP of the host running Terraform
data "http" "myip" {
  url = "http://api.ipify.org"
}

## /aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2
data "aws_ssm_parameter" "amzn2_x86_latest_ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

data "aws_ssm_parameter" "amzn2_kernel_510_latest_ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-kernel-5.10-hvm-x86_64-gp2"
  # name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-kernel-510-x86_64"
}

data "aws_ami" "amzn2_kernel_515_latest_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
    # values = ["amzn2-ami-kernel-5.15-hvm-*-x86_64-gp2"]
  }
}



## /aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64
data "aws_ssm_parameter" "al2023_x86_latest_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

data "aws_caller_identity" "current" {
}

data "aws_region" "current" {}
data "aws_ip_ranges" "current_region_instance_connect" {
  regions  = [data.aws_region.current.id]
  services = ["ec2_instance_connect"]
}

data "aws_route53_zone" "hosted_zone" {
  name         = var.domain_name
  private_zone = false
}
