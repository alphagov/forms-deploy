output "aws_sns_topic" {
  value = aws_sns_topic.ses_topic.arn
}

output "queue_name" {
  value = aws_sqs_queue.ses_queue.name
}

output "dlq_name" {
  value = aws_sqs_queue.ses_dead_letter.name
}

output "kms_key_arn" {
  value = aws_kms_key.this.arn
}
