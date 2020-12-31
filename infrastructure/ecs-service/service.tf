# -----------------------------------------------------------------------------
# TARGET GROUP AND LISTENER RULE
# -----------------------------------------------------------------------------

resource "aws_lb_target_group" "service" {
  name                 = "${data.template_file.environment.rendered}-${var.service_name}-${var.external_port}"
  port                 = var.internal_port
  protocol             = "HTTP"
  vpc_id               = data.terraform_remote_state.network.outputs.vpc_id
  deregistration_delay = var.deregistration_delay

  health_check {
    matcher             = var.matcher
    interval            = var.interval
    port                = var.port
    protocol            = "HTTP"
    path                = var.health_check_path
    timeout             = var.timeout
    healthy_threshold   = var.healthy_threshold
    unhealthy_threshold = var.unhealthy_threshold
  }
}

resource "aws_lb_listener_rule" "listener_rule" {
  listener_arn = data.terraform_remote_state.alb.outputs.listener_id_shared
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.service.arn
  }

  condition {
    host_header {
      values = ["www.check.co"]
    }
  }
}

# -----------------------------------------------------------------------------
# ECS SERVICE IAM ROLE
# -----------------------------------------------------------------------------

resource "aws_iam_role" "ecs_task_role" {
  name               = "${data.template_file.environment.rendered}-${var.service_name}-ecs-task"
  assume_role_policy = data.template_file.ecs_task_policy.rendered
}

# -----------------------------------------------------------------------------
# TASK DEFINITION
# -----------------------------------------------------------------------------

resource "aws_ecs_task_definition" "task_definition" {
  family                = var.service_name
  container_definitions = data.template_file.ecs_task_http.rendered
  task_role_arn         = aws_iam_role.ecs_task_role.arn
}

# -----------------------------------------------------------------------------
# ECS SERVICE
# -----------------------------------------------------------------------------

resource "aws_ecs_service" "ecs_service" {
  name    = var.service_name
  cluster = data.terraform_remote_state.ecs_cluster.outputs.ecs_cluster_id

  task_definition                    = aws_ecs_task_definition.task_definition.arn
  desired_count                      = var.desired_count
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  deployment_maximum_percent         = var.deployment_maximum_percent
  health_check_grace_period_seconds  = var.health_check_grace_period_seconds

  load_balancer {
    target_group_arn = aws_lb_target_group.service.arn
    container_name   = var.service_name
    container_port   = var.container_port
  }

  # Preserve desired count when updating an autoscaled ECS Service
  lifecycle {
    ignore_changes = [desired_count]
  }

  tags = {
    Name            = "${data.template_file.environment.rendered}-${var.service_name}"
    ops_terraformed = var.ops_terraformed
    ops_environment = data.template_file.environment.rendered
    ops_service     = var.service_name
  }
}

# -----------------------------------------------------------------------------
# ECS SERVICE AUTOSCALING
# -----------------------------------------------------------------------------

resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 9
  min_capacity       = 3
  resource_id        = "service/${data.terraform_remote_state.ecs_cluster.outputs.ecs_cluster_name}/${var.service_name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# Scale UP if CPU usage > 81%
resource "aws_appautoscaling_policy" "ecs_autoscaling_up" {
  name               = "scale-up"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 300
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 1
      scaling_adjustment          = 1
    }
  }
}

# Scale down if CPU usage < 60%
resource "aws_appautoscaling_policy" "ecs_autoscaling_down" {
  name               = "scale-down"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 300
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_upper_bound = -20
      scaling_adjustment          = -1
    }
  }
}