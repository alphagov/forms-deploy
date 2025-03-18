variable "env_name" {
  type        = string
  description = "The name of the environment to be used in resource names."
}

variable "environment_type" {
  type        = string
  description = "The type of environment the deployer-access role is being used in"
}

variable "hosted_zone_id" {
  description = "The ID of the AWS hosted zone in the account, to which DNS records will be added"
  type        = string
  nullable    = false
}

variable "codestar_connection_arn" {
  type        = string
  description = "ARN of the CodeStar connection in the account"
}

variable "dynamodb_state_file_locks_table_arn" {
  type        = string
  description = "The arn of the DynamoDB table being used for state file locking"
}
