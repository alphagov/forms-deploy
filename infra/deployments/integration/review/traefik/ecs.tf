locals {
  http_port = 80
  api_port  = 8080
}

resource "aws_ecs_task_definition" "traefik" {
  family = "traefik"
  container_definitions = jsonencode([
    {
      name = "traefik",
      command = [
        "--log.level=INFO",
        "--ping",
        "--ping.entrypoint=http",
      ]

      environment = [],
      image       = "public.ecr.aws/docker/library/traefik:3.3.2"
      essential   = true,
      portMappings = [
        {
          containerPort = local.http_port,
        },
        {
          containerPort = local.api_port
        }
      ],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = aws_cloudwatch_log_group.log.name,
          awslogs-region        = "eu-west-2",
          awslogs-stream-prefix = aws_cloudwatch_log_group.log.name
        }
      },
    }

  ])

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }

  execution_role_arn = aws_iam_role.ecs_execution.arn
  task_role_arn      = aws_iam_role.ecs_task.arn

  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512

  network_mode = "awsvpc"
}

resource "aws_ecs_service" "traefik" {
  #checkov:skip=CKV_AWS_332:We don't want to target "LATEST" and get a surprise when a new version is released.
  name                               = "traefik"
  cluster                            = var.ecs_cluster_arn
  task_definition                    = aws_ecs_task_definition.traefik.arn
  deployment_maximum_percent         = "200"
  deployment_minimum_healthy_percent = "100"

  desired_count = 1

  launch_type      = "FARGATE"
  platform_version = "1.4.0"

  load_balancer {
    target_group_arn = aws_lb_target_group.tg.arn
    container_name   = "traefik"
    container_port   = local.http_port
  }

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [aws_security_group.traefik.id]
    assign_public_ip = false
  }
}

resource "aws_cloudwatch_log_group" "log" {
  #checkov:skip=CKV_AWS_338:We're happy with 30 days retention for now
  #checkov:skip=CKV_AWS_158:Default AWS SSE is sufficient, no need for CM KMS.
  name              = "review-traefik"
  retention_in_days = 30
}
