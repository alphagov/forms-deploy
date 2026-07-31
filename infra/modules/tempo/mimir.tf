locals {
  # Reached over the internal ALB (alb.tf), not localhost, since mimir is
  # its own ECS service - tempo's metrics_generator remote_write and
  # grafana's datasource both use this (ecs.tf).
  mimir_internal_url = "http://mimir.internal.${var.root_domain}"

  # Hardcoded rather than module variables - mimir is lightweight for this
  # POC's traffic volume, and this isn't worth growing the tfvars surface
  # for.
  mimir_cpu    = 512
  mimir_memory = 1024

  # Templated into mimir.yaml.tmpl as an env var (docker/mimir/Dockerfile)
  # rather than a static value in the config, so it can be changed with a
  # plain terraform apply instead of an image rebuild/push.
  mimir_log_level = "warn"
}

resource "aws_ecs_task_definition" "mimir" {
  #checkov:skip=CKV_AWS_336:Mimir needs a writable root filesystem for its local WAL/TSDB blocks before they're flushed to S3 (see docker/mimir/mimir.yaml.tmpl) - there is deliberately no persistent volume here, durability comes from S3 once flushed.
  family = "tempo-${var.env_name}-mimir"
  container_definitions = jsonencode([
    {
      name      = "mimir",
      image     = "${aws_ecr_repository.mimir.repository_url}:${var.image_tag}",
      essential = true,
      environment = [
        {
          name  = "MIMIR_S3_BUCKET"
          value = module.mimir_storage.name
        },
        {
          name  = "AWS_REGION"
          value = data.aws_region.current.region
        },
        {
          name  = "MIMIR_LOG_LEVEL"
          value = local.mimir_log_level
        },
      ],
      portMappings = [
        {
          containerPort = 9009,
          hostPort      = 9009,
          protocol      = "tcp",
        }
      ],
      linuxParameters = {
        initProcessEnabled = true
      },
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = aws_cloudwatch_log_group.mimir.name,
          awslogs-region        = "eu-west-2",
          awslogs-stream-prefix = "mimir"
        }
      },
    }
  ])

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }

  execution_role_arn = aws_iam_role.mimir_task_exec.arn
  task_role_arn      = aws_iam_role.mimir_task.arn

  requires_compatibilities = ["FARGATE"]
  cpu                      = local.mimir_cpu
  memory                   = local.mimir_memory

  network_mode = "awsvpc"
}

resource "aws_ecs_service" "mimir" {
  #checkov:skip=CKV_AWS_332:We don't want to target "LATEST" and get a surprise when a new version is released.
  #checkov:skip=CKV2_FORMS_AWS_2:We don't autoscale this service, it's a single-instance POC
  name            = "tempo-${var.env_name}-mimir"
  cluster         = var.ecs_cluster_arn
  task_definition = aws_ecs_task_definition.mimir.arn
  desired_count   = 1

  launch_type      = "FARGATE"
  platform_version = "1.4.0"

  load_balancer {
    target_group_arn = aws_lb_target_group.mimir.arn
    container_name   = "mimir"
    container_port   = 9009
  }

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.mimir.id]
    assign_public_ip = false
  }
}
