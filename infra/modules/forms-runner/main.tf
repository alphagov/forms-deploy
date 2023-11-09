data "aws_caller_identity" "current" {}

data "aws_elasticache_replication_group" "forms_runner" {
  replication_group_id = "forms-runner-${var.env_name}"
}

locals {
  deploy_account_id           = "711966560482"
  maintenance_mode_bypass_ips = join(", ", module.common_values.vpn_ip_addresses)
}

module "common_values" {
  source = "../common-values"
}

data "aws_iam_policy_document" "ecs_task_role_permissions" {
  statement {
    actions = [
      "cloudwatch:PutMetricData"
    ]
    resources = ["*"]
    effect    = "Allow"
    condition {
      test     = "StringLike"
      variable = "cloudwatch:namespace"

      values = [
        "forms/${var.env_name}*"
      ]
    }
  }
}

module "ecs_service" {
  source                 = "../ecs-service"
  env_name               = var.env_name
  application            = "forms-runner"
  sub_domain             = "submit"
  image                  = "${local.deploy_account_id}.dkr.ecr.eu-west-2.amazonaws.com/forms-runner-deploy:${var.image_tag}"
  cpu                    = var.cpu
  memory                 = var.memory
  container_port         = 3000
  permit_internet_egress = true
  permit_redis_egress    = true

  scaling_rules = {
    min_capacity         = var.min_capacity
    max_capacity         = var.max_capacity
    cpu_usage_target_pct = 60
    scale_in_cooldown    = 180
    scale_out_cooldown   = 60
  }

  ecs_task_role_policy_json = data.aws_iam_policy_document.ecs_task_role_permissions.json

  environment_variables = [
    {
      name  = "REDIS_URL",
      value = "rediss://${data.aws_elasticache_replication_group.forms_runner.primary_endpoint_address}:${data.aws_elasticache_replication_group.forms_runner.port}"
    },
    {
      name  = "SETTINGS__FORMS_API__BASE_URL",
      value = var.api_base_url
    },
    {
      name  = "SETTINGS__FORMS_ADMIN__BASE_URL",
      value = var.admin_base_url
    },
    {
      name  = "RACK_ENV",
      value = "production"
    },
    {
      name  = "RAILS_LOG_TO_STDOUT",
      value = "true"
    },
    {
      name  = "RAILS_ENV",
      value = "production"
    },
    {
      name  = "RAILS_SERVE_STATIC_FILES",
      value = "1"
    },
    {
      name  = "RAILS_MAX_THREADS",
      value = var.rails_max_threads
    },
    {
      name  = "SENTRY_ENVIRONMENT",
      value = "aws-${var.env_name}"
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
      name  = "SETTINGS__FEATURES__EMAIL_CONFIRMATIONS_ENABLED",
      value = var.email_confirmations_enabled
    }
  ]

  secrets = [
    {
      name      = "SETTINGS__FORMS_API__AUTH_KEY",
      valueFrom = "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/forms-runner-${var.env_name}/forms-api-key"
    },
    {
      name      = "SETTINGS__GOVUK_NOTIFY__API_KEY",
      valueFrom = "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/forms-runner-${var.env_name}/notify-api-key"
    },
    {
      name      = "SETTINGS__SENTRY__DSN",
      valueFrom = "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/forms-runner-${var.env_name}/sentry/dsn"
    },
    {
      name      = "SECRET_KEY_BASE",
      valueFrom = "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/forms-runner-${var.env_name}/secret-key-base"
    }
  ]
}

