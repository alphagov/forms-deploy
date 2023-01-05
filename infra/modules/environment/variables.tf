variable "env_name" {
  type        = string
  description = "The name of the environment to be used in resource names."
  validation {
    condition     = contains(["dev", "staging", "production"], var.env_name)
    error_message = "Valid values for env_name are: dev, staging, production"
  }
}
