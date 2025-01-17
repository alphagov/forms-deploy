variable "account_name" {
  type        = string
  description = "The name to be given to the account (e.g. dev, production)"
  nullable    = false
  validation {
    condition     = can(regex("^[A-Za-z-_]+$", var.account_name))
    error_message = "'account_name' may only contain alphabetic characters, dashes, and underscores"
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

variable "bucket" {
  description = "Name of the state file bucket. This is named to match the key in the S3 type backend"
  type        = string
  nullable    = false
}

variable "dynamodb_table" {
  description = "Name of the DynamoDB table used for state file locking. This is named to match the key in the S3 type backend"
  type        = string
  nullable    = false
}

variable "require_vpn_to_access" {
  type        = bool
  description = "Whether this AWS account will require users to be on the VPN to access it"
  nullable    = false
  default     = true
}

variable "codestar_connection_arn" {
  description = "It isn't possible to automate the creation of a CodeStar connection, so we must create it by hand once in each account and hardcode its ARN."
  type        = string
  nullable    = false
}

variable "deploy_account_id" {
  description = "the account number for deploy account"
  type        = string
  nullable    = false
}
