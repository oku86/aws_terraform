
variable "aws_region" {
  description = "AWS Region where the resources will be created"
  default     = "eu-west-1"
}

variable "service_name" {
  description = "ECS service name"
  default     = "check-co"
}

variable "ecr_repo" {
  default = "check_co"
}

variable "aws_account" {
  description = "AWS account number - used to reference the ECR repository ARN"
  default     = "464347167474"
}

variable "ops_terraformed" {
  description = "Indication of the resource being created via terraform. Must be true for all resources created through modules"
  default     = true
}

variable "internal_port" {
  description = "Port the service will be listening on. To be used to allow access from LBs in the ECS instances"
  default     = 80
  #default     = 443
}

variable "matcher" {
  description = "(Only supported on Application Load Balancers): The HTTP codes to use when checking for a successful response from a target. You can specify multiple values (for example, \"200,202\") or a range of values (for example, \"200-299\")."
  default     = 200
}

variable "interval" {
  description = "The approximate amount of time, in seconds, between health checks of an individual target. Minimum value 5 seconds, Maximum value 300 seconds."
  default     = 5
}

variable "timeout" {
  description = "The amount of time, in seconds, during which no response means a failed health check. For Application Load Balancers, the range is 2 to 60 seconds and the default is 5 seconds. For Network Load Balancers, you cannot set a custom value, and the default is 10 seconds for TCP and HTTPS health checks and 6 seconds for HTTP health checks."
  default     = 2
}

variable "healthy_threshold" {
  description = "The number of consecutive health checks successes required before considering an unhealthy target healthy."
  default     = 2
}

variable "unhealthy_threshold" {
  description = "The number of consecutive health check failures required before considering the target unhealthy."
  default     = 5
}

variable "port" {
  description = "The port to use to connect with the target. Valid values are either ports 1-65536, or traffic-port."
  default     = "traffic-port"
}

variable "health_check_path" {
  description = "URL path to be used by the health check of the target group"
  default     = "/"
}


variable "deregistration_delay" {
  description = "The amount time for Elastic Load Balancing to wait before changing the state of a deregistering target from draining to unused. The range is 0-3600 seconds. The default value is 300 seconds."
  default     = 30
}

variable "external_port" {
  description = "External port the LB will listen on. Can, and sometimes will, be different from the internal one."
  default     = 80
  #default     = 443
}

variable "ssl_policy" {
  description = "SSL policy for HTTPS connection"
  default     = "ELBSecurityPolicy-TLS-1-2-2017-01"
}

variable "desired_count" {
  description = "Default number of instances and tasks within the services that must be running. This keeps the management services that needs to be running in all instances with the correct number of tasks"
  default     = 3
}

variable "deployment_minimum_healthy_percent" {
  description = "The lower limit (as a percentage of the service's desiredCount) of the number of running tasks that must remain running and healthy in a service during a deployment."
  default     = 100
}

variable "deployment_maximum_percent" {
  description = "The upper limit (as a percentage of the service's desiredCount) of the number of running tasks that can be running in a service during a deployment. Not valid when using the DAEMON scheduling strategy."
  default     = 200
}

variable "health_check_grace_period_seconds" {
  description = "Seconds to ignore failing load balancer health checks on newly instantiated tasks to prevent premature shutdown, up to 1800"
  default     = 10
}

variable "container_port" {
  description = "The port of the main container run by the service"
  default     = 80
}

variable "host_port" {
  description = "The host port"
  default     = 0
}

variable "warning_threshold" {
  description = "Memory utilization warning threshold."
  default     = 130
}

variable "warning_period" {
  description = "Memory utilization warning period."
  default     = 300
}

variable "warning_evaluation_period" {
  description = "Memory utilization warning evaluation period."
  default     = 3
}

variable "critical_evaluation_period" {
  description = "Memory utilization critical evaluation period."
  default     = 2
}

variable "critical_threshold" {
  description = "Memory utilization critical threshold."
  default     = 150
}

variable "critical_period" {
  description = "Memory utilization critical period."
  default     = 300
}
