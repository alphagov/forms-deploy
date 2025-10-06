output "bucket_id" {
  description = "The ID of the access logs bucket"
  value       = aws_s3_bucket.access_logs.id
}

output "bucket_arn" {
  description = "The ARN of the access logs bucket"
  value       = aws_s3_bucket.access_logs.arn
}

output "bucket_name" {
  description = "The name of the access logs bucket"
  value       = aws_s3_bucket.access_logs.id
}
