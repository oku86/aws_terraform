
variable "aws_region" {
  description = "AWS Region where the resources will be created"
  default     = "eu-west-1"
}

variable "internal" {
  description = "If set to true, this will be an internal LB, accessible only within the VPC. The main reason to use an LB with Vault is to make it publicly accessible, so this should typically be set to false."
  default     = false
}

variable "ops_terraformed" {
  description = "Indication of the resource being created via terraform. Must be true for all resources created through modules"
  default     = true
}

variable "ssl_policy" {
  description = "SSL policy for HTTPS connection"
  default     = "ELBSecurityPolicy-TLS-1-2-2017-01"
}
