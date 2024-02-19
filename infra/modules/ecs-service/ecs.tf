data "aws_ecs_cluster" "forms" {
  cluster_name = "forms-${var.env_name}"
}

data "aws_ecs_task_definition" "active_task" {
  task_definition = local.task_definition_family
}

data "aws_ecs_container_definition" "active_container" {
  task_definition = data.aws_ecs_task_definition.active_task.id
  container_name  = var.application
}

data "aws_subnets" "private" {
  filter {
    name = "tag:Name"
    values = [
      "private-a-${var.env_name}",
      "private-b-${var.env_name}",
      "private-c-${var.env_name}"
    ]
  }
}

locals {
  task_definition_family = "${var.env_name}_${var.application}"

  image = coalesce(var.image, data.aws_ecs_container_definition.active_container.image)

  task_container_definition = {
    name        = var.application,
    environment = var.environment_variables,
    secrets     = var.secrets,
    image       = local.image
    essential   = true,
    portMappings = [
      {
        containerPort = var.container_port,
      }
    ],
    logConfiguration = {
      logDriver = "awslogs",
      options = {
        awslogs-group         = "${var.application}-${var.env_name}",
        awslogs-region        = "eu-west-2",
        awslogs-stream-prefix = "${var.application}-${var.env_name}"
      }
    },
  }

  # Extract the values needed for the ECS service network configuration
  # to local variable so we can ensure the same configuration is used
  # for any pre-deploy tasks
  ecs_service_network_configuration = {
    subnets        = data.aws_subnets.private.ids
    securityGroups = [aws_security_group.baseline.id]
    assignPublicIp = false
  }
}
resource "aws_ecs_task_definition" "task" {
  family                = local.task_definition_family
  container_definitions = jsonencode([local.task_container_definition])

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }

  execution_role_arn = aws_iam_role.ecs_task_exec_role.arn
  task_role_arn      = aws_iam_role.ecs_task_role.arn

  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory

  network_mode = "awsvpc"
}

resource "aws_ecs_service" "app_service" {
  #checkov:skip=CKV_AWS_332:We don't want to target "LATEST" and get a surprise when a new version is released.
  name                               = var.application
  cluster                            = data.aws_ecs_cluster.forms.id
  task_definition                    = "${aws_ecs_task_definition.task.family}:${aws_ecs_task_definition.task.revision}"
  deployment_maximum_percent         = "200"
  deployment_minimum_healthy_percent = "100"

  launch_type      = "FARGATE"
  platform_version = "1.4.0"

  load_balancer {
    target_group_arn = aws_lb_target_group.tg.arn
    container_name   = var.application
    container_port   = var.container_port
  }

  lifecycle {
    prevent_destroy = true # ECS services cannot be destructively replaced without downtime. This helps to avoid accidentally doing so.
    ignore_changes  = [desired_count]
  }

  network_configuration {
    subnets          = local.ecs_service_network_configuration.subnets
    security_groups  = local.ecs_service_network_configuration.securityGroups
    assign_public_ip = local.ecs_service_network_configuration.assignPublicIp
  }

  depends_on = [
    null_resource.pre_deploy_script
  ]
}
