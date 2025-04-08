variable "role_suffix" {
  type        = string
  description = "The value to be used as a suffix on each role. This value will be prefixed with a dash, so it does not need to be included"
}

variable "email" {
  type        = string
  description = "The email address of the human who will use this role"
}

variable "iam_policy_arns" {
  type = list(any)
}

variable "ip_restrictions" {
  type    = list(string)
  default = []
}

variable "max_session_duration" {
  type        = number
  description = "(Optional) Maximum session duration (in seconds) that you want to set for the specified role. If you do not specify a value for this setting, the default maximum of one hour is applied. This setting can have a value from 1 hour to 12 hours."
  default     = 3600
}
