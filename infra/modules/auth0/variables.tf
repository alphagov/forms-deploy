variable "admin_base_url" {
  type        = string
  description = "URL of the admin app"
}

variable "app_auth_callback_path" {
  type    = string
  default = "/auth/auth0/callback"
}

variable "app_logo_path" {
  type    = string
  default = "/auth-widget-logo.svg"
}

variable "env_name" {
  type        = string
  description = "The name of the environment to be used in resource names."

  validation {
    condition     = contains(["user-research", "dev", "staging", "production"], var.env_name)
    error_message = "Valid values for env_name are: user-research, dev, staging, production"
  }
}
