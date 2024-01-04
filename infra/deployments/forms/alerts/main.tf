module "alerts" {
  source      = "../../../modules/alerts"
  environment = var.environment_name

  enable_alert_actions = var.environmental_settings.enable_alert_actions

  minimum_healthy_host_count = 3
}

import {
  to = module.alerts.aws_ssm_parameter.pagerduty_integration_url
  id = "/alerting/${var.environment_name}/pager-duty-integration-url"
}