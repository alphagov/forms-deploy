variable "environment" {
  type = string
}

variable "container_registry" {
  description = "The container registry from which images should be pulled"
  type        = string
  nullable    = false
}


variable "frequency_minutes" {
  description = "How often the scheduled smoke tests should run"
  type        = number
  default     = 10
}

variable "test_name" {
  description = "The name of the test, used for naming various components such as the CodeBuild project"
  type        = string
}

variable "rspec_path" {
  description = "The path of the file or directory to run with Rspec, from the root of the forms-e2e repo. E.g. `spec/smoke_tests`"
  type        = string
}

variable "enable_alerting" {
  description = "If true then alerts will be sent when the cloud watch alarms are triggered"
  type        = bool
  default     = true
}

variable "alarm_description" {
  description = "The text to display in the alarm message. It should help responder understand what the alarm means and how to begin to respond."
  type        = string
}

variable "codebuild_environment_variables" {
  description = "A map of name and value pairs to set at environment variables in the CodeBuild environment."
  type        = map(any)
}

variable "alarm_sns_topic_arn" {
  description = "The arn for the SNS topic that the CloudWatch alarm will send notifications to."
  type        = string
}

variable "deploy_account_id" {
  type        = string
  description = "the account number for the deploy account"
}