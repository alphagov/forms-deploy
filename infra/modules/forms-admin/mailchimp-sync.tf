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
          awslogs-group         = module.ecs_service.application_log_group_name,
          awslogs-region        = "eu-west-2",
          awslogs-stream-prefix = "forms-admin-${var.env_name}-mailchimp-sync"
        }
      },
    }
  )
}

resource "aws_ecs_task_definition" "mailchimp_cron_job" {
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

  // As we deploy the forms-admin versions with codepipeline, terraform is not the source of truth for the task definition image. Therefore use `track_latest` to avoid drift.
  track_latest = true
}

##
# EventBridge
##
resource "aws_cloudwatch_event_rule" "sync_mailchimp_cron_job" {
  count = var.enable_mailchimp_sync ? 1 : 0

  name                = "${var.env_name}-forms-admin-mailchimp-sync-cron"
  description         = "Trigger the forms-admin MailChimp synchronisation on a schedule"
  schedule_expression = "cron(30 10 * * ? *)" # 10:30AM daily. In office hours so that we can respond to failures
}

resource "aws_cloudwatch_event_target" "ecs_mailchimp_sync_job" {
  count = var.enable_mailchimp_sync ? 1 : 0

  arn      = var.ecs_cluster_arn
  rule     = aws_cloudwatch_event_rule.sync_mailchimp_cron_job[0].name
  role_arn = aws_iam_role.ecs_mailchimp_cron_scheduler[0].arn

  ecs_target {
    # Construct ARN without revision number to always use the latest revision
    # Format: arn:aws:ecs:region:account:task-definition/family
    # This ensures the EventBridge rule always uses the latest revision
    # which is updated by the forms-admin deployment pipeline
    task_definition_arn = "arn:aws:ecs:eu-west-2:${data.aws_caller_identity.current.account_id}:task-definition/${aws_ecs_task_definition.mailchimp_cron_job[0].family}"
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
resource "aws_cloudwatch_event_rule" "sync_mailchimp_cron_job_failed" {
  name        = "${var.env_name}-forms-admin-mailchimp-sync-failed"
  description = "Trigger when the MailChimp sync job has exited with a non-zero exit code"

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
        name     = [local.mailchimp_sync_container_definitions.name]
        exitCode = [{ "anything-but" : [0] }]
      }
    }
  })
}

resource "aws_cloudwatch_event_target" "sync_mailchimp_cron_job_alert_message" {
  rule = aws_cloudwatch_event_rule.sync_mailchimp_cron_job_failed.name

  # defined in 'environment' module. Sends alarms/errors via ZenDesk
  arn = var.zendesk_sns_topic_arn

  input_transformer {
    input_template = <<EOF
    {
      "title": "WARNING: Synchronising mailing lists with MailChimp has failed.",
      "description": "GOV.UK Forms has a scheduled ECS task to sync our Mailchimp mailing list with new users in the users database (only applied in production). When this task fails an email is sent to Zendesk.",
      "next-steps": {
        "1": "Navigate to Splunk: https://gds.splunkcloud.com/en-GB/app/gds-543-forms/search.",
        "2": "Search for index=gds_dsp_production_forms log_stream=forms-admin-production-mailchimp-sync/forms-admin_mailchimp_sync/*. Use the 'Today' date-time preset to find today's logs.",
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
resource "aws_iam_role" "ecs_mailchimp_cron_scheduler" {
  count = var.enable_mailchimp_sync ? 1 : 0

  name = "${var.env_name}-forms-admin-mailchimp-ecs-cron-scheduler"

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

resource "aws_iam_role_policy_attachment" "ecs_mailchimp_events_policy" {
  count = var.enable_mailchimp_sync ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceEventsRole"
  role       = aws_iam_role.ecs_mailchimp_cron_scheduler[0].name
}

moved {
  from = aws_cloudwatch_event_rule.sync_cron_job_failed
  to   = aws_cloudwatch_event_rule.sync_mailchimp_cron_job_failed
}

moved {
  from = aws_cloudwatch_event_target.sync_cron_job_alert_message
  to   = aws_cloudwatch_event_target.sync_mailchimp_cron_job_alert_message
}
