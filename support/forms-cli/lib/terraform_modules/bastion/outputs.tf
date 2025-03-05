locals {
  task_network_configuration = {
    awsvpc_configuration = {
      security_groups  = data.aws_security_groups.database_security_groups.ids
      subnets          = data.aws_subnets.private_subnets.ids
      assign_public_ip = "DISABLED"
    }
  }
}

output "task_configuration" {
  value = {
    cluster                = "forms-${var.environment}"
    enable_execute_command = true
    launch_type            = "FARGATE"
    task_definition        = aws_ecs_task_definition.ecs_bastion.arn_without_revision,
    network_configuration  = local.task_network_configuration
  }
}
