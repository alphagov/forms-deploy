output "cluster_arn" {
  value = data.aws_ecs_cluster.forms.arn
}

output "service" {
  value = aws_ecs_service.app_service
}
output "task_definition" {
  value = aws_ecs_task_definition.task
}

output "task_container_definition" {
  value = local.task_container_definition
}
