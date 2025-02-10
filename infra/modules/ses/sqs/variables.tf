variable "environment_type" {
  type        = string
  description = "The type of environment to be used."
}

variable "account_id" {
  type        = string
  description = "The current account id."
}

variable "identifier" {
  type        = string
  description = "The identifier of sqs. This is used in the naming of the resources."
}

variable "policy_id" {
  type        = string
  description = "The name to be used for the policy id."
}
