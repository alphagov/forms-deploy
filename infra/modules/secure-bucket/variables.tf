variable "name" {
  type = string
}

variable "extra_bucket_policies" {
  type        = list(string)
  description = "extra bucket policies to apply to this bucket. List of json policies"
  default     = []
}

variable "AES256_encryption_configuration" {
  type        = bool
  description = "Whether to use AES256 as the algorithm for server side encryption. If false, the caller should set their own configuration"
  default     = true
  nullable    = false
}
variable "versioning_enabled" {
  type        = bool
  description = "Whether S3 bucket object versioning should be enabled"
  default     = true
  nullable    = false
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
  default     = false
  nullable    = false
}

