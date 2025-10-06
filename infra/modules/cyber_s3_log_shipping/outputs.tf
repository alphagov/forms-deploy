output "s3_policy" {
  description = "S3 bucket policy for cyber security log shipping"
  value       = module.s3_log_shipping.s3_policy
}
