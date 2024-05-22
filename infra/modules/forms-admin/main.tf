data "aws_caller_identity" "current" {}
locals {
  deploy_account_id           = "711966560482"
  image                       = var.image_tag == null ? null : "${local.deploy_account_id}.dkr.ecr.eu-west-2.amazonaws.com/forms-admin-deploy:${var.image_tag}"
  maintenance_mode_bypass_ips = join(", ", module.common_values.vpn_ip_addresses)
  auth_credentials = {
    _ = [], # just in case we have a "null" previous auth provider
    basic_auth = [
      {
        name      = "SETTINGS__BASIC_AUTH__USERNAME",
        valueFrom = "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/forms-admin-${var.env_name}/basic-auth/username"
      },
      {
        name      = "SETTINGS__BASIC_AUTH__PASSWORD",
        valueFrom = "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/forms-admin-${var.env_name}/basic-auth/password"
      }
    ],
    gds_sso = [
      {
        name      = "GDS_SSO_OAUTH_ID",
        valueFrom = "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/forms-admin-${var.env_name}/gds-sso-oauth-id"
      },
      {
        name      = "GDS_SSO_OAUTH_SECRET",
        valueFrom = "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/forms-admin-${var.env_name}/gds-sso-oauth-secret"
      }
    ],
    cddo_sso = [
      {
        name      = "SETTINGS__CDDO_SSO__IDENTIFIER",
        valueFrom = "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/forms-admin-${var.env_name}/cddo-sso/identifier"
      },
      {
        name      = "SETTINGS__CDDO_SSO__SECRET",
        valueFrom = "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/forms-admin-${var.env_name}/cddo-sso/secret"
      }
    ],
    auth0 = [
      {
        name      = "SETTINGS__AUTH0__CLIENT_ID",
        valueFrom = "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/forms-admin-${var.env_name}/auth0/client-id"
      },
      {
        name      = "SETTINGS__AUTH0__CLIENT_SECRET",
        valueFrom = "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/forms-admin-${var.env_name}/auth0/client-secret"
      },
      {
        name      = "SETTINGS__AUTH0__E2E_CLIENT_ID",
        valueFrom = "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/forms-admin-${var.env_name}/auth0/e2e-client-id"
      },
      {
        name      = "SETTINGS__AUTH0__E2E_CLIENT_SECRET",
        valueFrom = "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/forms-admin-${var.env_name}/auth0/e2e-client-secret"
      },
      {
        name      = "SETTINGS__AUTH0__DOMAIN",
        valueFrom = "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/forms-admin-${var.env_name}/auth0/domain"
      }
    ]
  }

}

module "common_values" {
  source = "../common-values"
}

data "aws_iam_policy_document" "ecs_task_role_permissions" {
  statement {
    actions = [
      "cloudwatch:GetMetricStatistics"
    ]
    resources = ["*"]
    effect    = "Allow"
  }
}

module "ecs_service" {
  source                 = "../ecs-service"
  env_name               = var.env_name
  application            = "forms-admin"
  sub_domain             = "admin"
  image                  = local.image
  cpu                    = var.cpu
  memory                 = var.memory
  container_port         = 3000
  permit_internet_egress = true
  permit_postgres_egress = true

  scaling_rules = {
    min_capacity                                = var.min_capacity
    max_capacity                                = var.max_capacity
    p95_response_time_scaling_threshold_seconds = 1
    scale_in_cooldown                           = 180
    scale_out_cooldown                          = 60
  }

  ecs_task_role_policy_json = data.aws_iam_policy_document.ecs_task_role_permissions.json

  environment_variables = [
    {
      name  = "SETTINGS__FORMS_API__BASE_URL",
      value = var.api_base_url
    },
    {
      name  = "RAILS_LOG_TO_STDOUT",
      value = "true"
    },
    {
      name  = "RACK_ENV",
      value = "production"
    },
    {
      name  = "RAILS_ENV",
      value = "production"
    },
    {
      name  = "SETTINGS__FORMS_RUNNER__URL",
      value = var.runner_base
    },
    {
      name  = "SETTINGS__AUTH_PROVIDER",
      value = var.auth_provider
    },
    {
      name  = "GOVUK_APP_DOMAIN",
      value = var.govuk_app_domain
    },
    {
      name  = "SETTINGS__SENTRY__ENVIRONMENT",
      value = "aws-${var.env_name}"
    },
    {
      name  = "SETTINGS__MAINTENANCE_MODE__ENABLED",
      value = var.enable_maintenance_mode
    },
    {
      name  = "SETTINGS__MAINTENANCE_MODE__BYPASS_IPS",
      value = local.maintenance_mode_bypass_ips
    },
    {
      name  = "SETTINGS__FORMS_ENV",
      value = var.env_name
    },
    {
      name  = "SETTINGS__FEATURES__METRICS_FOR_FORM_CREATORS_ENABLED",
      value = var.metrics_feature_flag
    },
    {
      name  = "SETTINGS__FEATURES__NOTIFY_ORIGINAL_SUBMISSION_EMAIL_OF_CHANGE",
      value = var.submission_email_changed_feature_flag
    },
    {
      name  = "SETTINGS__FORMS_PRODUCT_PAGE__SUPPORT_URL",
      value = var.forms_product_page_support_url
    },
    {
      name  = "SETTINGS__CLOUDWATCH_METRICS_ENABLED",
      value = var.cloudwatch_metrics_enabled
    },
    {
      name  = "SETTINGS__FEATURES__GROUPS",
      value = var.groups_enabled
    },
  ]

  secrets = flatten([
    {
      name      = "SETTINGS__FORMS_API__AUTH_KEY",
      valueFrom = "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/forms-admin-${var.env_name}/forms-api-key"
    },
    {
      name      = "SETTINGS__GOVUK_NOTIFY__API_KEY",
      valueFrom = "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/forms-admin-${var.env_name}/notify-api-key"
    },
    {
      name      = "DATABASE_URL",
      valueFrom = "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/forms-admin-${var.env_name}/database/url"
    },
    {
      name      = "SETTINGS__SENTRY__DSN",
      valueFrom = "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/forms-admin-${var.env_name}/sentry/dsn"
    },
    {
      name      = "SECRET_KEY_BASE",
      valueFrom = "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/forms-admin-${var.env_name}/secret-key-base"
    },
    {
      name      = "SETTINGS__MAILCHIMP__API_KEY"
      valueFrom = aws_ssm_parameter.mailchimp_api_key.arn
    },
    lookup(local.auth_credentials, var.auth_provider, []),
    lookup(local.auth_credentials, coalesce(var.previous_auth_provider, "_"), [])
  ])
}
