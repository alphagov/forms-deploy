output "s3_policy" {
  description = "S3 bucket policy for cyber security log shipping"
  value       = module.s3_log_shipping.s3_policy
}

output "s3_to_splunk_queue_arn" {
  description = "ARN of the cyber security S3 to Splunk SQS queue"
  value       = "arn:aws:sqs:eu-west-2:885513274347:cyber-security-s3-to-splunk-prodpython"
}