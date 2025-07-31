##
# ECS
##
locals {
  # Take the exported task container definition
  # and override some parts of it, so that it doesn't fall out of sync
  organisations_sync_container_definitions = merge(
    module.ecs_service.task_container_definition,
    {
      name    = "forms-admin_organisations_sync",
      command = ["rake", "organisations:fetch"]
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = module.ecs_service.application_log_group_name,
          awslogs-region        = "eu-west-2",
          awslogs-stream-prefix = "forms-admin-${var.env_name}-organisations-sync"
        }
      },
    }
  )
}

resource "aws_ecs_task_definition" "orgs_cron_job" {
  count = var.enable_organisations_sync ? 1 : 0

  family                = "${var.env_name}_forms-admin_organisations_sync"
  container_definitions = jsonencode([local.organisations_sync_container_definitions])

  execution_role_arn       = module.ecs_service.task_definition.execution_role_arn
  task_role_arn            = module.ecs_service.task_definition.task_role_arn
  requires_compatibilities = module.ecs_service.task_definition.requires_compatibilities
  cpu                      = module.ecs_service.task_definition.cpu
  memory                   = module.ecs_service.task_definition.memory
  network_mode             = "awsvpc"
  track_latest             = true

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }
}

##
# EventBridge
##
resource "aws_cloudwatch_event_rule" "sync_orgs_cron_job" {
  count = var.enable_organisations_sync ? 1 : 0

  name                = "${var.env_name}-forms-admin-orgs-sync-cron"
  description         = "Trigger the forms-admin organisations synchronisation on a schedule"
  schedule_expression = "cron(30 11 * * 2 *)" # 11:30AM every Tuesday. In office hours so that we can respond to failures
}

resource "aws_cloudwatch_event_target" "ecs_org_sync_job" {
  count = var.enable_organisations_sync ? 1 : 0

  arn      = var.ecs_cluster_arn
  rule     = aws_cloudwatch_event_rule.sync_orgs_cron_job[0].name
  role_arn = aws_iam_role.ecs_orgs_cron_scheduler[0].arn

  ecs_target {
    task_definition_arn = "arn:aws:ecs:eu-west-2:${data.aws_caller_identity.current.account_id}:task-definition/${aws_ecs_task_definition.orgs_cron_job[0].family}"
    launch_type         = "FARGATE"
    platform_version    = "1.4.0"

    network_configuration {
      assign_public_ip = false
      security_groups  = module.ecs_service.service.network_configuration[0].security_groups
      subnets          = module.ecs_service.service.network_configuration[0].subnets
    }
  }

  dead_letter_config {
    arn = var.eventbridge_dead_letter_queue_arn
  }
}

## Monitor for failure
resource "aws_cloudwatch_event_rule" "sync_orgs_cron_job_failed" {
  count = var.enable_organisations_sync ? 1 : 0

  name        = "${var.env_name}-forms-admin-org-sync-failed"
  description = "Trigger when the organisations sync job has exited with a non-zero exit code"

  event_pattern = jsonencode({
    source      = ["aws.ecs"]
    detail-type = ["ECS Task State Change"]
    resources = [
      {
        wildcard : "arn:aws:ecs:eu-west-2:${data.aws_caller_identity.current.account_id}:task/*"
      }
    ]

    detail = {
      lastStatus = ["STOPPED"]
      containers = {
        name     = [local.organisations_sync_container_definitions.name]
        exitCode = [{ "anything-but" : [0] }]
      }
    }
  })
}

resource "aws_cloudwatch_event_target" "sync_orgs_cron_job_alert_message" {
  count = var.enable_organisations_sync ? 1 : 0

  rule = aws_cloudwatch_event_rule.sync_orgs_cron_job_failed[0].name

  # defined in 'environment' module. Sends alarms/errors via ZenDesk
  arn = var.zendesk_sns_topic_arn

  input_transformer {
    input_template = <<EOF
    {
      "title": "WARNING: Synchronising organisations from GOV.UK has failed.",
      "description": "GOV.UK Forms has a scheduled ECS task to sync our organisations from GOV.UK. When this task fails an email is sent to Zendesk.",
      "next-steps": {
        "1": "Navigate to Splunk: https://gds.splunkcloud.com/en-GB/app/gds-543-forms/search.",
        "2": "Search for index=gds_dsp_production_forms log_stream=forms-admin-production-organisations-sync/forms-admin_organisations_sync/*. Use the 'Today' date-time preset to find today's logs.",
        "3": "Review logs for errors."
      }
    }
    EOF
  }

  dead_letter_config {
    arn = var.eventbridge_dead_letter_queue_arn
  }
}

##
# IAM
##
resource "aws_iam_role" "ecs_orgs_cron_scheduler" {
  count = var.enable_organisations_sync ? 1 : 0

  name = "${var.env_name}-forms-admin-orgs-ecs-cron-scheduler"

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

resource "aws_iam_role_policy_attachment" "ecs_orgs_events_policy" {
  count = var.enable_organisations_sync ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceEventsRole"
  role       = aws_iam_role.ecs_orgs_cron_scheduler[0].name
}
