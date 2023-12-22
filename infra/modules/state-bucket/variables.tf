variable "bucket_name" {}

output "bucket_name" {
  value = aws_s3_bucket.state.id
}