variable "verified_email_addresses" {
  type        = set(string)
  description = "Email addresses to verify. In SES sandbox emails can only be sent to verified email addresses and domains."
  default     = []
}
