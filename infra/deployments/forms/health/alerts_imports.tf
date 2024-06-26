# The imports in this file are in the lexical order the resources were defined
# within in each file in ./alerts, ordered alphabetically

locals {
  pagerduty_subscription_guids = {
    "dev"           = "269cda6b-9af8-4f11-8597-7d5ed92ae6b7",
    "staging"       = "3e02f944-d792-4130-bd20-83d0791569d7",
    "production"    = "c2b560ae-0fb1-4fb6-82a6-08a28e83357c",
    "user-research" = "2d4ffc20-a580-419e-a904-9d8bcf273c1a"
  }

  zendesk_subscription_guids = {
    "dev"           = null,
    "staging"       = null,
    "production"    = "950c742e-c556-4d96-9e0f-371ee65ae2ca",
    "user-research" = null
  }

  topic_kms_key_ids = {
    "dev"           = "03fa99fc-e1cf-4cff-97c2-15459178b44b",
    "staging"       = "42d015e1-2ddc-4dd9-a224-8809beadcf3c",
    "production"    = "ca8c379c-b1d8-4087-84fb-f7bed3db8e0b",
    "user-research" = "7c283803-654c-4928-8427-de48599f8a76"
  }
}

import {
  for_each = data.aws_lb_target_group.target_groups

  id = "alb_healthy_host_count_${each.value.name}"
  to = module.alerts.aws_cloudwatch_metric_alarm.healthy_host_alarms[each.key]
}

import {
  id = "pipeline-invoker-failed-invocation"
  to = module.alerts.aws_cloudwatch_metric_alarm.pipeline_invoker_failure
}

import {
  id = "paused-pipeline-detector-failed-invocation"
  to = module.alerts.aws_cloudwatch_metric_alarm.paused_pipeline_detector_failure
}

import {
  id = "ses_bounces_and_complaints_queue_buildup"
  to = module.alerts.aws_cloudwatch_metric_alarm.ses_bounces_and_complaints_queue_buildup
}

import {
  id = "ses_bounces_and_complaints_queue_contains_message"
  to = module.alerts.aws_cloudwatch_metric_alarm.ses_bounces_and_complaints_queue_contains_message
}

data "aws_sns_topic" "alert_pagerduty" {
  name = "pagerduty_integration_${var.environment_name}"
}

data "aws_sns_topic" "alert_zendesk" {
  name = "alert_zendesk_${var.environment_name}"
}

import {
  id = data.aws_sns_topic.alert_pagerduty.arn
  to = module.alerts.aws_sns_topic.alert_pagerduty
}

import {
  id = "/alerting/${var.environment_name}/pagerduty-integration-url"
  to = module.alerts.aws_ssm_parameter.pagerduty_integration_url
}

import {
  id = "${data.aws_sns_topic.alert_pagerduty.arn}:${local.pagerduty_subscription_guids[var.environment_name]}"
  to = module.alerts.aws_sns_topic_subscription.pagerduty_subscription
}

import {
  id = local.topic_kms_key_ids[var.environment_name]
  to = module.alerts.aws_kms_key.topic_sse
}

import {
  id = data.aws_sns_topic.alert_zendesk.arn
  to = module.alerts.aws_sns_topic.alert_zendesk
}

import {
  for_each = local.zendesk_subscription_guids[var.environment_name] == null ? [] : [1]
  id       = "${data.aws_sns_topic.alert_zendesk.arn}:${local.zendesk_subscription_guids[var.environment_name]}"
  to       = module.alerts.aws_sns_topic_subscription.zendesk_subscription
}

import {
  for_each = data.aws_lb_target_group.target_groups

  id = "alb_target_group_response_time_${each.value.name}"
  to = module.alerts.aws_cloudwatch_metric_alarm.lb_target_group_response_time[each.key]
}