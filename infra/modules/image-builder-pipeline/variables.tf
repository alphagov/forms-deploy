variable "application_name" {
  type        = string
  description = "The name of the application being built"
}
variable "container_repository" {
  type        = string
  description = "Name of the container repository to write to. Assumed to be in the same account"
}

variable "source_repository" {
  type        = string
  description = "Name of the source repository in GitHub from which to get the Dockerfile. E.g. alphagov/forms-deploy"

  validation {
    condition     = can(regex("[A-Za-z0-9-_]+/[A-Za-z0-9-_]+", var.source_repository))
    error_message = "Source repository must be in the form org/repo"
  }
}

variable "github_connection_arn" {
  type        = string
  description = "The ARN of the AWS CodeStar Connection used to communicate with GitHub"
  default     = "arn:aws:codestar-connections:eu-west-2:711966560482:connection/8ad08da2-743c-4431-bee6-ad1ae9efebe7"
}