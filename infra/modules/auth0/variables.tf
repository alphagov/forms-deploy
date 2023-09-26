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

variable "smtp_password" {
  type        = string
  description = "The password for the smtp user."
}

variable "smtp_username" {
  type        = string
  description = "The username of the smtp user."
}

variable "smtp_host" {
  type        = string
  description = "The hostname of the smtp server."
  default     = "email-smtp.eu-west-2.amazonaws.com"
}

variable "smtp_port" {
  type        = number
  description = "The port used by the smtp server."
  default     = 587
}

variable "smtp_from_address" {
  type        = string
  description = "The email address you want to send from."
}