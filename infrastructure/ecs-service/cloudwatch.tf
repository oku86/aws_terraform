# -----------------------------------------------------------------------------
# ECS SERVICE MONITORING
# -----------------------------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "memory_utilization_warning" {
  alarm_name          = "${data.template_file.environment.rendered}-${var.service_name}-ECS-service-memory-util-warning"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.warning_evaluation_period
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = var.warning_period
  statistic           = "Average"
  threshold           = var.warning_threshold

  dimensions = {
    ClusterName = data.terraform_remote_state.ecs_cluster.outputs.ecs_cluster_name
    ServiceName = aws_ecs_service.ecs_service.name
  }

  alarm_description = "Alerts if the memory utilization is above ${var.warning_threshold}% of ECS task reserved memory for ${var.warning_evaluation_period * var.warning_period / 60} minutes"
  #alarm_actions             = [data.terraform_remote_state.sns.outputs.alerts_sns_arn]  # Send the a SNS topic which will trigger an alarm
  #ok_actions                = [data.terraform_remote_state.sns.outputs.alerts_sns_arn]
  #insufficient_data_actions = [data.terraform_remote_state.sns.outputs.alerts_sns_arn]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_utilization_critical" {
  alarm_name          = "${data.template_file.environment.rendered}-${var.service_name}-ECS-service-cpu-util-warning"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.critical_evaluation_period
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = var.critical_period
  statistic           = "Average"
  threshold           = "80"

  dimensions = {
    ClusterName = data.terraform_remote_state.ecs_cluster.outputs.ecs_cluster_name
    ServiceName = aws_ecs_service.ecs_service.name
  }

  alarm_description = "Alerts & autoscale ECS service if the CPU utilization is above 80% of ECS task allocation for ${var.critical_evaluation_period * var.critical_period / 60} minutes"
  alarm_actions     = [aws_appautoscaling_policy.ecs_autoscaling_down.arn]    # Scale up
  ok_actions        = [aws_appautoscaling_policy.ecs_autoscaling_up.arn]      # Scale down
  #alarm_actions             = [data.terraform_remote_state.sns.outputs.alerts_sns_arn]  # Send the a SNS topic which will trigger an alarm
  #ok_actions                = [data.terraform_remote_state.sns.outputs.alerts_sns_arn]
  #insufficient_data_actions = [data.terraform_remote_state.sns.outputs.alerts_sns_arn]

  lifecycle {
    create_before_destroy = true
  }
}
