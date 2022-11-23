variable "github_connection_arn" {
  type        = string
  description = "The arn of the github connection to use"
  default     = "arn:aws:codestar-connections:eu-west-2:711966560482:connection/8ad08da2-743c-4431-bee6-ad1ae9efebe7"
}

variable "development_deployer_role_arn" {
  type        = string
  description = "The role arn to use when deploying to development environment"
}

variable "terraform_deployment" {
  type        = string
  description = "A directory under forms-deploy/infra/deployments/*/"
}

variable "source_repo" {
  type        = string
  description = "The github repo containing the source code and docker file to build"
}

variable "source_branch" {
  type        = string
  description = "The branch name of the source_repo to use"
  default     = "main"
}

variable "image_name" {
  type        = string
  description = "The name of the image without the tag, e.g. forms-api"
}
