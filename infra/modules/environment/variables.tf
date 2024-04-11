variable "env_name" {
  type        = string
  description = "The name of the environment to be used in resource names."
}

variable "ip_rate_limit" {
  type        = number
  description = "The maximum number of permitted requests from an IP address in a 5 minute period"
  default     = 1000
}

variable "ips_to_block" {
  type        = list(string)
  description = "List of Origin IPs to block"
  default     = []
}

variable "enable_cloudfront" {
  type        = bool
  description = "If true then a cloudfront distribution is created."
  default     = true
}

variable "enable_alert_actions" {
  type        = bool
  description = "Whether any actions associated with CloudWatch alarms should be enabled"
  default     = true
}

variable "enable_shield_advanced" {
  type        = bool
  description = "Whether Shield Advanced functionality should be enabled (must only be true for production)"
  default     = false
}