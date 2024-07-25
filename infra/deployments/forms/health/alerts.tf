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
  }
}