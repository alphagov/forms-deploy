variable "verified_email_addresses" {
  type        = set(string)
  description = "Email addresses to verify. In SES sandbox emails can only be sent to verified email addresses and domains."
  default     = []
}

variable "from_address" {
  type        = string
  description = "Address emails are sent from"
}

variable "environment" {
  type        = string
  description = "The name of the environment to be used in resource names."
  validation {
    condition     = contains(["user-research", "dev", "staging", "production"], var.environment)
    error_message = "Valid values for env_name are: user-research, dev, staging, production"
  }
}
