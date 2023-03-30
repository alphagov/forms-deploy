variable "environment" {
  type        = string
  description = "The name of the environment to be used in resource names."
  validation {
    condition     = contains(["user-research", "dev", "staging", "production"], var.environment)
    error_message = "Valid values for env_name are: user-research, dev, staging, production"
  }
}

variable "minimum_healthy_host_count" {
  type        = number
  description = "Alert will trigger if the minimum healthy host count for any ECS service drops below this number. Leaving at 0 effectively disables this alert."
  default     = 0
}
