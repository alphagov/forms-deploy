variable "env_name" {
  type        = string
  description = "The name of the environment to be used in resource names."

  validation {
    condition     = contains(["user-research", "dev", "staging", "production"], var.env_name)
    error_message = "Valid values for env_name are: user-research, dev, staging, production"
  }
}

variable "secret_kind" {
  type = string

  default = "tmp/"

  validation {
    condition   = contains(["","tmp/", "perm/"], var.secret_kind)
    error_message = "Valid values for secret_kind are: tmp/, perm/"
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

variable "govuk_app_domain" {
  description = "The domain name for the Signon integration for auth flow"
  type        = string
  default     = ""
}

variable "enable_maintenance_mode" {
  description = "Controls whether the maintenance page is shown"
  type        = bool
}

variable "maintenance_mode_bypass_ips" {
  description = "List of IP addresses which will bypass the maintenance mode message"
  type        = string
  default     = "213.86.153.211/32, 213.86.153.212/32, 213.86.153.213/32,213.86.153.214/32, 213.86.153.231/32, 213.86.153.235/32, 213.86.153.236/32, 213.86.153.237/32, 51.149.8.0/25, 51.149.8.128/29, 51.149.9.112/29, 51.149.9.240/29"
}

variable "details_guidance_feature_flag" {
  description = "Toggles on/off the detailed guidance feature"
  type        = bool
  default     = false
}
