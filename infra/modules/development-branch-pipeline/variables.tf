variable "github_connection_arn" {
  type        = string
  description = "The arn of the github connection to use"
  default     = "arn:aws:codestar-connections:eu-west-2:711966560482:connection/8ad08da2-743c-4431-bee6-ad1ae9efebe7"
}

variable "source_branch" {
  type        = string
  description = "The branch name of the source_repo to use"
  default     = "main"
}

variable "forms_deploy_branch" {
  type        = string
  description = "The branch of forms-deploy to use"
  default     = "main"
}

variable "app_name" {
  type        = string
  description = "The name of the app to deploy"
}

variable "environment" {
  type        = string
  description = "The environment to deploy to"
}

