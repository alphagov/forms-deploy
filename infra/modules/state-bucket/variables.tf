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


output "bucket_name" {
  value = aws_s3_bucket.state.id
}