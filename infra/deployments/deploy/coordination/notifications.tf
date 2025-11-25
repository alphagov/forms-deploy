locals {
  # We have configured AWS ChatBot for sending messages to Slack.
  # AWS ChatBot does not have an API we can use in Terraform, so we
  # configured it by hand in the one place and hardcoded the SNS topic here.
  chatbot_deployments_channel_sns_topic = "arn:aws:sns:eu-west-2:${var.deploy_account_id}:CodeStarNotifications-govuk-forms-deployments-c383f287ab987f0b12d32e4533a145b1c918167d"
  chatbot_alerts_channel_sns_topic      = "arn:aws:sns:eu-west-2:${var.deploy_account_id}:CodeStarNotifications-govuk-forms-alert-b7410628fe547543676d5dc062cf342caba48bcd"

  chatbot_message_input_paths = {
    pipeline = "$.detail.pipeline"
    account  = "$.account"
    time     = "$.time"
  }

  # Excludes integration account from the list of all account ids
  # This is because we don't want to build Slack notification resources
  # for the integration account (yet).
  account_except_integration = {
    for account in setsubtract(keys(module.other_accounts.all_accounts_id), ["integration"]) :
    account => module.other_accounts.all_accounts_id[account]
  }
}

# The alerts and deployments SNS topics and their access policies were created by the AWS ChatBot service.
# These import blocks should be left in place as a reminder of where they came from.
import {
  id = local.chatbot_alerts_channel_sns_topic
  to = aws_sns_topic.alerts_topic
}

import {
  id = local.chatbot_alerts_channel_sns_topic
  to = aws_sns_topic_policy.alerts_topic_access_policy
}

resource "aws_sns_topic" "alerts_topic" {
  # checkov:skip=CKV_AWS_26:AWS ChatBot doesn't configure it with encryption
  name            = "CodeStarNotifications-govuk-forms-alert-b7410628fe547543676d5dc062cf342caba48bcd"
  delivery_policy = <<JSON
{
  "http": {
    "defaultHealthyRetryPolicy": {
      "minDelayTarget": 20,
      "maxDelayTarget": 20,
      "numRetries": 3,
      "numMaxDelayRetries": 0,
      "numNoDelayRetries": 0,
      "numMinDelayRetries": 0,
      "backoffFunction": "linear"
    },
    "disableSubscriptionOverrides": false,
    "defaultRequestPolicy": {
      "headerContentType": "text/plain; charset=UTF-8"
    }
  }
}
JSON
}

resource "aws_sns_topic_policy" "alerts_topic_access_policy" {
  arn = aws_sns_topic.alerts_topic.arn
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AllowPublishFromServices",
        Action   = "sns:Publish"
        Effect   = "Allow"
        Resource = aws_sns_topic.alerts_topic.arn
        Principal = {
          Service = [
            "cloudwatch.amazonaws.com",
            "events.amazonaws.com",
            "codestar-notifications.amazonaws.com"
          ]
        }
      },
      {
        Sid      = "AllowPublishFromAccounts"
        Action   = "sns:Publish"
        Effect   = "Allow"
        Resource = aws_sns_topic.alerts_topic.arn
        Principal = {
          AWS = [for _, id in module.other_accounts.environment_accounts_id : "arn:aws:iam::${id}:root"]
        }
      }
    ]
  })
}

import {
  id = local.chatbot_deployments_channel_sns_topic
  to = aws_sns_topic.deployments_topic
}

import {
  id = local.chatbot_deployments_channel_sns_topic
  to = aws_sns_topic_policy.deployments_topic_access_policy
}

resource "aws_sns_topic" "deployments_topic" {
  # checkov:skip=CKV_AWS_26:AWS ChatBot doesn't configure it with encryption
  name            = "CodeStarNotifications-govuk-forms-deployments-c383f287ab987f0b12d32e4533a145b1c918167d"
  delivery_policy = <<JSON
{
  "http": {
    "defaultHealthyRetryPolicy": {
      "minDelayTarget": 20,
      "maxDelayTarget": 20,
      "numRetries": 3,
      "numMaxDelayRetries": 0,
      "numNoDelayRetries": 0,
      "numMinDelayRetries": 0,
      "backoffFunction": "linear"
    },
    "disableSubscriptionOverrides": false,
    "defaultRequestPolicy": {
      "headerContentType": "text/plain; charset=UTF-8"
    }
  }
}
JSON
}

resource "aws_sns_topic_policy" "deployments_topic_access_policy" {
  arn = aws_sns_topic.deployments_topic.arn
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AllowPublishFromServices",
        Action   = "sns:Publish"
        Effect   = "Allow"
        Resource = aws_sns_topic.deployments_topic.arn
        Principal = {
          Service = [
            "cloudwatch.amazonaws.com",
            "events.amazonaws.com",
            "codestar-notifications.amazonaws.com"
          ]
        }
      },
      {
        Sid      = "AllowPublishFromAccounts"
        Action   = "sns:Publish"
        Effect   = "Allow"
        Resource = aws_sns_topic.deployments_topic.arn
        Principal = {
          AWS = [for _, id in module.other_accounts.environment_accounts_id : "arn:aws:iam::${id}:root"]
        }
      }
    ]
  })
}

module "slack_notifications" {
  for_each = local.account_except_integration
  source   = "./slack-notifications"


  account_id                      = each.value
  account_name                    = each.key
  dead_letter_queue_arn           = aws_sqs_queue.event_bridge_dlq.arn
  pipeline_completion_topic_arn   = local.chatbot_deployments_channel_sns_topic
  pipeline_failure_topic_arn      = each.key == "development" ? local.chatbot_deployments_channel_sns_topic : local.chatbot_alerts_channel_sns_topic
  run_e2e_tests_failure_topic_arn = each.key == "development" ? local.chatbot_deployments_channel_sns_topic : local.chatbot_alerts_channel_sns_topic
}
