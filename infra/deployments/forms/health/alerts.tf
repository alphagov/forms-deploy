module "alerts" {
  source = "./alerts"

  providers = {
    aws           = aws
    aws.us-east-1 = aws.us-east-1
  }

  environment                = var.environment_name
  minimum_healthy_host_count = 3
  enable_alert_actions       = var.environmental_settings.enable_alert_actions
  deploy_account_id          = var.deploy_account_id


  zendesk_alert_topics = {
    us_east_1 : module.zendesk_alert_us_east_1.topic_arn
    eu_west_2 : module.zendesk_alert_eu_west_2.topic_arn
  }

  pagerduty_alert_topics = {
    eu_west_2 : module.pagerduty_eu_west_2.topic_arn
  }
}