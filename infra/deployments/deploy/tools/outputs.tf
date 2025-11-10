output "cribl_sqs_queue_arn" {
  description = "ARN of the SQS queue for Cribl S3 event notifications"
  value       = module.log_to_splunk.cribl_sqs_queue_arn
}
