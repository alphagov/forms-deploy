output "cribl_sqs_queue_arn" {
  description = "ARN of the SQS queue for Cribl S3 event notifications"
  value       = aws_sqs_queue.cribl_s3_events.arn
}

output "cribl_role_arn" {
  description = "ARN of the Cribl ingest role"
  value       = aws_iam_role.cribl_ingest.arn
}
