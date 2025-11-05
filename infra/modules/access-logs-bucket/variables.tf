variable "bucket_name" {
  type        = string
  description = "Name of the access logs bucket"
}

variable "send_access_logs_to_cyber" {
  type        = bool
  description = "Whether access logs should be sent to cyber"
  default     = false
  nullable    = false
}

variable "extra_bucket_policies" {
  type        = list(string)
  description = "Extra bucket policies to apply to this bucket. List of json policies"
  default     = []
}

variable "enable_cribl" {
  type        = bool
  description = "Whether to enable Cribl S3 event notifications and bucket access"
  default     = true
}
