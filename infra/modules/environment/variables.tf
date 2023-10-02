variable "env_name" {
  type        = string
  description = "The name of the environment to be used in resource names."
  validation {
    condition     = contains(["user-research", "dev", "staging", "production"], var.env_name)
    error_message = "Valid values for env_name are: user-research, dev, staging, production"
  }
}

variable "ip_rate_limit" {
  type        = number
  description = "The maximum number of permitted requests from an IP address in a 5 minute period"
  default     = 1000
}

variable "enable_cloudfront" {
  type        = bool
  description = "If true then a cloudfront distribution is created."
  default     = true
}
