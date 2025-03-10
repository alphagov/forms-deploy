locals {
  # We have configured AWS ChatBot for sending messages to Slack.
  # AWS ChatBot does not have an API we can use in Terraform, so we
  # configured it by hand in the one place and hardcoded the SNS topic here.
  chatbot_alerts_channel_sns_topic = "arn:aws:sns:eu-west-2:${var.deploy_account_id}:CodeStarNotifications-govuk-forms-alert-b7410628fe547543676d5dc062cf342caba48bcd"

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
