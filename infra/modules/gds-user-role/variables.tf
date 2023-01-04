variable "role_suffix" {}

variable "email" {}

variable "iam_policy_arns" {
  type = list(any)
}

variable "restrict_to_gds_ips" {
  default = false
}

variable "max_session_duration" {
  type        = number
  default     = 3600
  description = "(Optional) Maximum session duration (in seconds) that you want to set for the specified role. If you do not specify a value for this setting, the default maximum of one hour is applied. This setting can have a value from 1 hour to 12 hours."
}
