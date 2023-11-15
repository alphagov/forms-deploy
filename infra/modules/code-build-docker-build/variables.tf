variable "project_name" {
  type        = string
  description = "The name of the code build project"
}

variable "project_description" {
  type        = string
  description = "The description of the code build project"
}

variable "build_directory" {
  type        = string
  description = "The directory with the Dockerfile to be built"
  default     = "."
}

variable "image_name" {
  type        = string
  description = "The name of the image excluding its tag"
}

variable "image_tag" {
  type        = string
  description = "The image tag to use. Alternatively the GIT SHA and epoch timestamp will be used"
  default     = ""
}

variable "tag_prefix" {
  type        = string
  description = "Optional image tag prefix"
  default     = ""
}

variable "artifact_store_arn" {
  type        = string
  description = "An S3 bucket arn where artifacts can be stored"
}

variable "docker_username_parameter_path" {
  type        = string
  description = "The path to a secure string with the docker username"
}

variable "docker_password_parameter_path" {
  type        = string
  description = "The path to a secure string with the docker password"
}

variable "code_build_project_image" {
  type        = string
  description = "The docker image to use to run the CodeBuild project"
  default     = "aws/codebuild/amazonlinux2-aarch64-standard:3.0"
}

variable "code_build_project_compute_size" {
  type        = string
  description = "The compute size to use for the CodeBuild project"
  default     = "BUILD_GENERAL1_LARGE"
}

variable "code_build_project_compute_arch" {
  type        = string
  description = "The archecture of the container"
  default     = "ARM_CONTAINER"
}

variable "github_connection_arn" {
  type        = string
  description = "The arn of the github connection to use"
  default     = "arn:aws:codestar-connections:eu-west-2:711966560482:connection/8ad08da2-743c-4431-bee6-ad1ae9efebe7"
}

variable "extra_env_vars" {
  type        = list(map(string))
  description = "Additinal environment variables to set in the container"
  default     = []
}
