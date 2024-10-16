data "aws_sns_topic" "topic" {
  name = var.topic_name
}

output "topic_arn" {
  value = data.aws_sns_topic.topic.arn
}