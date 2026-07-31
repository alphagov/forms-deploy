locals {
  # Reached over the internal ALB (alb.tf), not localhost, since alloy is
  # its own ECS service - forms-admin/forms-runner's OTEL_EXPORTER_OTLP_ENDPOINT
  # points here instead of tempo directly (see dev.tfvars).
  alloy_otlp_url = "http://alloy-otlp.internal.${var.root_domain}"

  # Alloy's own upstream target - the same tempo-otlp.internal hostname
  # apps used to send traces to directly before alloy sat in front of it.
  tempo_otlp_url = "http://tempo-otlp.internal.${var.root_domain}"

  # Hardcoded rather than module variables - alloy is a lightweight
  # passthrough proxy for this POC's traffic volume, and this isn't worth
  # growing the tfvars surface for.
  alloy_cpu    = 256
  alloy_memory = 512
}

resource "aws_ecs_task_definition" "alloy" {
  #checkov:skip=CKV_AWS_336:Alloy needs a writable root filesystem for its remote_write WAL (/var/lib/alloy, pre-owned by the image's non-root user - see Dockerfile); it's ephemeral container storage, acceptable for this self-metrics stream the same way it is for mimir's own data.
  family = "tempo-${var.env_name}-alloy"
  container_definitions = jsonencode([
    {
      name      = "alloy",
      image     = "${aws_ecr_repository.alloy.repository_url}:${var.image_tag}",
      essential = true,
      environment = [
        {
          name  = "TEMPO_OTLP_ENDPOINT"
          value = local.tempo_otlp_url
        },
        {
          name  = "MIMIR_URL"
          value = local.mimir_internal_url
        },
        {
          name  = "MIMIR_HOST"
          value = "mimir.internal.${var.root_domain}"
        },
      ],
      portMappings = [
        {
          containerPort = 4318,
          hostPort      = 4318,
          protocol      = "tcp",
        },
        {
          # Alloy's own UI/API server - used for the ALB health check and
          # for alloy scraping its own /metrics (see config.alloy).
          containerPort = 12345,
          hostPort      = 12345,
          protocol      = "tcp",
        }
      ],
      linuxParameters = {
        initProcessEnabled = true
      },
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = aws_cloudwatch_log_group.alloy.name,
          awslogs-region        = "eu-west-2",
          awslogs-stream-prefix = "alloy"
        }
      },
    }
  ])

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }

  execution_role_arn = aws_iam_role.alloy_task_exec.arn
  task_role_arn      = aws_iam_role.alloy_task.arn

  requires_compatibilities = ["FARGATE"]
  cpu                      = local.alloy_cpu
  memory                   = local.alloy_memory

  network_mode = "awsvpc"
}

resource "aws_ecs_service" "alloy" {
  #checkov:skip=CKV_AWS_332:We don't want to target "LATEST" and get a surprise when a new version is released.
  #checkov:skip=CKV2_FORMS_AWS_2:We don't autoscale this service, it's a single-instance POC
  name            = "tempo-${var.env_name}-alloy"
  cluster         = var.ecs_cluster_arn
  task_definition = aws_ecs_task_definition.alloy.arn
  desired_count   = 1

  launch_type      = "FARGATE"
  platform_version = "1.4.0"

  # Normal rolling deployment - alloy has nothing stateful worth protecting
  # (its remote_write WAL is a short-lived buffer, not authoritative data).
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100

  load_balancer {
    target_group_arn = aws_lb_target_group.alloy.arn
    container_name   = "alloy"
    container_port   = 4318
  }

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.alloy.id]
    assign_public_ip = false
  }
}
