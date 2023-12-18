variable "environment" {
  type        = string
  description = "The name of the environment to be used in resource names."
}

variable "email_domain" {
  type        = string
  description = "The domain of the email address that emails are sent from."
}

variable "from_address" {
  type        = string
  description = "Address emails are sent from"
}

variable "verified_email_addresses" {
  type        = set(string)
  description = "Email addresses to verify. In SES sandbox emails can only be sent to verified email addresses and domains."
  default     = []
}
