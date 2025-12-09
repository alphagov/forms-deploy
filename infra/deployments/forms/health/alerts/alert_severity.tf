module "chatbot_well_known" {
  source = "../../../../modules/well-known/chatbot"
}

locals {
  # AWS ChatBot SNS topic - managed in the deploy account (deploy/coordination/chatbot.tf)
  # Referenced via well-known module for cross-account access
  chatbot_alerts_channel_sns_topic = module.chatbot_well_known.alerts_topic_arn

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
