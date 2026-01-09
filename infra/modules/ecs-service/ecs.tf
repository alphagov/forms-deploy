data "aws_ecs_task_definition" "active_task" {
  count           = var.image == null ? 1 : 0
  task_definition = local.task_definition_family
}

data "aws_ecs_container_definition" "active_container" {
  count           = var.image == null ? 1 : 0
  task_definition = data.aws_ecs_task_definition.active_task[0].id
  container_name  = var.application
}

locals {
  log_group_name         = "/aws/ecs/${var.application}-${var.env_name}"
  adot_log_group_name    = "/aws/ecs/${var.application}-${var.env_name}/adot-collector"
  task_definition_family = "${var.env_name}_${var.application}"

  image = var.image == null ? data.aws_ecs_container_definition.active_container[0].image : var.image

  task_container_definition = {
    name = var.application,
    environment = var.enable_adot_sidecar ? concat(var.environment_variables, [
      {
        name  = "ENABLE_OTEL"
        value = "true"
      },
      {
        name  = "OTEL_EXPORTER_OTLP_ENDPOINT"
        value = "http://localhost:4318"
      },
      {
        name  = "OTEL_SERVICE_NAME"
        value = var.application
      },
      {
        name  = "OTEL_PROPAGATORS"
        value = "xray"
      }
    ]) : var.environment_variables,
    mountPoints            = [],
    secrets                = var.secrets,
    image                  = local.image
    essential              = true,
    readonlyRootFilesystem = var.readonly_root_filesystem
    command                = null,
    cpu                    = null,
    memory                 = null,
    portMappings = [
      {
        hostPort      = var.container_port,
        protocol      = "tcp",
        containerPort = var.container_port,
      }
    ],
    systemControls = [],
    volumesFrom    = [],
    logConfiguration = {
      logDriver = "awslogs",
      options = {
        awslogs-group         = local.log_group_name,
        awslogs-region        = "eu-west-2",
        awslogs-stream-prefix = local.log_group_name
      }
    },
    healthCheck = null,
    dependsOn = var.enable_adot_sidecar ? [
      {
        containerName = "aws-otel-collector",
        condition     = "START"
      }
    ] : []
  }

  # ADOT collector sidecar container
  adot_container_definition = {
    name                   = "aws-otel-collector",
    image                  = var.adot_image,
    essential              = true,
    readonlyRootFilesystem = false,
    command = [
      "--config=${var.adot_collector_config}"
    ],
    cpu    = var.adot_sidecar_cpu,
    memory = var.adot_sidecar_memory,
    logConfiguration = {
      logDriver = "awslogs",
      options = {
        awslogs-group         = local.adot_log_group_name,
        awslogs-region        = "eu-west-2",
        awslogs-stream-prefix = "adot"
      }
    },
    healthCheck = {
      command = [
        "CMD",
        "/healthcheck"
      ],
      interval    = 5,
      timeout     = 6,
      retries     = 5,
      startPeriod = 1
    },
  }

  # Conditional container array composition
  container_definitions = var.enable_adot_sidecar ? jsonencode([
    local.task_container_definition,
    local.adot_container_definition
    ]) : jsonencode([
    local.task_container_definition
  ])

  # Extract the values needed for the ECS service network configuration
  # to local variable so we can ensure the same configuration is used
  # for any pre-deploy tasks
  ecs_service_network_configuration = {
    subnets        = var.private_subnet_ids
    securityGroups = [aws_security_group.baseline.id]
    assignPublicIp = false
  }
}
resource "aws_ecs_task_definition" "task" {
  family                = local.task_definition_family
  container_definitions = local.container_definitions

  // As this terraform module doesn't deal with updating app code, we see drift every time it's applied because the image is changed elsewhere.
  // Enable tracking of the latest ACTIVE task definition revision rather than the one in terraform state, so that changes to the image / task revision outside of terraform are picked up and not considered drift.
  // This is only necessary when terraform itself is not the source of truth for the task definition image.
  // See: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition#track_latest-1
  track_latest = true

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }

  execution_role_arn = aws_iam_role.ecs_task_exec_role.arn
  task_role_arn      = aws_iam_role.ecs_task_role.arn

  requires_compatibilities = ["FARGATE"]
  # When ADOT sidecar is enabled, round up to next valid Fargate CPU/memory configuration
  # Valid Fargate configs: 256/.5-2GB, 512/1-4GB, 1024/2-8GB, 2048/4-16GB, 4096/8-30GB
  # For forms-runner: 512 CPU + 1024 MB + ADOT (256 CPU + 512 MB) = needs 1024 CPU / 2048 MB minimum
  cpu    = var.enable_adot_sidecar ? (var.cpu + var.adot_sidecar_cpu <= 512 ? 512 : 1024) : var.cpu
  memory = var.enable_adot_sidecar ? (var.memory + var.adot_sidecar_memory <= 1024 ? 1024 : 2048) : var.memory

  network_mode = "awsvpc"

  enable_fault_injection = false
}

resource "aws_ecs_service" "app_service" {
  #checkov:skip=CKV_AWS_332:We don't want to target "LATEST" and get a surprise when a new version is released.
  name                               = var.application
  cluster                            = var.ecs_cluster_arn
  task_definition                    = aws_ecs_task_definition.task.arn
  deployment_maximum_percent         = "200"
  deployment_minimum_healthy_percent = "100"

  launch_type      = "FARGATE"
  platform_version = "1.4.0"

  load_balancer {
    target_group_arn = aws_lb_target_group.tg.arn
    container_name   = var.application
    container_port   = var.container_port
  }

  dynamic "load_balancer" {
    for_each = var.internal_sub_domain != null ? [1] : []
    content {
      target_group_arn = aws_lb_target_group.internal_tg[0].arn
      container_name   = var.application
      container_port   = var.container_port
    }
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
