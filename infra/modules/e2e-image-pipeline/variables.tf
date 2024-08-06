variable "codestar_connection_arn" {
  type        = string
  description = "the arn of the github connection to use"
}

variable "forms_e2e_tests_branch" {
  type        = string
  description = "The branch of forms-e2e-tests to use"
  default     = "main"
}
