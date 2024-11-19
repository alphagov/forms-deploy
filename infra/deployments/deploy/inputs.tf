variable "deploy_account_id" {
  description = "the account number for deploy account"
  type        = string
  default     = "711966560482"
}

variable "codestar_connection_arn" {
  description = "the arn of the github connection to use"
  type        = string
  default     = "arn:aws:codestar-connections:eu-west-2:711966560482:connection/8ad08da2-743c-4431-bee6-ad1ae9efebe7"
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