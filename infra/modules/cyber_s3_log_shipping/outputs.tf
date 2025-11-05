output "s3_policy" {
  description = "S3 bucket policy for cyber security log shipping"
  value       = module.s3_log_shipping.s3_policy
}

output "cribl_s3_policy" {
  description = "S3 bucket policy for Cribl role access (null if Cribl not enabled)"
  value       = var.enable_cribl ? data.aws_iam_policy_document.cribl_s3_access[0].json : null
}
