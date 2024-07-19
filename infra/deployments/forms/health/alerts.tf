module "alerts" {
  source = "./alerts"

  providers = {
    aws           = aws
    aws.us-east-1 = aws.us-east-1
  }

  environment                = var.environment_name
  minimum_healthy_host_count = 3
  enable_alert_actions       = var.environmental_settings.enable_alert_actions

  zendesk_alert_topics = {
    us_east_1 : aws_sns_topic.cloudwatch_alarms.arn
  }
}

import {
  id = "${var.environment_name}-reached-ip-rate-limit"
  to = module.alerts.aws_cloudwatch_metric_alarm.cloudfront_reached_ip_rate_limit
}