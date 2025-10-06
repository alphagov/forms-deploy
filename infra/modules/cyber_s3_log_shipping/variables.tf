variable "s3_name" {
  type        = string
  description = "The name of the S3 bucket to configure for log shipping"
}

variable "enable_bucket_notification" {
  type        = bool
  description = "Whether to enable S3 bucket notifications to trigger the log shipping Lambda function"
  default     = true
}
