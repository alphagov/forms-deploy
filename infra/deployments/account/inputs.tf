variable "account_name" {
  type        = string
  description = "The name to be given to the account (e.g. dev, production)"
  nullable    = false
  validation {
    condition     = can(regex("^[A-Za-z-_]+$", var.account_name))
    error_message = "'account_name' may only contain alphaetic characters, dashes, and underscores"
  }
}

variable "aws_account_id" {
  type        = string
  description = "The AWS account ID for the account"
  nullable    = false
  validation {
    condition     = can(regex("^[0-9]{12}$", var.aws_account_id))
    error_message = "AWS account IDs are exactly 12 digits long"
  }
}

variable "environment_type" {
  type        = string
  description = "The type of environments the account will host."
  nullable    = false
  validation {
    condition     = contains(["development", "staging", "production", "user_research", "ithc"], var.environment_type)
    error_message = "variable 'environment_type' must be one of dev, staging, production, user_research, or ithc"
  }
}

variable "apex_domain" {
  type        = string
  description = "The apex domain that will be hosted in the account. For example 'forms.service.gov.uk', 'staging.forms.service.gov.uk'"
  nullable    = false
}

variable "dns_delegation_records" {
  type        = map(list(string))
  description = <<EOF
Any DNS delegation records to set within the apex domain's zone. T
his is used to allow the account hosting 'forms.service.gov.uk' to delegate subdomains to other accounts

The value is a map of string => list(string)

{
  "staging.forms.service.gov.uk" = ["ns1", "ns2", "n3"]
  "dev.forms.service.gov.uk" = ["ns4", "ns5", "ns6", "ns7"]
}
EOF
  default     = {}
  nullable    = false
}

variable "imports" {
  type        = map(string)
  description = "A map of resource path to resource ID to import into Terraform. This will be removed later."
}