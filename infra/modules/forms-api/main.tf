data "aws_caller_identity" "current" {}

locals {
  deploy_account_id = "711966560482"
}

module "ecs_service" {
  source                 = "../ecs-service"
  env_name               = var.env_name
  application            = "forms-api"
  sub_domain             = "api"
  image                  = "${local.deploy_account_id}.dkr.ecr.eu-west-2.amazonaws.com/forms-api-deploy:${var.image_tag}"
  cpu                    = var.cpu
  memory                 = var.memory
  container_port         = 9292
  permit_internet_egress = true # Required for Sentry.io and AWS SSM
  permit_postgres_egress = true

  scaling_rules = {
    min_capacity         = var.min_capacity
    max_capacity         = var.max_capacity
    cpu_usage_target_pct = 50
    scale_in_cooldown    = 180
    scale_out_cooldown   = 45
  }

  environment_variables = [
    {
      name  = "RACK_ENV",
      value = "production"
    },
    {
      name  = "RAILS_ENV",
      value = "production"
    },
    {
      name  = "RAILS_LOG_TO_STDOUT",
      value = "true"
    },
    {
      name  = "SETTINGS__SENTRY__ENVIRONMENT",
      value = "aws-${var.env_name}"
    },
    {
      name  = "SETTINGS__FORMS_ENV",
      value = var.env_name
    },
  ]

  secrets = [
    {
      name      = "SETTINGS__FORMS_API__AUTHENTICATION_KEY",
      valueFrom = "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/forms-api-${var.env_name}/forms-api-key"
    },
    {
      name      = "DATABASE_URL",
      valueFrom = "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/forms-api-${var.env_name}/database/url"
    },
    {
      name      = "SETTINGS__SENTRY__DSN",
      valueFrom = "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/forms-api-${var.env_name}/sentry/dsn"
    },
    {
      name      = "SECRET_KEY_BASE",
      valueFrom = "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/forms-api-${var.env_name}/secret-key-base"
    }
  ]

  pre_deploy_script = abspath("${path.module}/../shared/scripts/db-migrations-pre-deploy.sh")
}

