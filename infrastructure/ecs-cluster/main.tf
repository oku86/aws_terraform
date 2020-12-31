# -----------------------------------------------------------------------------
# CREATE IAM ROLE AND ATTACH REQUIRED BASE PERMISSIONS
# -----------------------------------------------------------------------------

resource "aws_iam_role" "ecs_instance_role" {
  name               = "${data.template_file.environment.rendered}-ecs-instances"
  assume_role_policy = data.template_file.ecs_instance_policy.rendered
}

# -----------------------------------------------------------------------------
# ECS CLUSTER-LEVEL PERMISSIONS
# -----------------------------------------------------------------------------

resource "aws_iam_policy" "ecs_cluster_policy" {
  name        = "${data.template_file.environment.rendered}-ecs-cluster-policy"
  path        = "/${data.template_file.environment.rendered}/"
  description = "Permissions for ECS instances "

  policy = data.template_file.ecs_policy.rendered
}

resource "aws_iam_role_policy_attachment" "ecs_policy" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = aws_iam_policy.ecs_cluster_policy.arn
}

# -----------------------------------------------------------------------------
# CREATE THE SECURITY GROUP THAT CONTROLS WHAT TRAFFIC CAN GO IN AND OUT OF THE ECS CLUSTER
# -----------------------------------------------------------------------------

resource "aws_security_group" "ecs_access" {
  name        = "${data.template_file.environment.rendered}-ecs-instances"
  description = "Security group for ${data.template_file.environment.rendered} ECS cluster instances"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id

  tags = {
    Name              = "${data.template_file.environment.rendered}-ecs-instances"
    ops_terraformed   = var.ops_terraformed
    ops_environment   = data.template_file.environment.rendered
  }
}

resource "aws_security_group_rule" "allow_all_outbound" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.ecs_access.id
}

# Allow access from ALB security group
resource "aws_security_group_rule" "allow_inbound_alb_shared" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "all"
  source_security_group_id = data.terraform_remote_state.alb.outputs.alb_security_group_id
  description              = "Allows access from the Shared ALB"

  security_group_id = aws_security_group.ecs_access.id
}

# -----------------------------------------------------------------------------
# CREATE THE ASG FOR THE ECS CLUSTER INSTANCES
# -----------------------------------------------------------------------------

# Instance profile that provides IAM permissions to the instances in the ASG
resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "${data.template_file.environment.rendered}-ecs-instances"
  role = aws_iam_role.ecs_instance_role.name
}

# Launch configuration for the instance
resource "aws_launch_configuration" "launch_configuration" {
  name_prefix          = "${data.template_file.environment.rendered}-ecs-instances"
  instance_type        = var.instance_type
  image_id             = data.aws_ami.latest_ecs_ami.id
  security_groups      = [aws_security_group.ecs_access.id]
  user_data            = data.template_file.user_data.rendered
  iam_instance_profile = aws_iam_instance_profile.ecs_instance_profile.name

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = var.root_volume_type
  }

  ebs_block_device {
    device_name = var.ebs_device_name
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Autoscaling group for the the instance
resource "aws_autoscaling_group" "autoscaling_group" {
  name                 = "${data.template_file.environment.rendered}-ecs-cluster-01"
  vpc_zone_identifier  = tolist(data.terraform_remote_state.network.outputs.private_subnets)
  min_size             = var.asg_min_size
  max_size             = var.asg_max_size
  desired_capacity     = var.desired_count
  launch_configuration = aws_launch_configuration.launch_configuration.name
  health_check_type    = "EC2"
  termination_policies = ["OldestInstance"]

  tag {
    key                 = "Name"
    value               = "${data.template_file.environment.rendered}-ecs-cluster-01"
    propagate_at_launch = "true"
  }

  tag {
    key                 = "ops_terraformed"
    value               = var.ops_terraformed
    propagate_at_launch = "true"
  }

  tag {
    key                 = "ops_environment"
    value               = data.template_file.environment.rendered
    propagate_at_launch = "true"
  }
}

# Attach ASG to ALB target group
resource "aws_autoscaling_attachment" "target_group_shared" {
  autoscaling_group_name = aws_autoscaling_group.autoscaling_group.name
  alb_target_group_arn   = data.terraform_remote_state.alb.outputs.target_group_arn_shared
}

# -----------------------------------------------------------------------------
# CREATE THE ECS CLUSTER
# -----------------------------------------------------------------------------

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${data.template_file.environment.rendered}-cluster-01"

  tags = {
    Name              = "${data.template_file.environment.rendered}-cluster-01"
    ops_terraformed   = var.ops_terraformed
    ops_environment   = data.template_file.environment.rendered
  }
}
