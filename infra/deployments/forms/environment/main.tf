module "environment" {
  source      = "../../../modules/environment"
  env_name    = var.environment_name
  env_type    = var.environment_type
  root_domain = var.root_domain
  providers = {
    aws           = aws
    aws.us-east-1 = aws.us-east-1
  }

  ips_to_block         = var.environmental_settings.ips_to_block
  enable_alert_actions = var.environmental_settings.enable_alert_actions

  enable_shield_advanced_healthchecks = var.environmental_settings.enable_shield_advanced_healthchecks
  scheduled_smoke_tests_settings      = var.scheduled_smoke_tests_settings
}

# We are temporarily hard-coding the KMS key IDS
# so that we can reference them in the import statements
# Ideally we'd use KMS key aliases but we haven't
# declared any kms_key_alias resources
locals {
  us_east_1_kms_key_ids = {
    dev           = "5027ecd9-0650-4d82-8bd6-5863231736af"
    staging       = "fb038ad8-6b68-4f5c-9d10-978c4b5a58ee"
    user-research = "afe2c545-a7b0-47e4-92a0-8e05aff5cac0"
    production    = "c3a9b72e-b854-4516-8619-df57e5b711d9"
  }

  eu_west_2_kms_key_ids = {
    dev           = "03fa99fc-e1cf-4cff-97c2-15459178b44b"
    staging       = "42d015e1-2ddc-4dd9-a224-8809beadcf3c"
    user-research = "7c283803-654c-4928-8427-de48599f8a76"
    production    = "ca8c379c-b1d8-4087-84fb-f7bed3db8e0b"
  }
}

import {
  to = module.environment.aws_kms_key.topic_sse_us_east_1
  id = local.us_east_1_kms_key_ids[var.environment_name]
}

import {
  to = module.environment.aws_kms_key.topic_sse_eu_west_2
  id = local.eu_west_2_kms_key_ids[var.environment_name]
}

# We are using locals blocks to conditionally import SNS topic subscriptions.
# We need to do this because the topic subscriptions are "PendingConfirmation" in
# both staging and user-research and doesn't have an ARN.
# We also need to temporarily hard code the ARNs because Terraform doesn't support
# aws_sns_topic_subscription data sources.

locals {
  us_east_1_sns_topic_subscription_arns = {
    dev        = "arn:aws:sns:us-east-1:498160065950:cloudwatch-alarms:401ebe3e-3334-416b-bf15-0d77b6e2a691"
    production = "arn:aws:sns:us-east-1:443944947292:cloudwatch-alarms:5fa4dd7d-a3f7-4f7c-a332-32a79ade0bfb"
  }
}

locals {
  import_resource = {
    dev           = true
    staging       = false
    user-research = false
    production    = true
  }
}

import {
  for_each = local.import_resource[var.environment_name] ? [1] : []

  id = local.us_east_1_sns_topic_subscription_arns[var.environment_name]
  to = module.environment.aws_sns_topic_subscription.zendesk_email_us_east_1
}

locals {
  alert_zendesk_topic_subscription_arns = {
    dev        = "arn:aws:sns:eu-west-2:498160065950:alert_zendesk_dev:ee0de826-6bc4-4c01-a41d-9f0c20e42187"
    production = "arn:aws:sns:eu-west-2:443944947292:alert_zendesk_production:950c742e-c556-4d96-9e0f-371ee65ae2ca"
  }
}

import {
  for_each = local.import_resource[var.environment_name] ? [1] : []

  id = local.alert_zendesk_topic_subscription_arns[var.environment_name]
  to = module.environment.aws_sns_topic_subscription.zendesk_email_eu_west_2
}

import {
  id = "/alerting/${var.environment_name}/pagerduty-integration-url"
  to = module.environment.aws_ssm_parameter.pagerduty_integration_url
}
