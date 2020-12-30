variable "aws_region" {
  description = "AWS Region where the resources will be created"
  default     = "eu-west-1"
}

variable "ops_terraformed" {
  description = "Indication of the resource being created via terraform. Must be true for all resources created through modules"
  default     = true
}