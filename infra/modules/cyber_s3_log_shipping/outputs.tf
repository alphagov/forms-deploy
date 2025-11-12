output "s3_policy" {
  description = "S3 bucket policy for cyber security log shipping"
  value       = data.aws_iam_policy_document.cribl_s3_access.json
}
