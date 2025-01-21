variable "environment_name" {
  description = "The name of the environment. This is distinct from the environment type, but is likely to share the same name in cases like production or staging."
  type        = string
  nullable    = false
  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]+$", var.environment_name))
    error_message = "variable 'environment_name' must contain only alphanumeric characters, underscores, and hyphens; it must be a valid part of a DNS name"
  }
}

variable "ips_to_block" {
  type        = list(string)
  description = "List of Origin IPs to block"
  default     = []
}

variable "ip_rate_limit" {
  type        = number
  description = "The maximum number of permitted requests from an IP address in a 5 minute period"
  default     = 1000
}

variable "nat_gateway_egress_ips" {
  type        = list(string)
  description = "The IP addresses of all the NAT gateways used for traffic to exit the GOV.UK Forms VPC"
}
