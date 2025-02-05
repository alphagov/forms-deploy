variable "environment_name" {
  description = "The name of the environment. This is distinct from the environment type, but is likely to share the same name in cases like production or staging."
  type        = string
  nullable    = false
  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]+$", var.environment_name))
    error_message = "variable 'environment_name' must contain only alphanumeric characters, underscores, and hyphens; it must be a valid part of a DNS name"
  }
}

variable "environment_type" {
  type        = string
  description = "The type of environment to be used."
}

variable "email_domain" {
  type        = string
  description = "The domain of the email address that emails are sent from."
}

variable "from_address" {
  type        = string
  description = "Address emails are sent from"
}

variable "hosted_zone_id" {
  description = "The ID of the AWS hosted zone in the account, to which DNS records live"
  type        = string
  nullable    = false
}
