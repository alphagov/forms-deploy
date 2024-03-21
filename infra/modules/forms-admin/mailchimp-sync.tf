##
# ECS
##
locals {
  # Take the exported task container definition
  # and override some parts of it, so that it doesn't fall out of sync
  mailchimp_sync_container_definitions = merge(
    module.ecs_service.task_container_definition,
    {
      name    = "forms-admin_mailchimp_sync",
      command = ["rake", "mailchimp:synchronize_audiences"]
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = "forms-admin-${var.env_name}",
          awslogs-region        = "eu-west-2",
          awslogs-stream-prefix = "forms-admin-${var.env_name}-mailchimp-sync"
        }
      },
    }
  )
}
resource "aws_ecs_task_definition" "cron_job" {
  count = var.enable_mailchimp_sync ? 1 : 0

  family                = "${var.env_name}_forms-admin_mailchimp_sync"
  container_definitions = jsonencode([local.mailchimp_sync_container_definitions])

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

##
# EventBridge
##
resource "aws_cloudwatch_event_rule" "sync_cron_job" {
  count = var.enable_mailchimp_sync ? 1 : 0

  description         = "Trigger the forms-admin MailChimp synchronisation on a schedule"
  schedule_expression = "cron(30 10 * * ? *)" # 10:30AM daily. In office hours so that we can respond to failures
}

resource "aws_cloudwatch_event_target" "ecs_sync_job" {
  count = var.enable_mailchimp_sync ? 1 : 0

  arn      = module.ecs_service.cluster_arn
  rule     = aws_cloudwatch_event_rule.sync_cron_job[0].name
  role_arn = aws_iam_role.ecs_cron_scheduler[0].arn

  ecs_target {
    task_definition_arn = aws_ecs_task_definition.cron_job[0].arn
    launch_type         = "FARGATE"
    platform_version    = "1.4.0"

    network_configuration {
      assign_public_ip = false
      security_groups  = module.ecs_service.service.network_configuration[0].security_groups
      subnets          = module.ecs_service.service.network_configuration[0].subnets
    }
  }

  dead_letter_config {
    arn = "arn:aws:sqs:eu-west-2:711966560482:eventbridge-dead-letter-queue"
  }
}

##
# IAM
##
resource "aws_iam_role" "ecs_cron_scheduler" {
  count = var.enable_mailchimp_sync ? 1 : 0

  name = "${var.env_name}-forms-admin-ecs-cron-scheduler"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_events_policy" {
  count = var.enable_mailchimp_sync ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceEventsRole"
  role       = aws_iam_role.ecs_cron_scheduler[0].name
}
