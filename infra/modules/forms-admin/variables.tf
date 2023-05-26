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

variable "govuk_app_domain" {
  description = "The domain name for the Signon integration for auth flow"
  type        = string
  default     = ""
}

variable "enable_basic_auth" {
  description = "Controls if basic auth should be used."
  type        = bool
  default     = false
}
variable "enable_basic_routing" {
  description = "Controls if basic routing feature should be used."
  type        = bool
  default     = false
}
