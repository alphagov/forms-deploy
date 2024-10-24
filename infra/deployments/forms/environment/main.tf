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

# We are using locals blocks to conditionally import the
# SNS topic subscriptions: cloudwatch-alarms and alert_zendesk_<env>.
# We need to do this because the topic subscriptions are "PendingConfirmation" in
# both staging and user-research and doesn't have an ARN.
# We also need to temporarily hard code SNS topic subscription ARNs because
# Terraform doesn't support aws_sns_topic_subscription data sources.

locals {
  us_east_1_sns_topic_subscription_arns = {
    dev           = "arn:aws:sns:us-east-1:498160065950:cloudwatch-alarms:401ebe3e-3334-416b-bf15-0d77b6e2a691"
    staging       = null
    user-research = null
    production    = "arn:aws:sns:us-east-1:443944947292:cloudwatch-alarms:5fa4dd7d-a3f7-4f7c-a332-32a79ade0bfb"
  }
}

import {
  for_each = local.us_east_1_sns_topic_subscription_arns[var.environment_name] != null ? [1] : []

  id = local.us_east_1_sns_topic_subscription_arns[var.environment_name]
  to = module.environment.aws_sns_topic_subscription.zendesk_email_us_east_1
}

locals {
  alert_zendesk_topic_subscription_arns = {
    dev           = "arn:aws:sns:eu-west-2:498160065950:alert_zendesk_dev:ee0de826-6bc4-4c01-a41d-9f0c20e42187"
    staging       = null
    user-research = null
    production    = "arn:aws:sns:eu-west-2:443944947292:alert_zendesk_production:950c742e-c556-4d96-9e0f-371ee65ae2ca"
  }
}

import {
  for_each = local.alert_zendesk_topic_subscription_arns[var.environment_name] != null ? [1] : []

  id = local.alert_zendesk_topic_subscription_arns[var.environment_name]
  to = module.environment.aws_sns_topic_subscription.zendesk_email_eu_west_2
}

import {
  id = "/alerting/${var.environment_name}/pagerduty-integration-url"
  to = module.environment.aws_ssm_parameter.pagerduty_integration_url
}

locals {
  pagerduty_topic_subscription_arns = {
    dev           = "arn:aws:sns:eu-west-2:498160065950:pagerduty_integration_dev:3915fc62-57c5-4e30-a6a6-e809a2ee24fb"
    staging       = "arn:aws:sns:eu-west-2:972536609845:pagerduty_integration_staging:d30668e5-ac00-44b5-bec0-44a687a6f56b"
    user-research = "arn:aws:sns:eu-west-2:619109835131:pagerduty_integration_user-research:ed88b257-992b-41fc-9c51-d08bb731b120"
    production    = "arn:aws:sns:eu-west-2:443944947292:pagerduty_integration_production:a69df9c7-e229-4b58-b02e-05f718c83803"
  }
}

import {
  id = local.pagerduty_topic_subscription_arns[var.environment_name]
  to = module.environment.aws_sns_topic_subscription.pagerduty_subscription_eu_west_2
}

locals {
  kms_key_ids = {
    dev = {
      us-east-1 = "03fa99fc-e1cf-4cff-97c2-15459178b44b"
      eu-west-2 = "5027ecd9-0650-4d82-8bd6-5863231736af"
    }

    staging = {
      us-east-1 = "fb038ad8-6b68-4f5c-9d10-978c4b5a58ee"
      eu-west-2 = "42d015e1-2ddc-4dd9-a224-8809beadcf3c"
    }

    user-research = {
      us-east-1 = "afe2c545-a7b0-47e4-92a0-8e05aff5cac0"
      eu-west-2 = "7c283803-654c-4928-8427-de48599f8a76"
    }

    production = {
      us-east-1 = "c3a9b72e-b854-4516-8619-df57e5b711d9"
      eu-west-2 = "ca8c379c-b1d8-4087-84fb-f7bed3db8e0b"
    }
  }
}

data "aws_region" "current" {}

# CloudWatch Topic
import {
  id = "arn:aws:sns:us-east-1:${data.aws_caller_identity.current.account_id}:cloudwatch-alarms"
  to = module.environment.module.zendesk_alert_us_east_1.aws_sns_topic.topic
}

# CloudWatch SNS Topic Policy
import {
  id = "arn:aws:sns:us-east-1:${data.aws_caller_identity.current.account_id}:cloudwatch-alarms"
  to = module.environment.module.zendesk_alert_us_east_1.aws_sns_topic_policy.topic_policy
}

# Alert Zendesk Topic
import {
  id = "arn:aws:sns:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:alert_zendesk_${var.environment_name}"
  to = module.environment.module.zendesk_alert_eu_west_2.aws_sns_topic.topic
}

# Alert Zendesk Topic Policy
import {
  id = "arn:aws:sns:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:alert_zendesk_${var.environment_name}"
  to = module.environment.module.zendesk_alert_eu_west_2.aws_sns_topic_policy.topic_policy
}

# Pagerduty Topic
import {
  id = "arn:aws:sns:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:pagerduty_integration_${var.environment_name}"
  to = module.environment.module.pagerduty_eu_west_2.aws_sns_topic.topic
}

# Pagerduty Topic Policy
import {
  id = "arn:aws:sns:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:pagerduty_integration_${var.environment_name}"
  to = module.environment.module.pagerduty_eu_west_2.aws_sns_topic_policy.topic_policy
}
