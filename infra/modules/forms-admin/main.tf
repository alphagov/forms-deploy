data "aws_caller_identity" "current" {}

locals {
  deploy_account_id = "711966560482"
}

module "ecs_service" {
  source                 = "../ecs-service"
  env_name               = var.env_name
  application            = "forms-admin"
  sub_domain             = "admin"
  desired_task_count     = var.desired_task_count
  image                  = "${local.deploy_account_id}.dkr.ecr.eu-west-2.amazonaws.com/forms-admin-deploy:${var.image_tag}"
  cpu                    = var.cpu
  memory                 = var.memory
  container_port         = 3000
  permit_internet_egress = true
  permit_postgres_egress = true

  environment_variables = [
    {
      name  = "API_BASE",
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
      name  = "SECRET_KEY_BASE",
      value = "something"
    },
    {
      name  = "RAILS_SERVE_STATIC_FILES",
      value = "1"
    },
    {
      name  = "RUNNER_BASE",
      value = var.runner_base
    },
    {
      name  = "GOVUK_APP_DOMAIN",
      value = var.govuk_app_domain
    }
  ]

  secrets = [
    {
      name      = "API_KEY",
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
      name      = "GDS_SSO_OAUTH_ID",
      valueFrom = "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/forms-admin-${var.env_name}/gds-sso-oauth-id"
    },
    {
      name      = "GDS_SSO_OAUTH_SECRET",
      valueFrom = "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/forms-admin-${var.env_name}/gds-sso-oauth-secret"
    }
  ]
}

