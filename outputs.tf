output "al2023_x86_latest_ami_id" {
  value = nonsensitive(data.aws_ssm_parameter.al2023_x86_latest_ami.value)
}

output "al2023_x86_latest_ami_insecure_value" {
  value = data.aws_ssm_parameter.al2023_x86_latest_ami.insecure_value
}

output "amzn2_x86_latest_ami_id" {
  value = nonsensitive(data.aws_ssm_parameter.amzn2_x86_latest_ami.value)
}

output "amzn2_x86_latest_ami_insecure_value" {
  value = data.aws_ssm_parameter.amzn2_x86_latest_ami.insecure_value
}

output "instance_ips" {
  value = [for i in aws_instance.al2023_instance[*] : i.public_ip]
}

output "instance_ids" {
  value = [for i in aws_instance.al2023_instance[*] : i.id]
}

output "instance_hostnames" {
  value = [for i in aws_instance.al2023_instance[*] : i.public_dns]
}

output "aws_account_id" {
  value = nonsensitive(data.aws_caller_identity.current.account_id)
}

output "aws_user_arn" {
  value = nonsensitive(data.aws_caller_identity.current.arn)
}

output "aws_user_id" {
  value = nonsensitive(data.aws_caller_identity.current.user_id)
}

output "current_region_instance_connect" {
  value = data.aws_ip_ranges.current_region_instance_connect
}

output "hosted_zone_id" {
  value = data.aws_route53_zone.hosted_zone.zone_id
}

output "hosted_zone_name" {
  value = data.aws_route53_zone.hosted_zone.name
}

output "amzn2_instance_public_ips" {
  value = [for i in aws_instance.amzn2_instance[*] : i.public_ip]
}

output "amzn2_instance_public_hostnames" {
  value = [for i in aws_instance.amzn2_instance[*] : i.public_dns]
}

output "al2023_instance_public_ips" {
  value = [for i in aws_instance.al2023_instance[*] : i.public_ip]
}

output "al2023_instance_public_hostnames" {
  value = [for i in aws_instance.al2023_instance[*] : i.public_dns]
}
