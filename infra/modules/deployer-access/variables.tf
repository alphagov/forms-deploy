variable "environment_name" {
  type        = string
  description = "The name of the environment to be used in resource names."
}

variable "environment_type" {
  type        = string
  description = "The type of environment the deployer-access role is being used in"
}

variable "account_id" {
  type        = string
  description = "The id of the account into which this environment is deployed"
}

variable "deploy_account_id" {
  type        = string
  description = "The id of the deploy account to make reference to"
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
