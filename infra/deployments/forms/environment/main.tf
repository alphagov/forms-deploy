module "environment" {
  source   = "../../../modules/environment"
  env_name = var.environment_name

  providers = {
    aws           = aws
    aws.us-east-1 = aws.us-east-1
  }

  ips_to_block         = var.environmental_settings.ips_to_block
  enable_alert_actions = var.environmental_settings.enable_alert_actions

  enable_shield_advanced_healthchecks = var.environmental_settings.enable_shield_advanced_healthchecks
}

# TODO: Remove import and locals once AWSServiceRoleForAWSShield linked role is deployed
import {
  to = module.environment.aws_iam_service_linked_role.shield
  id = "arn:aws:iam::${lookup(local.account_ids, var.environment_name)}:role/aws-service-role/shield.amazonaws.com/AWSServiceRoleForAWSShield"
}

locals {
  account_ids = {
    "dev"           = "498160065950"
    "staging"       = "972536609845"
    "production"    = "443944947292"
    "user-research" = "619109835131"
  }
}
