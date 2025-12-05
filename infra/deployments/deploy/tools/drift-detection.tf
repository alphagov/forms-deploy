data "aws_secretsmanager_secret_version" "chatbot_infra_notifications_sns_topic_arn" {
  # Reference the secret in the same account (deploy account)
  secret_id = "arn:aws:secretsmanager:eu-west-2:${data.aws_caller_identity.current.account_id}:secret:govuk-forms/chatbot/infra-notifications-sns-topic-arn"
}

locals {
  # AWS ChatBot SNS topic - managed in the deploy account (deploy/coordination/chatbot.tf)
  # Retrieved from Secrets Manager for consistency with cross-account access pattern
  chatbot_infra_notifications_channel_sns_topic = data.aws_secretsmanager_secret_version.chatbot_infra_notifications_sns_topic_arn.secret_string
}

module "drift_detection" {
  source = "../../../modules/drift-detection"

  deployment_name          = "deploy"
  schedule_expression      = var.drift_detection_schedule
  drift_detected_topic_arn = local.chatbot_infra_notifications_channel_sns_topic
}
