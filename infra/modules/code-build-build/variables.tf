variable "environment" {
  type = string
}

variable "service_name" {
  type        = string
  description = "The name of the service"
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
