module "environment" {
  source   = "../../../modules/environment"
  env_name = var.environment_name

  providers = {
    aws           = aws
    aws.us-east-1 = aws.us-east-1
  }

  ips_to_block         = var.environmental_settings.ips_to_block
  enable_alert_actions = var.environmental_settings.enable_alert_actions
}

