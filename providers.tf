## Account: bms-ms
provider "aws" {
  # alias   = "dev_account"
  profile = var.aws_profile
  region  = var.region
}
