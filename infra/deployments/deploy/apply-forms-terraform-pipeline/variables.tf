variable "environment_name" {
  description = "The name of the environment. This is distinct from the environment type, but is likely to share the same name in cases like production or staging."
  type        = string
  nullable    = false
  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]+$", var.environment_name))
    error_message = "variable 'environment_name' must contain only alphanumeric characters, underscores, and hyphens; it must be a valid part of a DNS name"
  }
}

variable "branch_name" {
  description = "The name of the default branch you want to deploy from."
  type        = string
  default     = "main"
  nullable    = false
}

variable "detect_changes" {
  description = "whether or not to trigger the pipeline on changes to the source repo"
  type        = bool
  nullable    = false
}

variable "github_connection_arn" {
  type        = string
  description = "The arn of the github connection"
  default     = "arn:aws:codestar-connections:eu-west-2:711966560482:connection/8ad08da2-743c-4431-bee6-ad1ae9efebe7"
}