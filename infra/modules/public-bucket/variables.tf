variable "name" {
  type = string
}

variable "extra_bucket_policies" {
  type        = list(string)
  description = "extra bucket policies to apply to this bucket. List of json policies"
  default     = []
}

variable "access_logging_enabled" {
  type        = bool
  description = "Whether S3 bucket access logging should be enabled"
  default     = true
  nullable    = false
}

variable "send_access_logs_to_cyber" {
  type        = bool
  description = "Whether access logs should be sent to cyber"
  default     = true
  nullable    = false
}
