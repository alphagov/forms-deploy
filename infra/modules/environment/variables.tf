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

variable "aws_shield_drt_access_role_arn" {
  type        = string
  description = "The role name for the AWS Shield DDoS Response Team (DRT)"
  default     = "shield-ddos-response-team"
}

variable "cloudwatch_alarm_region" {
  type        = string
  description = "The region in which the CloudWatch alarm is configured"
  default     = "eu-west-2"
}