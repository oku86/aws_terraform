# -----------------------------------------------------------------------------
# STATE FILE
# -----------------------------------------------------------------------------

provider "aws" {
  region = var.aws_region
}

terraform {
  backend "s3" {
    bucket  = "check-terraform-state"
    key     = "ecs-cluster/terraform.tfstate"
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

# -----------------------------------------------------------------------------
# ECS Instance policy
# -----------------------------------------------------------------------------

data "template_file" "ecs_instance_policy" {
  template = file("templates/assume-role-policy")

  vars = {
    service_name = "ec2"
  }
}

# -----------------------------------------------------------------------------
# DATA SOURCES FOR NETWORK RESOURCES
# -----------------------------------------------------------------------------

data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket  = "check-terraform-state"
    key     = "infrastructure/network/terraform.tfstate"
    region  = var.aws_region
  }
}

# -----------------------------------------------------------------------------
# FIND THE LATEST AMI FOR THE ECS CLUSTER
# -----------------------------------------------------------------------------

data "aws_ami" "latest_ecs_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "state"
    values = ["available"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*x86_64-ebs"]
  }
}

# -----------------------------------------------------------------------------
# GET USER DATA FROM TEMPLATE
# -----------------------------------------------------------------------------

data "template_file" "user_data" {
  template = file("templates/user-data")

  vars = {
    cluster_name  = "${data.template_file.environment.rendered}-cluster-01"
  }
}

# -----------------------------------------------------------------------------
# DATA SOURCES FOR ALB ACCESS RESOURCES
# -----------------------------------------------------------------------------

data "terraform_remote_state" "alb" {
  backend = "s3"

  config = {
    bucket  = "check-terraform-state"
    key     = "alb/terraform.tfstate"
    region  = var.aws_region
  }
}

# -----------------------------------------------------------------------------
# ECS CLUSTER-LEVEL PERMISSIONS
# -----------------------------------------------------------------------------

data "template_file" "ecs_policy" {
  template = file("templates/ecs-policy")
}

# -----------------------------------------------------------------------------
# GET SNS DATA SOURCE FOR SNS TOPICS
# Required for ECS Cluster monitoring
# -----------------------------------------------------------------------------
/*
data "terraform_remote_state" "sns_topics" {
  backend = "s3"

  config = {
    bucket = "${data.template_file.environment.rendered}-terraform-state"
    key    = "sns_topics/terraform.tfstate"
    region = var.aws_region
  }
}
*/