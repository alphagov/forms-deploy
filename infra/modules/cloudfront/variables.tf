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

variable "domain_name" {
  type        = string
  description = "The domain name for the distribution"
}

variable "alb_dns_name" {
  type        = string
  description = "The alb dns name to use as the origin of the distribution"
}

variable "subject_alternative_names" {
  type        = list(string)
  description = "Alternative names for the distribution and its certificate"
}

variable "alarm_subscription_endpoint" {
  type        = string
  description = "Endpoint for alarm notifications from Cloudwatch"
}