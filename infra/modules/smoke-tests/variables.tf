variable "environment" {
  type = string
}

variable "smoke_test_form_url" {
  description = "The url for form to use in smoke test"
  type        = string
}

variable "smoke_tests_frequency_minutes" {
  description = "How often the scheduled smoke tests should run"
  type        = number
  default     = 15
}
