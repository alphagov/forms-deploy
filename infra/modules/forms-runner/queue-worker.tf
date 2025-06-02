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
      }

      secrets = [
        {
          name      = "SETTINGS__FORMS_API__AUTH_KEY",
          valueFrom = "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/forms-runner-${var.env_name}/forms-api-key"
        },
        {
          name      = "SETTINGS__SENTRY__DSN",
          valueFrom = "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/forms-runner-queue-worker-${var.env_name}/sentry/dsn"
        },
        {
          name      = "SECRET_KEY_BASE",
          valueFrom = "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/forms-runner-${var.env_name}/secret-key-base"
        },
        {
          name      = "DATABASE_URL",
          valueFrom = "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/forms-runner-${var.env_name}/database/url"
        },
        {
          name      = "QUEUE_DATABASE_URL",
          valueFrom = "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/forms-runner-queue-${var.env_name}/database/url"
        }
      ]
    }
  )
}

resource "aws_ecs_task_definition" "queue_worker" {
  family                   = "${var.env_name}-${local.queue_worker_name}"
  container_definitions    = jsonencode([local.queue_worker_container_definitions])
  execution_role_arn       = aws_iam_role.ecs_task_exec_role.arn
  task_role_arn            = module.ecs_service.task_role_arn
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

resource "aws_iam_role" "ecs_task_role" {
  name               = "${var.env_name}-${local.queue_worker_name}-ecs-task"
  description        = "Used by ${local.queue_worker_name} tasks when running"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_role_assume_role.json
}

data "aws_iam_policy_document" "ecs_task_role_assume_role" {
  statement {
    sid     = "AllowECS"
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "ecs_task_policy" {
  name   = "${var.env_name}-${local.queue_worker_name}-ecs-task-policy"
  policy = data.aws_iam_policy_document.ecs_task_policy.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_role_policy_attachment" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_task_policy.arn
}

data "aws_iam_policy_document" "ecs_task_policy" {
  statement {
    actions = [
      "cloudwatch:PutMetricData"
    ]
    resources = ["*"]
    effect    = "Allow"
    condition {
      test     = "StringLike"
      variable = "cloudwatch:namespace"

      values = [
        "Forms*"
      ]
    }
  }
}

resource "aws_iam_role" "ecs_task_exec_role" {
  name               = "${var.env_name}-${local.queue_worker_name}-ecs-task-exec"
  description        = "Used by ECS to create ${local.queue_worker_name} task"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_exec_role_assume_role.json
}

data "aws_iam_policy_document" "ecs_task_exec_role_assume_role" {
  statement {
    sid     = "AllowECS"
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_exec_standard_policy" {
  role       = aws_iam_role.ecs_task_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_policy" "ecs_task_exec_additional_policy" {
  name   = "${var.env_name}-${local.queue_worker_name}-ecs-task-additional-policies"
  policy = data.aws_iam_policy_document.queue_worker_ecs_task_exec_additional_policy.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_exec_additional_policy" {
  role       = aws_iam_role.ecs_task_exec_role.name
  policy_arn = aws_iam_policy.ecs_task_exec_additional_policy.arn
}

data "aws_iam_policy_document" "queue_worker_ecs_task_exec_additional_policy" {
  statement {
    actions = [
      "ssm:DescribeParameters"
    ]
    resources = ["*"]
    effect    = "Allow"
  }
  statement {
    actions = [
      "ssm:GetParameters"
    ]
    resources = [
      "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/${local.queue_worker_name}-${var.env_name}/sentry/dsn",
      "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/forms-runner-${var.env_name}/secret-key-base",
      "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/forms-runner-${var.env_name}/database/url",
      "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/forms-runner-queue-${var.env_name}/database/url"
    ]
    effect = "Allow"
  }
}