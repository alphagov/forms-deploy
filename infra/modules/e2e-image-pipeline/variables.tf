variable "github_connection_arn" {
  type        = string
  description = "The arn of the github connection to use"
  default     = "arn:aws:codestar-connections:eu-west-2:711966560482:connection/8ad08da2-743c-4431-bee6-ad1ae9efebe7"
}

variable "forms_e2e_tests_branch" {
  type        = string
  description = "The branch of forms-e2e-tests to use"
  default     = "main"
}
