variable "terraform_org" {
  type = string
}

variable "project" {
  type    = string
  default = "new_project"
}

variable "region" {
  type    = string
  default = "us-east-2"
}

variable "home_host_ip" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "main_instance_type" {
  type    = string
  default = "t3.micro"
}

variable "main_vol_size" {
  type    = number
  default = 8
}

variable "main_instance_count" {
  type    = number
  default = 1
}

variable "amzn2_instance_count" {
  type    = number
  default = 0
}

variable "al2023_instance_count" {
  type    = number
  default = 0
}

variable "aws_profile" {
  type    = string
  default = "default"
}

variable "aws_shared_credentials_files" {
  type    = string
  default = "~/.aws/credentials"
}

variable "vpc_cidr" {
  type    = string
  default = "10.124.0.0/16"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "additional_tags" {
  description = "Additional tags to apply to all resources from tfvars"
  type        = map(string)
  default     = {}
}

variable "owner" {
  type    = string
  default = "KilroyWasHere"
}
