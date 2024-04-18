variable "env_name" {
  type        = string
  description = "The name of the environment to be used in resource names."
}

variable "env_type" {
  type        = string
  description = "The type of environment this is. For example 'dev', 'staging', 'productions'."
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

variable "enable_shield_advanced_healthchecks" {
  type        = bool
  description = "Whether Shield Advanced healthchecks should be enabled (must only be true for production)"
}

variable "scheduled_smoke_tests_settings" {
  description = "Configuration for the scheduled smoke tests"
  type = object({
    enable_scheduled_smoke_tests = bool
    # This form is created specifically for the runner smoke tests. See https://github.com/alphagov/forms-e2e-tests/blob/main/spec/smoke_tests/smoke_test_runner_spec.rb
    form_url          = string
    frequency_minutes = number
    enable_alerting   = bool # Whether to send notification to govuk-forms-alerts channel
  })
}