variable "env_name" {
  type        = string
  description = "The name of the environment to be used in resource names."
  validation {
    condition     = contains(["dev", "staging", "prod"], var.env_name)
    error_message = "Valid values for env_name are: dev, staging, prod"
  }
}

variable "mutable_image_tags" {
  type        = string
  description = "If true then image tags in ECR are muttable"
  default     = false
}
