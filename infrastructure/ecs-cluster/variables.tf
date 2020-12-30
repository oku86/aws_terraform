
variable "aws_region" {
  description = "AWS Region where the resources will be created"
  default     = "eu-west-1"
}

variable "ops_terraformed" {
  description = "Indication of the resource being created via terraform. Must be true for all resources created through modules"
  default     = true
}

variable "instance_type" {
  description = "ECS instances type. Default to small instance"
  #default     = "t2.micro"
  default     = "m5.large"
}

variable "root_volume_size" {
  description = "The Size of the Docker EBS volume to be used in the ASG group"
  default     = 50
}

variable "root_volume_type" {
  description = "The Type of the Root EBS volume to be used in the ASG group"
  default     = "gp2"
}

variable "ebs_volume_size" {
  description = "The Size of the Docker EBS volume to be used in the ASG group"
  #default     = 20
  default     = 100
}

variable "ebs_volume_type" {
  description = "The Type of the Docker EBS volume to be used in the ASG group"
  default     = "gp2"
}

# Name of the device used by docker-storage-setup to create the volumes used by docker
variable "ebs_device_name" {
  description = "The name of the Docker device to mount"
  default     = "/dev/xvdcz"
}

variable "asg_min_size" {
  description = "ASG min number of instances to be running."
  default     = 1
}

variable "asg_max_size" {
  description = "ASG max number of instances to be running."
  default     = 5
}

variable "desired_count" {
  description = "Default number of instances and tasks within the services that must be running. This keeps the management services that needs to be running in all instances with the correct number of tasks"
  #default     = 1
  default     = 3
}

variable "warning_evaluation_period" {
  description = "Reservation warning evaluation period."
  default     = 6
}

variable "warning_period" {
  description = "Reservation warning period."
  default     = 600
}

variable "memory_warning_threshold" {
  description = "Memory reservation warning threshold."
  default     = 80
}

variable "cpu_warning_threshold" {
  description = "CPU reservation warning threshold."
  default     = 80
}

