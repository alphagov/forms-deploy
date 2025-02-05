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
