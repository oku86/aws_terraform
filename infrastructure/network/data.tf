# -----------------------------------------------------------------------------
# AWS PROVIDER AND REMOTE STATE
# -----------------------------------------------------------------------------

provider "aws" {
  region = var.aws_region
}

terraform {
  backend "s3" {
    bucket  = "check-terraform-state"
    key     = "infrastructure/network/terraform.tfstate"
    encrypt = true
    region  = "eu-west-1"
  }
}

# -----------------------------------------------------------------------------
# GET ENVIRONMENT NAME
# -----------------------------------------------------------------------------

data "template_file" "environment" {
  template = file("../environment")
}
