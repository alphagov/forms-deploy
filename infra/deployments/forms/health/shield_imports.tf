# The imports in this file are in the lexical order the resources were defined
# in shield.tf, ordered alphabetically

locals {
  shield_cloudfront_protection_ids = {
    "dev"           = "0932e17f-d696-4f0d-86da-8762a4061af1",
    "staging"       = "4418859f-5ca7-4dfb-8164-4feaddb438ee",
    "production"    = "b35bfe8d-7a0b-45fe-995d-3bef3d1cda03",
    "user-research" = "d0bf8280-d5eb-4b5b-80d4-2edf28fed417"
  }

  shield_alb_protection_ids = {
    "dev"           = "40c1f53d-d590-491a-94f8-57c608d47255",
    "staging"       = "cb681d8b-ef5f-4192-8868-e4fe98be5ab6",
    "production"    = "e980d478-f679-41a3-9d97-79fa6ddb018b",
    "user-research" = "59490a83-1a65-4643-b56a-eae740e7aeb3"
  }

  shield_role_arn_association_ids = {
    "dev"           = data.aws_caller_identity.current.account_id,
    "staging"       = data.aws_caller_identity.current.account_id,
    "production"    = data.aws_caller_identity.current.account_id,
    "user-research" = data.aws_caller_identity.current.account_id
  }

  shield_proactive_engagement_ids = {
    "dev"           = data.aws_caller_identity.current.account_id,
    "staging"       = data.aws_caller_identity.current.account_id,
    "production"    = data.aws_caller_identity.current.account_id,
    "user-research" = data.aws_caller_identity.current.account_id
  }

  r53_healthcheck_api_id = {
    "dev"           = "",
    "staging"       = "",
    "production"    = "774584fc-c0bc-47e3-8f56-f1f322b8d1f9",
    "user-research" = ""
  }

  r53_healthcheck_admin_id = {
    "dev"           = "",
    "staging"       = "",
    "production"    = "bce539df-5615-48c6-816f-621390401b80",
    "user-research" = ""
  }


  r53_healthcheck_product_page_id = {
    "dev"           = "",
    "staging"       = "",
    "production"    = "8025bfc1-8bc3-4ba3-bd9b-550d5c96b04a",
    "user-research" = ""
  }

  r53_healthcheck_runner_id = {
    "dev"           = "",
    "staging"       = "",
    "production"    = "1eb2cd45-d39c-4caf-abd0-c5dcdfe6020b",
    "user-research" = ""
  }

  r53_healthcheck_cf_total_error_rate_id = {
    "dev"           = "",
    "staging"       = "",
    "production"    = "c5e532b5-adc1-4bb4-aec9-b9e13bbb01de",
    "user-research" = ""
  }

  r53_healthcheck_ddos_detection_id = {
    "dev"           = "",
    "staging"       = "",
    "production"    = "05dc08ae-bfb2-42ed-839e-51e7a54a82af",
    "user-research" = ""
  }

  r53_healthcheck_target_groups_ids = {
    "targetgroup/forms-api-dev/53e75a980b6d83b8"          = "51928116-633b-4c0f-8633-6d8a9d3bcd29",
    "targetgroup/forms-api-dev/53e75a980b6d83b8"          = "5c9e1db0-65c0-4dec-be6e-72ed7b567e3e",
    "targetgroup/forms-admin-dev/07b0e446fe4671b1"        = "7e57d00a-4955-44fb-beab-e29e8521ac48",
    "targetgroup/forms-admin-dev/07b0e446fe4671b1"        = "8109ab75-8806-4e17-996e-13c37714cd07",
    "targetgroup/forms-product-page-dev/869490357a5954a9" = "92932f00-9d4d-40f3-b500-7461ce1d16fd",
    "targetgroup/forms-runner-dev/1afc802c389b5ecd"       = "beff856c-b8b6-4f4f-ae37-e8b76347dfc9",
    "targetgroup/forms-product-page-dev/869490357a5954a9" = "dccc05e0-37a8-42b1-b9d9-58ce8640b03a",
    "targetgroup/forms-runner-dev/1afc802c389b5ecd"       = "eb7a7dba-09cc-4894-9bda-543a9529335f",

    "targetgroup/forms-runner-staging/35ed8db0a9d3eb23"       = "06e879d5-e47e-4470-882e-6dd630d33682",
    "targetgroup/forms-api-staging/15f135f4b9fe9d7b"          = "7b1c8da9-1301-4ac3-9929-5619723e385f",
    "targetgroup/forms-admin-staging/678d30a4ad301ffa"        = "7fde9f74-d3ed-4c80-969a-3abe754bed9f",
    "targetgroup/forms-product-page-staging/ee03581941444f0d" = "8ea7aa25-f4ba-4078-b7b8-152290d27920",

    "targetgroup/forms-admin-production/3f3c0ec1ec914bdb"        = "6b45455d-40c5-4413-b547-73fa3e902b56",
    "targetgroup/forms-runner-production/dc1ef6b38be73050"       = "80e4a620-ec0a-4e38-8507-6219cba3e0e4",
    "targetgroup/forms-product-page-production/eea72df3bd4e7081" = "d3b2b1fe-eab4-416b-a7fd-c1ed4b00ec65",
    "targetgroup/forms-api-production/c0855c3550515fa1"          = "f62c9108-ef7e-466e-9eac-c798c8f6e001",

    "targetgroup/forms-admin-user-research/9cc0df12e8ae4757"        = "07f42564-1ad1-4382-b7aa-00288ba909d9",
    "targetgroup/forms-runner-user-research/59e27ddab95ceb4a"       = "336156f1-8736-4ce1-b22e-c94811c609a7",
    "targetgroup/forms-api-user-research/e66b42ff23bdf221"          = "822a8833-829d-4bae-93de-d5c63db006f3",
    "targetgroup/forms-product-page-user-research/f905912c93f4e62d" = "ab95f22f-6221-489f-a05f-401ec25ccabc",
  }

  r53_healthcheck_aggregated_id = {
    "dev"           = "",
    "staging"       = "",
    "production"    = "5357ee7d-4b68-4900-a134-c28be0488de0",
    "user-research" = ""
  }
}

import {
  id = local.shield_cloudfront_protection_ids[var.environment_name]
  to = aws_shield_protection.cloudfront
}

import {
  id = local.shield_alb_protection_ids[var.environment_name]
  to = aws_shield_protection.alb
}

import {
  id = "shield-response-team"
  to = aws_iam_role.shield_response_team
}

import {
  id = "shield-response-team/arn:aws:iam::aws:policy/service-role/AWSShieldDRTAccessPolicy"
  to = aws_iam_role_policy_attachment.shield_response_team
}

import {
  id = local.shield_role_arn_association_ids[var.environment_name]
  to = aws_shield_drt_access_role_arn_association.shield_response_team
}

import {
  id = data.aws_s3_bucket.logs_bucket.bucket
  to = aws_shield_drt_access_log_bucket_association.alb_log_access
}

import {
  id = "shield-response-team:shield_response_team_alb_log_access"
  to = aws_iam_role_policy.alb_log_access
}

import {
  id = "Incoming-Traffic-Resources"
  to = aws_shield_protection_group.protected_resources
}

import {
  id = "/account/pagerduty-email"
  to = aws_ssm_parameter.pagerduty_email
}

import {
  id = "/account/pagerduty-phone-number"
  to = aws_ssm_parameter.pagerduty_phone_number
}

import {
  id = local.shield_proactive_engagement_ids[var.environment_name]
  to = aws_shield_proactive_engagement.escalation_contacts
}

import {
  for_each = var.environmental_settings.enable_shield_advanced_healthchecks ? [1] : []

  id = local.r53_healthcheck_api_id[var.environment_name]
  to = aws_route53_health_check.api[0]
}

import {
  for_each = var.environmental_settings.enable_shield_advanced_healthchecks ? [1] : []

  id = local.r53_healthcheck_admin_id[var.environment_name]
  to = aws_route53_health_check.admin[0]
}

import {
  for_each = var.environmental_settings.enable_shield_advanced_healthchecks ? [1] : []

  id = local.r53_healthcheck_product_page_id[var.environment_name]
  to = aws_route53_health_check.product_page[0]
}

import {
  for_each = var.environmental_settings.enable_shield_advanced_healthchecks ? [1] : []

  id = local.r53_healthcheck_runner_id[var.environment_name]
  to = aws_route53_health_check.runner[0]
}

import {
  provider = aws.us-east-1

  id = "${var.environment_name}_cloudfront_total_error_rate"
  to = aws_cloudwatch_metric_alarm.cloudfront_total_error_rate
}

import {
  for_each = var.environmental_settings.enable_shield_advanced_healthchecks ? [1] : []

  id = local.r53_healthcheck_cf_total_error_rate_id[var.environment_name]
  to = aws_route53_health_check.cloudfront_total_error_rate[0]
}

import {
  provider = aws.us-east-1

  id = "ddos_detected_in_${var.environment_name}"
  to = aws_cloudwatch_metric_alarm.ddos_detection
}

import {
  for_each = var.environmental_settings.enable_shield_advanced_healthchecks ? [1] : []

  id = local.r53_healthcheck_ddos_detection_id[var.environment_name]
  to = aws_route53_health_check.ddos_detection[0]
}

import {
  for_each = data.aws_lb_target_group.target_groups

  id = local.r53_healthcheck_target_groups_ids[substr(each.value.arn, 52, length(each.value.arn) - 52)]
  to = aws_route53_health_check.healthy_hosts[each.key]
}

import {
  for_each = var.environmental_settings.enable_shield_advanced_healthchecks ? [1] : []

  id = local.r53_healthcheck_aggregated_id[var.environment_name]
  to = aws_route53_health_check.aggregated[0]
}

import {
  for_each = var.environmental_settings.enable_shield_advanced_healthchecks ? [1] : []

  id = "${local.shield_cloudfront_protection_ids[var.environment_name]}+arn:aws:route53:::healthcheck/${local.r53_healthcheck_aggregated_id[var.environment_name]}"
  to = aws_shield_protection_health_check_association.system_health[0]
}

import {
  id = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/shield.amazonaws.com/AWSServiceRoleForAWSShield"
  to = aws_iam_service_linked_role.shield
}