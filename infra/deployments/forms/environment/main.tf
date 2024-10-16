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
