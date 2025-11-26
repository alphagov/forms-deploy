variable "account_id" {
  type        = string
  description = "The ID of the account the notification are for"
}

variable "account_name" {
  type        = string
  description = "The name of the account the notifications are for"
}

variable "pipeline_completion_topic_arn" {
  type        = string
  description = "The ARN of the AWS SNS topic to which the pipeline completion notifications should be sent"
}

variable "pipeline_failure_topic_arn" {
  type        = string
  description = "The ARN of the AWS SNS topic to which the pipeline failure notifications should be sent"
}

variable "run_e2e_tests_failure_topic_arn" {
  type        = string
  description = "The ARN of the AWS SNS topic to which the run-e2e-tests failure notifications should be sent"
}

variable "dead_letter_queue_arn" {
  type        = string
  description = "The ARN of the AWS SQS queue to use as the dead letter queue in AWS EventBridge"
}
