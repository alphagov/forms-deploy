data "aws_secretsmanager_secret_version" "chatbot_alerts_sns_topic_arn" {
  # Use the full ARN to reference the secret in the deploy account
  secret_id = "arn:aws:secretsmanager:eu-west-2:${var.deploy_account_id}:secret:govuk-forms/chatbot/alerts-sns-topic-arn"
}

locals {
  # AWS ChatBot SNS topic - managed in the deploy account (deploy/coordination/chatbot.tf)
  # Retrieved from Secrets Manager for cross-account access
  chatbot_alerts_channel_sns_topic = data.aws_secretsmanager_secret_version.chatbot_alerts_sns_topic_arn.secret_string

  // alert severity is a collection of maps from severity level to the channel that
  // should be used for that severity
  alert_severity = {
    eu_west_2 = {
      info = var.zendesk_alert_topics.eu_west_2
      warn = local.chatbot_alerts_channel_sns_topic
      high = var.allow_pagerduty_alerts ? var.pagerduty_alert_topics.eu_west_2 : local.chatbot_alerts_channel_sns_topic
    }

    us_east_1 = {
      info = var.zendesk_alert_topics.us_east_1
      warn = local.chatbot_alerts_channel_sns_topic
      high = var.allow_pagerduty_alerts ? var.pagerduty_alert_topics.eu_west_2 : local.chatbot_alerts_channel_sns_topic
    }
  }
}
