output "destination_arn" {
  description = "Source account Cloudwatch Logs Destination ARN"
  value       = aws_cloudwatch_log_destination.kinesis_log_destination.arn
}
