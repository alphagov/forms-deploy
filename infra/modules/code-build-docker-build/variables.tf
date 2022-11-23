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

variable "artifact_store_arn" {
  type        = string
  description = "An S3 bucket arn where artifacts can be stored"
}
