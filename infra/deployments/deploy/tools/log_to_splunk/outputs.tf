output "destination_arn" {
  description = "Source account Cloudwatch Logs Destination ARN"
  value       = aws_cloudwatch_log_destination.kinesis_log_destination.arn
}

output "destination_arn_us_east_1" {
  description = "Source account Cloudwatch Logs Destination ARN in the us-east-1 region"
  value       = aws_cloudwatch_log_destination.kinesis_log_destination_us_east_1.arn
}

output "cribl_sqs_queue_arn" {
  description = "ARN of the SQS queue for Cribl S3 event notifications"
  value       = aws_sqs_queue.cribl_s3_events.arn
}

output "cribl_role_arn" {
  description = "ARN of the Cribl ingest role"
  value       = aws_iam_role.cribl_ingest.arn
}
