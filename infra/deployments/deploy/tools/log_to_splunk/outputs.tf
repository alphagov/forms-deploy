output "destination_arn" {
  description = "Source account Cloudwatch Logs Destination ARN"
  value       = aws_cloudwatch_log_destination.kinesis_log_destination.arn
}

output "destination_arn_us_east_1" {
  description = "Source account Cloudwatch Logs Destination ARN in the us-east-1 region"
  value       = aws_cloudwatch_log_destination.kinesis_log_destination_us_east_1.arn
}
