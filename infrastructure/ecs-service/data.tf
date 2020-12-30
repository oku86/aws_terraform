# -----------------------------------------------------------------------------
# AWS PROVIDER AND REMOTE STATE
# -----------------------------------------------------------------------------

provider "aws" {
  region = var.aws_region
}

terraform {
  backend "s3" {
    bucket  = "check-terraform-state"
    key     = "ecs-service/terraform.tfstate"
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
# DATA SOURCES FOR ORHESTRA ECS CLUSTER
# -----------------------------------------------------------------------------

data "terraform_remote_state" "ecs_cluster" {
  backend = "s3"

  config = {
    bucket = "check-terraform-state"
    key    = "ecs-cluster/terraform.tfstate"
    region = var.aws_region
  }
}


# -----------------------------------------------------------------------------
# DATA SOURCES FOR NETWORK RESOURCES
# -----------------------------------------------------------------------------

data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket = "check-terraform-state"
    key    = "infrastructure/network/terraform.tfstate"
    region = var.aws_region
  }
}

# -----------------------------------------------------------------------------
# DATA SOURCES FOR ALBs
# -----------------------------------------------------------------------------

data "terraform_remote_state" "alb" {
  backend = "s3"

  config = {
    bucket = "check-terraform-state"
    key    = "alb/terraform.tfstate"
    region = var.aws_region
  }
}

# -----------------------------------------------------------------------------
# ECS task policy
# -----------------------------------------------------------------------------

data "template_file" "ecs_task_policy" {
  template = file("templates/assume-role-policy")

  vars = {
    service_name = "ecs-tasks"
  }
}

# -----------------------------------------------------------------------------
# ECS TASKS
# -----------------------------------------------------------------------------

data "template_file" "ecs_task_http" {
  template = file("templates/ecs-task-http")

  vars = {
    host_port       = var.host_port
    container_port  = var.container_port
    ops_environment = data.template_file.environment.rendered
    ops_service     = var.service_name
    aws_account     = var.aws_account
    ecr_repo        = var.ecr_repo
    container_name  = "http"

  }
}

# -----------------------------------------------------------------------------
# GET SNS DATA SOURCE FOR SNS TOPICS
# Required for ECS service monitoring
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