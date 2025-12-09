output "chatbot_alerts_configuration_arn" {
  value       = aws_chatbot_slack_channel_configuration.alerts.chat_configuration_arn
  description = "ARN of the ChatBot alerts channel configuration"
}

output "chatbot_deployments_configuration_arn" {
  value       = aws_chatbot_slack_channel_configuration.deployments.chat_configuration_arn
  description = "ARN of the ChatBot deployments channel configuration"
}

output "chatbot_alerts_sns_topic_arn" {
  value       = aws_sns_topic.alerts_topic.arn
  description = "ARN of the SNS topic for ChatBot alerts channel"
}

output "chatbot_deployments_sns_topic_arn" {
  value       = aws_sns_topic.deployments_topic.arn
  description = "ARN of the SNS topic for ChatBot deployments channel"
}
