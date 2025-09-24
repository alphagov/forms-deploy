output "service" {
  value = aws_ecs_service.app_service
}
output "task_definition" {
  value = aws_ecs_task_definition.task
}

output "task_container_definition" {
  value = local.task_container_definition
}

output "task_role_arn" {
  value = aws_iam_role.ecs_task_role.arn
}

output "application_log_group_name" {
  value = aws_cloudwatch_log_group.log.name
}

output "task_definition_family" {
  value = aws_ecs_task_definition.task.family
}

output "target_group_arn" {
  value = aws_lb_target_group.tg.arn
}
