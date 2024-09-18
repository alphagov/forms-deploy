module "environment" {
  source   = "../../../modules/environment"
  env_name = var.environment_name
  env_type = var.environment_type

  providers = {
    aws           = aws
    aws.us-east-1 = aws.us-east-1
  }

  ips_to_block         = var.environmental_settings.ips_to_block
  enable_alert_actions = var.environmental_settings.enable_alert_actions

  enable_shield_advanced_healthchecks = var.environmental_settings.enable_shield_advanced_healthchecks
  scheduled_smoke_tests_settings      = var.scheduled_smoke_tests_settings
}

import {
  id = "https://sqs.eu-west-2.amazonaws.com/498160065950/dev-eventbridge-dead-letter-queue"
  to = module.environment.aws_sqs_queue.event_bridge_dlq
}
