locals {
  # Reached over the internal ALB (alb.tf), not localhost, now that
  # prometheus is its own ECS service - tempo's metrics_generator
  # remote_write and grafana's datasource both use this (ecs.tf).
  prometheus_internal_url = "http://prometheus.internal.${var.root_domain}"

  # Hardcoded rather than module variables - prometheus is lightweight for
  # this POC's traffic volume, and this isn't worth growing the tfvars
  # surface for.
  prometheus_cpu    = 512
  prometheus_memory = 1024
}

resource "aws_ecs_task_definition" "prometheus" {
  #checkov:skip=CKV_AWS_336:Prometheus needs a writable root filesystem for its lock file; the TSDB itself lives on the EFS-backed mount at /prometheus (see volume block below), not the container's ephemeral root fs.
  family = "tempo-${var.env_name}-prometheus"
  container_definitions = jsonencode([
    {
      name      = "prometheus",
      image     = "${aws_ecr_repository.prometheus.repository_url}:${var.image_tag}",
      essential = true,
      # Default CMD plus --web.enable-remote-write-receiver, so it can
      # receive tempo's service-graph/span-metrics remote_write. Everything
      # else (config file, scrape self-check) is upstream's own default -
      # see https://github.com/prometheus/prometheus/blob/main/Dockerfile.
      command = [
        "--config.file=/etc/prometheus/prometheus.yml",
        "--storage.tsdb.path=/prometheus",
        "--web.enable-remote-write-receiver",
      ],
      portMappings = [
        {
          containerPort = 9090,
          hostPort      = 9090,
          protocol      = "tcp",
        }
      ],
      mountPoints = [
        {
          sourceVolume  = "prometheus-data",
          containerPath = "/prometheus",
          readOnly      = false,
        }
      ],
      linuxParameters = {
        initProcessEnabled = true
      },
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = aws_cloudwatch_log_group.prometheus.name,
          awslogs-region        = "eu-west-2",
          awslogs-stream-prefix = "prometheus"
        }
      },
    }
  ])

  volume {
    name = "prometheus-data"

    efs_volume_configuration {
      file_system_id     = aws_efs_file_system.prometheus.id
      transit_encryption = "ENABLED"

      authorization_config {
        access_point_id = aws_efs_access_point.prometheus.id
        iam             = "ENABLED"
      }
    }
  }

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }

  execution_role_arn = aws_iam_role.prometheus_task_exec.arn
  task_role_arn      = aws_iam_role.prometheus_task.arn

  requires_compatibilities = ["FARGATE"]
  cpu                      = local.prometheus_cpu
  memory                   = local.prometheus_memory

  network_mode = "awsvpc"
}

resource "aws_ecs_service" "prometheus" {
  #checkov:skip=CKV_AWS_332:We don't want to target "LATEST" and get a surprise when a new version is released.
  #checkov:skip=CKV2_FORMS_AWS_2:We don't autoscale this service, it's a single-instance POC
  name            = "tempo-${var.env_name}-prometheus"
  cluster         = var.ecs_cluster_arn
  task_definition = aws_ecs_task_definition.prometheus.arn
  desired_count   = 1

  launch_type      = "FARGATE"
  platform_version = "1.4.0"

  # No rolling overlap: two prometheus processes must never hold the same
  # EFS-mounted TSDB directory open concurrently, so the old task must be
  # fully stopped before the replacement starts (true "recreate" semantics,
  # unlike this repo's usual 200/100 rolling-update convention).
  deployment_maximum_percent         = 100
  deployment_minimum_healthy_percent = 0

  # ECS's Availability Zone rebalancing could otherwise start a second task
  # in a different AZ before the first has fully drained, racing on the
  # same EFS mount - explicitly disabled for that reason.
  availability_zone_rebalancing = "DISABLED"

  load_balancer {
    target_group_arn = aws_lb_target_group.prometheus.arn
    container_name   = "prometheus"
    container_port   = 9090
  }

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.prometheus.id]
    assign_public_ip = false
  }
}
