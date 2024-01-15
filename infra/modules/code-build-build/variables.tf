variable "project_name" {
  type        = string
  nullable    = false
  description = "The name to give to the CodeBuild project"
}

variable "project_description" {
  type        = string
  nullable    = false
  description = "Description of the purpose of the CodeBuild project"
}


variable "environment" {
  type = string
}

variable "artifact_store_arn" {
  type        = string
  description = "An S3 bucket arn where artifacts can be stored"
}

variable "github_connection_arn" {
  type        = string
  description = "The arn of the github connection to use"
  default     = "arn:aws:codestar-connections:eu-west-2:711966560482:connection/8ad08da2-743c-4431-bee6-ad1ae9efebe7"
}

variable "environment_variables" {
  type        = map(string)
  default     = {}
  description = "Environment variables used by codebuild"
}

variable "buildspec" {
  type        = string
  description = "The path to the build specification (buildspec file)"
}

variable "codebuild_service_role_arn" {
  type        = string
  nullable    = false
  description = "ARN of the role which CodeBuild will assume"
}

variable "log_group_name" {
  type        = string
  nullable    = false
  description = "The name to give the log group which will hold the logs of the codebuild project"

  validation {
    condition     = can(regex("^codebuild/.*$", var.log_group_name))
    error_message = "Log group names must start with 'codebuild/'"
  }
}