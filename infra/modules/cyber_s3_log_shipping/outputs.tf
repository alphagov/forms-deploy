output "s3_policy" {
  description = "S3 bucket policy for cyber security log shipping"
  value       = local.enable_cribl ? data.aws_iam_policy_document.cribl_s3_access[0].json : data.aws_iam_policy_document.csls_s3_access[0].json
}
