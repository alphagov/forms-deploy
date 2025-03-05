locals {
  task_definition_name = "${var.environment}_bastion"
}

resource "aws_ecs_task_definition" "ecs_bastion" {
  family = local.task_definition_name

  container_definitions = jsonencode([{
    name      = "bastion",
    image     = var.container_image,
    cpu       = 0,
    essential = true,
    command   = ["sleep", "3600"],
    linuxParameters = {
      initProcessEnabled = true,
    },
    secrets = [
      for database, ssm_parameter in data.aws_ssm_parameter.database_url_secrets :
      {
        name      = "${replace(upper(database), "-", "_")}__DATABASE_URL"
        valueFrom = ssm_parameter.arn
      }
    ]
  }])

  execution_role_arn = aws_iam_role.ecs_bastion_task_exec_role.arn
  task_role_arn      = aws_iam_role.ecs_bastion_task_role.arn

  network_mode = "awsvpc"

  cpu    = 1024
  memory = 3072

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }
}
