data "aws_caller_identity" "current" {}

locals {
  deploy_account_id = "711966560482"
  image = var.image_tag == null? null : "${local.deploy_account_id}.dkr.ecr.eu-west-2.amazonaws.com/forms-product-page-deploy:${var.image_tag}"
}

module "ecs_service" {
  source                 = "../ecs-service"
  env_name               = var.env_name
  application            = "forms-product-page"
  sub_domain             = "www"
  image                  = local.image
  cpu                    = var.cpu
  memory                 = var.memory
  container_port         = 3000
  permit_internet_egress = true # Required for Sentry.io and AWS SSM
  permit_postgres_egress = true

  scaling_rules = {
    min_capacity                                = var.min_capacity
    max_capacity                                = var.max_capacity
    p95_response_time_scaling_threshold_seconds = 1
    scale_in_cooldown                           = 180
    scale_out_cooldown                          = 60
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
      name  = "RAILS_SERVE_STATIC_FILES",
      value = "1"
    },
    {
      name  = "SETTINGS__SENTRY__ENVIRONMENT",
      value = "aws-${var.env_name}"
    },
    {
      name  = "SETTINGS__FORMS_ENV",
      value = var.env_name
    },
    {
      name  = "SETTINGS__ZENDESK__SUBDOMAIN",
      value = var.zendesk_subdomain
    },
    {
      name  = "SETTINGS__FORMS_ADMIN__BASE_URL",
      value = var.admin_base_url
    },
  ]

  secrets = [
    {
      name      = "SETTINGS__SENTRY__DSN",
      valueFrom = "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/forms-product-page-${var.env_name}/sentry/dsn"
    },
    {
      name      = "SETTINGS__ZENDESK__API_USER",
      valueFrom = "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/forms-product-page-${var.env_name}/zendesk/api-user"
    },
    {
      name      = "SETTINGS__ZENDESK__API_TOKEN",
      valueFrom = "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/forms-product-page-${var.env_name}/zendesk/api-token"
    },
    {
      name      = "SECRET_KEY_BASE",
      valueFrom = "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/forms-product-page-${var.env_name}/secret-key-base"
    },
  ]
}

