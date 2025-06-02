locals {
  queue_worker_name = "forms-runner-queue-worker"

  # Take the exported task container definition and override some parts of it
  queue_worker_container_definitions = merge(
    module.ecs_service.task_container_definition,
    {
      name    = local.queue_worker_name,
      command = ["bin/jobs"]

      healthCheck = {
        command     = ["CMD-SHELL", "test -f tmp/solidqueue_healthcheck || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 10
      }

      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = module.ecs_service.application_log_group_name,
          awslogs-region        = "eu-west-2",
          awslogs-stream-prefix = "forms-runner-${var.env_name}-queue-worker"
        }
      },
    }
  )
}

resource "aws_ecs_task_definition" "queue_worker" {
  family                   = "${var.env_name}-${local.queue_worker_name}"
  container_definitions    = jsonencode([local.queue_worker_container_definitions])
  execution_role_arn       = module.ecs_service.task_definition.execution_role_arn
  task_role_arn            = module.ecs_service.task_definition.task_role_arn
  requires_compatibilities = module.ecs_service.task_definition.requires_compatibilities
  cpu                      = module.ecs_service.task_definition.cpu
  memory                   = module.ecs_service.task_definition.memory
  network_mode             = "awsvpc"

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }
}

resource "aws_ecs_service" "queue_worker" {
  #checkov:skip=CKV_AWS_332:We don't want to target "LATEST" and get a surprise when a new version is released.
  #checkov:skip=CKV2_FORMS_AWS_2:The queue worker currently doesn't autoscale, revisit this decision by 23/06/2025
  name          = local.queue_worker_name
  cluster       = var.ecs_cluster_arn
  desired_count = 3

  task_definition                    = aws_ecs_task_definition.queue_worker.arn
  deployment_maximum_percent         = "200"
  deployment_minimum_healthy_percent = "100"

  launch_type      = "FARGATE"
  platform_version = "1.4.0"

  lifecycle {
    prevent_destroy = true # ECS services cannot be destructively replaced without downtime. This helps to avoid accidentally doing so.
  }

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.queue_worker.id]
    assign_public_ip = false
  }
}

resource "aws_security_group" "queue_worker" {
  name        = local.queue_worker_name
  description = "Restrict all ingress, allow egress to VPC, RDS, and internet"
  vpc_id      = var.vpc_id
  egress {
    description = "Permit outbound to VPC CIDR on 443"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  egress {
    description = "Permit outbound to the RDS postgres port 5432"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  egress {
    description = "Permit outbound 443 to the internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}