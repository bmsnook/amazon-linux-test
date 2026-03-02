resource "random_id" "al2023_node_id" {
  byte_length = 2
  count       = var.al2023_instance_count
}

resource "aws_instance" "al2023_instance" {
  ami    = data.aws_ssm_parameter.al2023_x86_latest_ami.insecure_value
  region = var.region
  # ami           = "ami-0634f3c109dcdc659"
  instance_type = var.main_instance_type
  count         = var.al2023_instance_count
  key_name      = aws_key_pair.project_key_pair.key_name
  # vpc_security_group_ids = [aws_security_group.project_sg.id]
  # subnet_id     = aws_subnet.main_subnet.id
  vpc_security_group_ids = [aws_security_group.project_sg.id, aws_security_group.al2023_sg_hostself[count.index].id]
  subnet_id              = aws_subnet.project_public_subnet[count.index].id

  associate_public_ip_address = true
  root_block_device {
    volume_size           = var.main_vol_size
    volume_type           = "gp3"
    delete_on_termination = true
  }

  user_data = <<-EOF
              #!/bin/bash
              hostnamectl set-hostname "${var.project}-al2023-${var.environment}-${random_id.al2023_node_id[count.index].dec}-${count.index + 1}"
              EOF

  tags = merge(
    {
      # Name        = "${var.project}-al2023-${var.environment}-${random_id.al2023_node_id[count.index].dec}"
      Name   = "${var.project}-al2023-${var.environment}-${random_id.al2023_node_id[count.index].dec}-${count.index + 1}",
      NodeID = random_id.al2023_node_id[count.index].dec
    },
    local.global_tags
  )

  provisioner "local-exec" {
    command = templatefile("ssh-config-${local.host_os}.tpl", {
      host     = "${var.project}-al2023-${var.environment}-${random_id.al2023_node_id[count.index].dec}-${count.index + 1}",
      hostname = "${var.project}-al2023-${var.environment}-${random_id.al2023_node_id[count.index].dec}-${count.index + 1}.${var.domain_name}",
      hostip   = self.public_ip,
      # user         = "ubuntu",
      user         = "ec2-user",
      identityfile = "~/.ssh/${local.key_name}"
    })
    interpreter = local.host_os == "windows" ? ["Powershell", "-Command"] : ["bash", "-c"]
  }

  provisioner "local-exec" {
    command = "sed -i'' -e '/^$/N;/^\\n$/D' ~/.ssh/config"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "sed -i'' -e '/^Host '${self.public_ip}'/,/^$/d' ~/.ssh/config"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "sed -i'' -e '/^$/N;/^\\n$/D' ~/.ssh/config"
  }
}

resource "aws_route53_record" "al2023_instance_records" {
  count   = var.al2023_instance_count
  zone_id = data.aws_route53_zone.hosted_zone.zone_id
  name    = "${var.project}-al2023-${var.environment}-${random_id.al2023_node_id[count.index].dec}-${count.index + 1}.${var.domain_name}"
  type    = "CNAME"
  ttl     = 300
  records = [aws_instance.al2023_instance[count.index].public_dns]
}
