variable "bucket_name" {
  type        = string
  description = "The name of the bucket"
}

variable "access_logging_enabled" {
  type        = bool
  description = "Whether S3 bucket access logging should be enabled"
  default     = false
  nullable    = false
}

variable "send_access_logs_to_cyber" {
  type        = bool
  description = "Whether access logs should be sent to cyber"
  default     = true
  nullable    = false
}

variable "access_log_shipping_destination" {
  type        = string
  description = "The destination for log shipping. Valid values are 'cribl' or 'csls'."
  default     = "cribl"

  validation {
    condition     = contains(["cribl", "csls"], var.access_log_shipping_destination)
    error_message = "Invalid destination. Valid values are 'cribl' or 'csls'."
  }
}

output "bucket_name" {
  value = aws_s3_bucket.state.id
}
