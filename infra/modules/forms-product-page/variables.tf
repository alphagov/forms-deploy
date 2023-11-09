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

variable "zendesk_subdomain" {
  description = "The Zendesk tenant the support form should create tickets on"
  default     = "govuk"
}

variable "admin_base_url" {
  description = "The url for redirecting to forms-admin"
  type        = string
}
