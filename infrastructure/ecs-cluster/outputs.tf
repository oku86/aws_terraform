output "ecs_cluster_id" {
  value = aws_ecs_cluster.ecs_cluster.id
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.ecs_cluster.name
}

output "asg_name" {
  value = aws_autoscaling_group.autoscaling_group.name
}

output "ecs_instance_role_name" {
  value = aws_iam_instance_profile.ecs_instance_profile.name
}

output "ecs_security_group_id" {
  value = aws_security_group.ecs_access.id
}