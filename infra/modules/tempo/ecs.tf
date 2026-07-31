data "aws_region" "current" {}

locals {
  # Containers share the task's network namespace (awsvpc), so grafana talks
  # to tempo's query API over localhost without needing a portMapping for it.
  container_definitions = jsonencode([
    {
      name      = "tempo",
      image     = "${aws_ecr_repository.tempo.repository_url}:${var.image_tag}",
      essential = true,
      environment = [
        {
          name  = "TEMPO_S3_BUCKET"
          value = module.trace_storage.name
        },
        {
          name  = "AWS_REGION"
          value = data.aws_region.current.region
        },
        {
          name  = "PROMETHEUS_URL"
          value = local.prometheus_internal_url
        },
      ],
      portMappings = [
        {
          # OTLP HTTP - routed through the internal ALB. ALB only supports
          # HTTP/2 (and therefore gRPC, port 4317) over TLS listeners, so
          # OTLP/HTTP is used here to keep the internal listener plain HTTP,
          # matching every other internal app-to-app route in this repo.
          containerPort = 4318,
          hostPort      = 4318,
          protocol      = "tcp",
        },
        {
          # Tempo's main server (query API, /ready health check). Used by
          # grafana over localhost and by the internal ALB's health check.
          containerPort = 3200,
          hostPort      = 3200,
          protocol      = "tcp",
        }
      ],
      linuxParameters = {
        initProcessEnabled = true
      },
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = aws_cloudwatch_log_group.tempo.name,
          awslogs-region        = "eu-west-2",
          awslogs-stream-prefix = "tempo"
        }
      },
    },
    {
      name      = "grafana",
      image     = "${aws_ecr_repository.grafana.repository_url}:${var.image_tag}",
      essential = true,
      environment = [
        {
          name  = "GF_AUTH_ANONYMOUS_ENABLED"
          value = "false"
        },
        {
          name  = "GF_FEATURE_TOGGLES_ENABLE"
          value = "traceqlEditor"
        },
        {
          # This task has no internet egress (see security-groups.tf) - by
          # default Grafana tries to download a few "Explore" app plugins
          # from grafana.com on startup, which would otherwise just fail
          # repeatedly with a timeout.
          name  = "GF_PLUGINS_PREINSTALL_DISABLED"
          value = "true"
        },
        {
          # Same reason: disables the background job that periodically
          # fetches angular-detection patterns from grafana.com.
          name  = "GF_ANALYTICS_CHECK_FOR_PLUGIN_UPDATES"
          value = "false"
        },
        {
          # Same reason: disables the grafana.com version-check call.
          name  = "GF_ANALYTICS_CHECK_FOR_UPDATES"
          value = "false"
        },
        {
          # Same reason: disables anonymous usage reporting to
          # stats.grafana.org.
          name  = "GF_ANALYTICS_REPORTING_ENABLED"
          value = "false"
        },
        {
          name  = "PROMETHEUS_URL"
          value = local.prometheus_internal_url
        },
      ],
      secrets = [
        {
          name      = "GF_SECURITY_ADMIN_USER"
          valueFrom = local.basic_auth_username_parameter_arn
        },
        {
          name      = "GF_SECURITY_ADMIN_PASSWORD"
          valueFrom = local.basic_auth_password_parameter_arn
        },
      ],
      portMappings = [
        {
          containerPort = 3000,
          hostPort      = 3000,
          protocol      = "tcp",
        }
      ],
      linuxParameters = {
        initProcessEnabled = true
      },
      dependsOn = [
        {
          containerName = "tempo",
          condition     = "START"
        }
      ],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = aws_cloudwatch_log_group.grafana.name,
          awslogs-region        = "eu-west-2",
          awslogs-stream-prefix = "grafana"
        }
      },
    }
  ])
}

resource "aws_ecs_task_definition" "tempo" {
  #checkov:skip=CKV_AWS_336:Both containers need a writable root filesystem (tempo's WAL, gomplate's rendered config); not worth the added complexity of ephemeral volume mounts for a POC.
  family                = "tempo-${var.env_name}"
  container_definitions = local.container_definitions

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }

  execution_role_arn = aws_iam_role.tempo_task_exec.arn
  task_role_arn      = aws_iam_role.tempo_task.arn

  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory

  network_mode = "awsvpc"
}

resource "aws_ecs_service" "tempo" {
  #checkov:skip=CKV_AWS_332:We don't want to target "LATEST" and get a surprise when a new version is released.
  #checkov:skip=CKV2_FORMS_AWS_2:We don't autoscale this service, it's a single-instance POC
  name            = "tempo-${var.env_name}"
  cluster         = var.ecs_cluster_arn
  task_definition = aws_ecs_task_definition.tempo.arn
  desired_count   = 1

  launch_type      = "FARGATE"
  platform_version = "1.4.0"

  load_balancer {
    target_group_arn = aws_lb_target_group.grafana.arn
    container_name   = "grafana"
    container_port   = 3000
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.tempo_otlp.arn
    container_name   = "tempo"
    container_port   = 4318
  }

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.tempo.id]
    assign_public_ip = false
  }
}
