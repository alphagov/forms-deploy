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

variable "cache_bucket" {
  type        = string
  default     = null
  description = "The S3 bucket to use for CodeBuild caching"
}

variable "cache_namespace" {
  type        = string
  default     = null
  description = "The namespace to use for CodeBuild caching. This determines the scope in which a cache is shared across multiple projects."

  validation {
    condition     = var.cache_namespace == null || var.cache_bucket != null
    error_message = "cache_bucket must be set when cache_namespace is provided"
  }
}
