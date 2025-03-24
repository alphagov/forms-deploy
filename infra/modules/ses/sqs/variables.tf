variable "environment_name" {
  description = "The name of the environment. This is distinct from the environment type, but is likely to share the same name in cases like production or staging."
  type        = string
  nullable    = false
  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]+$", var.environment_name))
    error_message = "variable 'environment_name' must contain only alphanumeric characters, underscores, and hyphens; it must be a valid part of a DNS name"
  }
}

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

variable "sqs_type" {
  type        = string
  description = "The type of queue, used for naming the resources."
}
