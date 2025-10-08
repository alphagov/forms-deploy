variable "topic_name" {
  type        = string
  description = "Name of the SNS topic to be created"

  validation {
    condition     = can(regex("^[[:alnum:]_-]+$", var.topic_name))
    error_message = "Topic name must contain only alphanumeric characters, underscores, and dashes"
  }
}

variable "kms_key_id" {
  type        = string
  description = "The unique id of the KMS key to use for at-rest encryption"
}
