variable "allowed_email_domains" {
  type        = set(string)
  description = "Allowed email domains"

  validation {
    condition = alltrue([
      for domain in var.allowed_email_domains : startswith(domain, ".") || startswith(domain, "@")
    ])
    error_message = "Allowed email domains must start with a dot (.) or an at symbol (@) to prevent name collisions."
  }

  validation {
    condition = alltrue([
      for domain in var.allowed_email_domains : lower(domain) == domain
    ])
    error_message = "Allowed email domains must be lowercase characters only."
  }
}

variable "admin_base_url" {
  type        = string
  description = "URL of the admin app"
}

variable "app_auth_path" {
  type    = string
  default = "/auth/auth0"
}

variable "app_auth_callback_path" {
  type    = string
  default = "/auth/auth0/callback"
}

variable "app_logo_path" {
  type    = string
  default = "/auth-widget-logo.svg"
}

variable "favicon_url_path" {
  type    = string
  default = "/auth-favicon.ico"
}

variable "idle_session_lifetime" {
  type        = number
  default     = 24
  description = "Number of hours for which a session can be inactive before the user must log in again."
}

variable "otp_expiry_length" {
  type        = number
  default     = 900
  description = "Number of seconds that a one time password is valid for."
}

variable "session_lifetime" {
  type        = number
  default     = 24
  description = "Number of hours a session will stay valid."
}

variable "env_name" {
  type        = string
  description = "The name of the environment to be used in resource names."
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

variable "support_url" {
  type        = string
  description = "URL of the support page"
}

variable "enable_splunk_log_stream" {
  type        = bool
  description = "Whether to enable streaming logs from Auth0 to Splunk."
  default     = false
}
