##
# Naming
##
variable "environment_type" {
  description = "The type of environment this is. For example 'dev', 'staging', 'productions'."
  type        = string
  nullable    = false
  validation {
    condition     = contains(["development", "staging", "production", "user_research", "ithc"], var.environment_type)
    error_message = "variable 'environment_type' must be one of dev, staging, production, user_research, or ithc"
  }
}

variable "environment_name" {
  description = "The name of the environment. This is distinct from the environment type, but is likely to share the same name in cases like production or staging."
  type        = string
  nullable    = false
  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]+$", var.environment_name))
    error_message = "variable 'environment_name' must contain only alphanumeric characters, underscores, and hyphens; it must be a valid part of a DNS name"
  }
}

##
# Infra
##
variable "codestar_connection_arn" {
  description = "It isn't possible to automate the creation of a CodeStar connection, so we must create it by hand once in each account and hardcode its ARN."
  type        = string
  nullable    = false
}

variable "container_repository" {
  description = "The container repository from which images should be pulled"
  type        = string
  nullable    = false
}

##
# AWS provider
##
variable "allowed_account_ids" {
  description = <<EOF
The list of AWS account ids to be allowed for this Terraform application.
This prevents us from applying one environment configuration to the wrong account(s)."
EOF
  type        = list(string)
  nullable    = false
}

variable "default_tags" {
  description = "The set of tags which should be attached to every resource by default."
  type        = map(string)
  nullable    = false
}

##
# DNS
##
variable "root_domain" {
  description = "The root domain under which the environment will be deployed"
  type        = string
  nullable    = false
}

variable "cloudfront_distribution_id" {
  description = "The ID of the cloudfront distribution to point the domins at"
  type        = string
  nullable    = false
}

variable "hosted_zone_id" {
  description = "The ID of the AWS hosted zone in the account, to which DNS records will be added"
  type        = string
  nullable    = false
}

##
# Settings
##
variable "forms_admin_settings" {
  description = "Forms Admin configuration values"
  type = object({
    cpu                                   = number
    memory                                = number
    min_capacity                          = number
    max_capacity                          = number
    enable_maintenance_mode               = bool
    metrics_feature_flag                  = bool
    submission_email_changed_feature_flag = bool
    auth_provider                         = string
    previous_auth_provider                = string
    cloudwatch_metrics_enabled            = bool
    govuk_app_domain                      = string
    payment_links                         = bool
    reference_numbers_enabled             = bool
  })
  nullable = false
}

variable "forms_api_settings" {
  description = "Forms API configuration values"
  type = object({
    cpu          = number
    memory       = number
    min_capacity = number
    max_capacity = number
  })
  nullable = false
}

variable "forms_product_page_settings" {
  description = "Forms Product Page configuration values"
  type = object({
    cpu          = number
    memory       = number
    min_capacity = number
    max_capacity = number
  })
}

variable "forms_runner_settings" {
  description = "Forms Runner configuration values"
  type = object({
    cpu                        = number
    memory                     = number
    min_capacity               = number
    max_capacity               = number
    enable_maintenance_mode    = bool
    cloudwatch_metrics_enabled = bool
    reference_numbers_enabled  = bool
  })
}

variable "environmental_settings" {
  description = "Configuration values for the environment. The types of settings that affect the environment as a whole, and aren't specific to one application."
  type = object({
    auth0_domain                             = string
    disable_auth0                            = bool
    pause_databases_on_inactivity            = bool
    pause_databases_after_inactivity_seconds = number
    database_backup_retention_period_days    = number
    allow_authentication_from_email_domains  = list(string)
    enable_alert_actions                     = bool
    forms_product_page_support_url           = string
    rds_maintenance_window                   = string
    redis_backup_retention_period_days       = optional(number)
    ips_to_block                             = list(string)
  })
}
