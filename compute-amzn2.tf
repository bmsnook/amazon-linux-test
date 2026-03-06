resource "random_id" "amzn2_node_id" {
  byte_length = 2
  count       = var.amzn2_instance_count
}

resource "aws_instance" "amzn2_instance" {
  # ami    = data.aws_ssm_parameter.amzn2_x86_latest_ami.insecure_value
  ami    = local.amzn2_ami_id
  region = var.region
  # ami           = "ami-0634f3c109dcdc659"
  instance_type = var.main_instance_type
  count         = var.amzn2_instance_count
  key_name      = aws_key_pair.project_key_pair.key_name
  # vpc_security_group_ids = [aws_security_group.project_sg.id]
  # subnet_id     = aws_subnet.main_subnet.id
  vpc_security_group_ids = [aws_security_group.project_sg.id, aws_security_group.amzn2_sg_hostself[count.index].id]
  subnet_id              = aws_subnet.project_public_subnet[count.index].id

  associate_public_ip_address = true
  root_block_device {
    volume_size           = var.main_vol_size
    volume_type           = "gp3"
    delete_on_termination = true
  }

  user_data = <<-EOF
              #!/bin/bash
              hostnamectl set-hostname "${var.project}-amzn2-${var.environment}-${random_id.amzn2_node_id[count.index].dec}"
              EOF

  tags = merge(
    local.global_tags,
    {
      # Name        = "${var.project}-main-${random_id.amzn2_node_id[count.index].dec}"
      # Name   = "${var.project}-amzn2-${var.environment}-${random_id.amzn2_node_id[count.index].dec}-${count.index + 1}",
      Name   = "${var.project}-amzn2-${var.environment}-${random_id.amzn2_node_id[count.index].dec}",
      NodeID = random_id.amzn2_node_id[count.index].dec
    }
  )

  provisioner "local-exec" {
    command = templatefile("ssh-config-${local.host_os}.tpl", {
      # host     = "${var.project}-amzn2-${var.environment}-${random_id.amzn2_node_id[count.index].dec}-${count.index + 1}",
      # hostname = "${var.project}-amzn2-${var.environment}-${random_id.amzn2_node_id[count.index].dec}-${count.index + 1}.${var.domain_name}",
      host     = "${var.project}-amzn2-${var.environment}-${random_id.amzn2_node_id[count.index].dec}",
      hostname = "${var.project}-amzn2-${var.environment}-${random_id.amzn2_node_id[count.index].dec}.${var.domain_name}",
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
    command = "sed -i'' -e '/^Host '${var.project}-amzn2-${var.environment}-${random_id.amzn2_node_id[count.index].dec}'/,/^$/d' ~/.ssh/config"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "sed -i'' -e '/^$/N;/^\\n$/D' ~/.ssh/config"
  }
}

resource "aws_route53_record" "amzn2_instance_records" {
  count   = var.amzn2_instance_count
  zone_id = data.aws_route53_zone.hosted_zone.zone_id
  # name    = "${var.project}-amzn2-${var.environment}-${random_id.amzn2_node_id[count.index].dec}-${count.index + 1}.${var.domain_name}"
  name    = "${var.project}-amzn2-${var.environment}-${random_id.amzn2_node_id[count.index].dec}.${var.domain_name}"
  type    = "CNAME"
  ttl     = 300
  records = [aws_instance.amzn2_instance[count.index].public_dns]
}
