data "aws_caller_identity" "current" {}

locals {
  image = var.image_tag == null ? null : "${var.container_repository}:${var.image_tag}"
}

module "ecs_service" {
  source                       = "../ecs-service"
  env_name                     = var.env_name
  application                  = "forms-api"
  root_domain                  = var.root_domain
  sub_domain                   = "api.${var.root_domain}"
  listener_priority            = 200
  include_domain_root_listener = false
  image                        = local.image
  cpu                          = var.cpu
  memory                       = var.memory
  container_port               = 9292
  permit_internet_egress       = true # Required for Sentry.io and AWS SSM
  permit_postgres_egress       = true
  vpc_id                       = var.vpc_id
  vpc_cidr_block               = var.vpc_cidr_block
  private_subnet_ids           = var.private_subnet_ids
  alb_arn_suffix               = var.alb_arn_suffix
  alb_listener_arn             = var.alb_listener_arn
  ecs_cluster_arn              = var.ecs_cluster_arn
  scaling_rules = {
    min_capacity                                = var.min_capacity
    max_capacity                                = var.max_capacity
    p95_response_time_scaling_threshold_seconds = 1
    scale_in_cooldown                           = 180
    scale_out_cooldown                          = 45
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
      name      = "SETTINGS__FORMS_API__AUTH_KEY",
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
}
