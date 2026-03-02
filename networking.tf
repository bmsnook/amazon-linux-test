locals {
  azs = data.aws_availability_zones.available.names
}

data "aws_availability_zones" "available" {}

resource "random_id" "random" {
  byte_length = 2
}

resource "aws_vpc" "project_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name      = "${var.project}-vpc-${random_id.random.dec}"
    Project   = var.project
    ManagedBy = "Terraform"
    Owner     = var.owner
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_internet_gateway" "project_internet_gateway" {
  vpc_id = aws_vpc.project_vpc.id

  tags = {
    Name      = "${var.project}-igw-${random_id.random.dec}"
    Project   = var.project
    ManagedBy = "Terraform"
    Owner     = var.owner
  }
}

resource "aws_route_table" "project_public_rt" {
  vpc_id = aws_vpc.project_vpc.id

  tags = {
    Name      = "${var.project}-public"
    Project   = var.project
    ManagedBy = "Terraform"
    Owner     = var.owner
  }
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.project_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.project_internet_gateway.id
}

resource "aws_default_route_table" "project_private_rt" {
  default_route_table_id = aws_vpc.project_vpc.default_route_table_id

  tags = {
    Name      = "${var.project}-private"
    Project   = var.project
    ManagedBy = "Terraform"
    Owner     = var.owner
  }
}

resource "aws_subnet" "project_public_subnet" {
  count                   = length(local.azs)
  vpc_id                  = aws_vpc.project_vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  map_public_ip_on_launch = true
  availability_zone       = local.azs[count.index]

  tags = {
    Name      = "${var.project}-public-${count.index + 1}"
    Project   = var.project
    ManagedBy = "Terraform"
    Owner     = var.owner
  }
}

resource "aws_subnet" "project_private_subnet" {
  count                   = length(local.azs)
  vpc_id                  = aws_vpc.project_vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, length(local.azs) + count.index)
  map_public_ip_on_launch = false
  availability_zone       = local.azs[count.index]

  tags = {
    Name      = "${var.project}-private-${count.index + 1}"
    Project   = var.project
    ManagedBy = "Terraform"
    Owner     = var.owner
  }
}

resource "aws_route_table_association" "project_public_assoc" {
  count          = length(local.azs)
  subnet_id      = aws_subnet.project_public_subnet[count.index].id
  route_table_id = aws_route_table.project_public_rt.id
}

resource "aws_security_group" "project_sg" {
  name        = "${var.project}-public_sg"
  description = "Security group for public instances"
  vpc_id      = aws_vpc.project_vpc.id

  tags = {
    Name      = "${var.project}-public-sg"
    Project   = var.project
    ManagedBy = "Terraform"
    Owner     = var.owner
  }
}

resource "aws_vpc_security_group_ingress_rule" "ingress_admin" {
  for_each          = toset(local.access_ips)
  security_group_id = aws_security_group.project_sg.id
  cidr_ipv4         = each.value
  from_port         = 0
  to_port           = 65535
  ip_protocol       = "-1"
  description       = "Admin access from trusted IPs (home_host_ip and this_host_ip, if different)"
}

resource "aws_vpc_security_group_ingress_rule" "ec2_instance_connect_ipv4" {
  for_each          = toset(data.aws_ip_ranges.current_region_instance_connect.cidr_blocks)
  security_group_id = aws_security_group.project_sg.id
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  cidr_ipv4         = each.value
}

resource "aws_vpc_security_group_ingress_rule" "ec2_instance_connect_ipv6" {
  for_each          = toset(data.aws_ip_ranges.current_region_instance_connect.ipv6_cidr_blocks)
  security_group_id = aws_security_group.project_sg.id
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  cidr_ipv6         = each.value
}

resource "aws_vpc_security_group_egress_rule" "egress_all" {
  security_group_id = aws_security_group.project_sg.id
  from_port         = 0
  to_port           = 65535
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_security_group" "project_sg_hostself" {
  count  = var.main_instance_count
  name   = "${var.project}-self_sg-${random_id.al2023_node_id[count.index].dec}"
  vpc_id = aws_vpc.project_vpc.id

  tags = {
    Name      = "${var.project}_self_sg-${random_id.al2023_node_id[count.index].dec}"
    Project   = var.project
    ManagedBy = "Terraform"
    Owner     = var.owner
  }
}

resource "aws_vpc_security_group_ingress_rule" "ingress_hostself" {
  count             = var.main_instance_count
  from_port         = 0
  to_port           = 65535
  ip_protocol       = "-1"
  cidr_ipv4         = "${aws_instance.al2023_instance[count.index].public_ip}/32"
  security_group_id = aws_security_group.project_sg_hostself[count.index].id
  description       = "Allow all traffic from self"
}
