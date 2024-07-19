data "aws_ssm_parameter" "email_zendesk" {
  name = "/alerting/email-zendesk"
}

resource "aws_sns_topic" "cloudwatch_alarms" {
  #checkov:skip=CKV_AWS_26:We don't need this to be encrypted at the moment
  provider = aws.us-east-1
  name     = "cloudwatch-alarms"
}

resource "aws_sns_topic_subscription" "email" {
  provider  = aws.us-east-1
  topic_arn = aws_sns_topic.cloudwatch_alarms.arn
  protocol  = "email"
  endpoint  = data.aws_ssm_parameter.email_zendesk.value
}

import {
  id = "arn:aws:sns:us-east-1:${data.aws_caller_identity.current.account_id}:cloudwatch-alarms"
  to = aws_sns_topic.cloudwatch_alarms
}

locals {
  zendesk_subscription_guids = {
    "dev" : "23357c1f-7245-4563-9d84-ce19e31535e4"
    "staging" : null,
    "production" : "5fa4dd7d-a3f7-4f7c-a332-32a79ade0bfb",
    "user-research" : null,
  }
}

import {
  for_each = local.zendesk_subscription_guids[var.environment_name] != null ? [1] : []

  id = "${aws_sns_topic.cloudwatch_alarms.arn}:${local.zendesk_subscription_guids[var.environment_name]}"
  to = aws_sns_topic_subscription.email
}