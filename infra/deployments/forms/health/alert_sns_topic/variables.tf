variable "topic_name" {
  type        = string
  description = "Name of the SNS topic to be created"

  validation {
    condition     = can(regex("^[[:alnum:]_-]+$", var.topic_name))
    error_message = "Topic name must contain only alphanumeric characters, underscores, and dashes"
  }
}

variable "kms_key_arn" {
  type        = string
  description = "The ARN of the KMS key to use for at-rest encryption"

  validation {
    condition     = can(provider::aws::arn_parse(var.kms_key_arn))
    error_message = "Must be a valid AWS ARN string"
  }

  validation {
    condition = alltrue([
      can(provider::aws::arn_parse(var.kms_key_arn).service == "kms"),
      can(startswith(provider::aws::arn_parse(var.kms_key_arn).resource, "key/"))
    ])

    error_message = "The ARN must point to a KMS key"
  }
}