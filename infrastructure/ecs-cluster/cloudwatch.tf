
# -----------------------------------------------------------------------------
# ECS CLUSTER MONITORING
# -----------------------------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "memory_reservation" {
  alarm_name          = "${data.template_file.environment.rendered}-ECS-cluster-memory-reservation"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.warning_evaluation_period
  metric_name         = "MemoryReservation"
  namespace           = "AWS/ECS"
  period              = var.warning_period
  statistic           = "Average"
  threshold           = var.memory_warning_threshold

  dimensions = {
    ClusterName = aws_ecs_cluster.ecs_cluster.name
  }

  alarm_description         = "Alerts if the memory reservation is above ${var.memory_warning_threshold}% of ECS cluster reserved memory for ${var.warning_evaluation_period * var.warning_period / 60} minutes"
  #alarm_actions             = [data.terraform_remote_state.sns_topics.outputs.ecs_sns_topic_arn]  # Send the a SNS topic which will trigger an alarm
  #ok_actions                = [data.terraform_remote_state.sns_topics.outputs.ecs_sns_topic_arn]
  #insufficient_data_actions = [data.terraform_remote_state.sns_topics.outputs.ecs_sns_topic_arn]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_reservation" {
  alarm_name          = "${data.template_file.environment.rendered}-ECS-cluster-CPU-reservation"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.warning_evaluation_period
  metric_name         = "CPUReservation"
  namespace           = "AWS/ECS"
  period              = var.warning_period
  statistic           = "Average"
  threshold           = var.cpu_warning_threshold

  dimensions = {
    ClusterName = aws_ecs_cluster.ecs_cluster.name
  }

  alarm_description         = "Alerts if the CPU reservation is above ${var.cpu_warning_threshold}% of ECS cluster reserved CPU for ${var.warning_evaluation_period * var.warning_period / 60} minutes"
  #alarm_actions             = [data.terraform_remote_state.sns_topics.outputs.ecs_sns_topic_arn]  # Send the a SNS topic which will trigger an alarm
  #ok_actions                = [data.terraform_remote_state.sns_topics.outputs.ecs_sns_topic_arn]
  #insufficient_data_actions = [data.terraform_remote_state.sns_topics.outputs.ecs_sns_topic_arn]

  lifecycle {
    create_before_destroy = true
  }
}
