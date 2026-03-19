variable "deploy_account_id" {
  description = "the account number for deploy account"
  type        = string
  default     = "711966560482"
}

variable "codestar_connection_arn" {
  description = "the arn of the github connection to use"
  type = object({
    alphagov    = string
    govuk-forms = string
  })
  default = {
    alphagov    = "arn:aws:codestar-connections:eu-west-2:711966560482:connection/8ad08da2-743c-4431-bee6-ad1ae9efebe7"
    govuk-forms = "arn:aws:codeconnections:eu-west-2:711966560482:connection/c285479e-88b3-430e-8c59-d96035a30f53"
  }
}

variable "send_logs_to_cyber" {
  description = "Whether logs should be sent to cyber"
  type        = bool
  default     = true
}

variable "drift_detection_schedule" {
  description = "EventBridge schedule expression for drift detection"
  type        = string
  default     = "cron(0 9 ? * MON *)"
}
