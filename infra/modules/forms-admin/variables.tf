variable "env_name" {
  type        = string
  description = "The name of the environment to be used in resource names."

  validation {
    condition     = contains(["user-research", "dev", "staging", "production"], var.env_name)
    error_message = "Valid values for env_name are: user-research, dev, staging, production"
  }
}

variable "image_tag" {
  type = string
}

variable "cpu" {
  type = number
}

variable "memory" {
  type = number
}

variable "api_base_url" {
  description = "The url for connecting to forms-api"
  type        = string
}

variable "runner_base" {
  description = "The url for redirecting to forms-runner"
  type        = string
}

variable "auth_provider" {
  description = "Controls how users are authenticated"
  type        = string
  default     = "gds_sso"
}

variable "previous_auth_provider" {
  description = "The previous auth provider changing to preserve env vars and allow users to logout"
  type        = string
  default     = ""
}

variable "govuk_app_domain" {
  description = "The domain name for the Signon integration for auth flow"
  type        = string
  default     = ""
}

variable "enable_maintenance_mode" {
  description = "Controls whether the maintenance page is shown"
  type        = bool
}

variable "metrics_feature_flag" {
  description = "Toggles on/off the metrics for form creators feature"
  type        = bool
  default     = false
}

variable "email_confirmations_feature_flag" {
  description = "Toggles on/off the email confirmations feature"
  type        = bool
  default     = false
}

variable "forms_product_page_support_url" {
  description = "Sets the support URL for the product page"
  type        = string
  default     = ""
}

variable "min_capacity" {
  description = "Sets the minimum number of instances"
  type        = number
}

variable "max_capacity" {
  description = "Sets the maximum number of instances"
  type        = number
}

variable "cloudwatch_metrics_enabled" {
  description = "Enables metrics being sent to CloudWatch"
  type        = bool
  default     = false
}