variable "s3_name" {
  type        = string
  description = "The name of the S3 bucket to configure for log shipping"
}

variable "enable_bucket_notification" {
  type        = bool
  description = "Whether to enable S3 bucket notifications to trigger the log shipping Lambda function"
  default     = true
}

variable "enable_cribl" {
  type        = bool
  description = "Whether to enable Cribl S3 event notifications and bucket access. Set to true to enable dual logging to both CSLS and Cribl."
  default     = true
}
