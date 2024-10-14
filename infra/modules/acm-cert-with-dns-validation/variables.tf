variable "domain_name" {
  type        = string
  description = "The primary domain name for the certificate"
}

variable "subject_alternative_names" {
  type        = list(string)
  description = "Subject alternative names for the certificate. Must be within the same domain as domain_name"
}
