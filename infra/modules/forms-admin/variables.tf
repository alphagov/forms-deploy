variable "env_name" {
  type        = string
  description = "The name of the environment to be used in resource names."
}

variable "image_tag" {
  type     = string
  nullable = true
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

variable "submission_email_changed_feature_flag" {
  description = "Toggles on/off the notify submission email changed feature"
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

variable "reference_numbers_enabled" {
  description = "Enables reference number content"
  type        = bool
  default     = false
}

variable "enable_mailchimp_sync" {
  description = "Whether to synchronise the MailChimp mailing lists from the forms-admin user data"
  type        = bool
  default     = false
}
