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

variable "desired_task_count" {
  description = "How many tasks should run"
  type        = number
  default     = 2
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

variable "details_guidance_feature_flag" {
  description = "Toggles on/off the detailed guidance feature"
  type        = bool
  default     = false
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
