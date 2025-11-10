output "s3_logs_processor_role_arn" {
  description = "The ARN of the CSLS S3 logs processor role"
  value       = "arn:aws:iam::885513274347:role/csls_prodpython/csls_process_s3_logs_lambda_prodpython"
}

output "s3_to_splunk_queue_arn" {
  description = "ARN of the SQS queue that CSLS uses to send S3 logs to Splunk"
  value       = "arn:aws:sqs:eu-west-2:885513274347:cyber-security-s3-to-splunk-prodpython"
}

output "cloudwatch_to_splunk_destination_arns" {
  description = "Mapping of region to the ARN of the CloudWatch Logs destination that CSLS uses to send CloudWatch logs to Splunk"
  value = {
    "eu-west-2" = "arn:aws:logs:eu-west-2:885513274347:destination:csls_cw_logs_destination_prodpython"
    "us-east-1" = "arn:aws:logs:us-east-1:885513274347:destination:csls_cw_logs_destination_prodpython"
  }
}
