# AWS ChatBot Slack Channel Configurations
#
# These resources were previously created manually via the AWS Console.
# Use the import blocks below to bring them under Terraform management.

# Import the existing IAM role created by AWS ChatBot
import {
  id = "AWSChatBot-GOVUK-Forms-Deployments-Channel-Role"
  to = aws_iam_role.chatbot
}

# IAM Role for ChatBot (existing resource)
# This role was originally created by AWS ChatBot service
resource "aws_iam_role" "chatbot" {
  name = "AWSChatBot-GOVUK-Forms-Deployments-Channel-Role"
  path = "/service-role/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "chatbot.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  lifecycle {
    ignore_changes = [tags, tags_all]
  }
}

# Import the existing custom managed policy
import {
  id = "arn:aws:iam::711966560482:policy/service-role/AWS-Chatbot-NotificationsOnly-Policy-24aa677e-d37d-40b7-9b56-a1e2c542ba4d"
  to = aws_iam_policy.chatbot_notifications_only
}

# Custom managed policy for ChatBot (existing resource)
# This policy was created by AWS ChatBot service
resource "aws_iam_policy" "chatbot_notifications_only" {
  #checkov:skip=CKV_AWS_355:CloudWatch read operations require Resource="*" as metrics cannot be scoped to specific resources
  name        = "AWS-Chatbot-NotificationsOnly-Policy-24aa677e-d37d-40b7-9b56-a1e2c542ba4d"
  path        = "/service-role/"
  description = "NotificationsOnly policy for AWS-Chatbot"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "cloudwatch:Describe*",
          "cloudwatch:Get*",
          "cloudwatch:List*"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })

  lifecycle {
    ignore_changes = [tags, tags_all]
  }
}

# Import the policy attachment
import {
  id = "AWSChatBot-GOVUK-Forms-Deployments-Channel-Role/arn:aws:iam::711966560482:policy/service-role/AWS-Chatbot-NotificationsOnly-Policy-24aa677e-d37d-40b7-9b56-a1e2c542ba4d"
  to = aws_iam_role_policy_attachment.chatbot_notifications_only
}

# Attach the NotificationsOnly policy to the ChatBot role
resource "aws_iam_role_policy_attachment" "chatbot_notifications_only" {
  role       = aws_iam_role.chatbot.name
  policy_arn = aws_iam_policy.chatbot_notifications_only.arn
}

# Import blocks for existing ChatBot configurations
import {
  id = "arn:aws:chatbot::711966560482:chat-configuration/slack-channel/govuk-forms-alert"
  to = aws_chatbot_slack_channel_configuration.alerts
}

import {
  id = "arn:aws:chatbot::711966560482:chat-configuration/slack-channel/govuk-forms-deployments"
  to = aws_chatbot_slack_channel_configuration.deployments
}

data "aws_chatbot_slack_workspace" "gds" {
  slack_team_name = "GDS"
}

# ChatBot Slack Channel Configuration - Alerts Channel
resource "aws_chatbot_slack_channel_configuration" "alerts" {
  configuration_name = "govuk-forms-alert"
  iam_role_arn       = aws_iam_role.chatbot.arn

  slack_channel_id = "C0402R0GCTS"
  slack_team_id    = data.aws_chatbot_slack_workspace.gds.slack_team_id

  sns_topic_arns = [
    aws_sns_topic.alerts_topic.arn
  ]

  guardrail_policy_arns = [
    "arn:aws:iam::aws:policy/ReadOnlyAccess"
  ]

  logging_level = "INFO"

  user_authorization_required = false
}

# ChatBot Slack Channel Configuration - Deployments Channel
resource "aws_chatbot_slack_channel_configuration" "deployments" {
  configuration_name = "govuk-forms-deployments"
  iam_role_arn       = aws_iam_role.chatbot.arn

  slack_channel_id = "C04LAMR3RNW"
  slack_team_id    = data.aws_chatbot_slack_workspace.gds.slack_team_id

  sns_topic_arns = [
    aws_sns_topic.deployments_topic.arn
  ]

  guardrail_policy_arns = [
    "arn:aws:iam::aws:policy/AWSCodePipeline_ReadOnlyAccess"
  ]

  logging_level = "INFO"

  user_authorization_required = false
}
