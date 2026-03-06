locals {
  this_host_ip = data.http.myip.response_body
  this_ip_cidr = "${local.this_host_ip}/32"
  home_ip_cidr = "${var.home_host_ip}/32"
  access_ips   = local.this_ip_cidr != local.home_ip_cidr ? concat([local.this_ip_cidr, local.home_ip_cidr]) : [local.home_ip_cidr]

  is_linux = (length(regexall("^/", lower(abspath(path.root)))) > 0) ? true : false
  host_os  = local.is_linux ? "linux" : "windows"

  key_name        = "${var.project}_${var.environment}_key"
  public_key_path = "~/.ssh/${local.key_name}.pub"

  base_tags = {
    ManagedBy = "Terraform"
    Owner     = var.owner
    Project   = var.project
  }
  # Combine base_tags with additional_tags from tfvars, allowing tfvars to override base_tags if there are conflicts
  global_tags = merge(local.base_tags, var.additional_tags)

  amzn2_ami_id = data.aws_ssm_parameter.amzn2_kernel_510_latest_ami.insecure_value


  # "${var.project}-al2023-${var.environment}-${random_id.al2023_node_id[count.index].dec}"
  # amzn2_instance_names = [for i in range(var.amzn2_instance_count) : "${var.project}-amzn2-${var.environment}-${i}"]
  # al2023_instance_names = [for i in range(var.al2023_instance_count) : "${var.project}-al2023-${var.environment}-${i}"]
  # amzn2_instance_names  = [for i in range(var.amzn2_instance_count) : "${var.project}-amzn2-${var.environment}-${random_id.amzn2[count.index].dec}-${i}"]
  # al2023_instance_names = [for i in range(var.al2023_instance_count) : "${var.project}-al2023-${var.environment}-${random_id.al2023_node_id[count.index].dec}-${i}"]
  # amzn2_instance_names  = [for i in range(var.amzn2_instance_count) : format("%s-amzn2-%s-%s-%s", var.project, var.environment, random_id.amzn2[i].dec, i)]
  # al2023_instance_names = [for i in range(var.al2023_instance_count) : format("%s-al2023-%s-%s-%s", var.project, var.environment, random_id.al2023_node_id[i].dec, i)]

}
