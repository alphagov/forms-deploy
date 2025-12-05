data "aws_secretsmanager_secret_version" "chatbot_infra_notifications_sns_topic_arn" {
  # Use the full ARN to reference the secret in the deploy account
  secret_id = "arn:aws:secretsmanager:eu-west-2:${var.deploy_account_id}:secret:govuk-forms/chatbot/infra-notifications-sns-topic-arn"
}

locals {
  # AWS ChatBot SNS topic - managed in the deploy account (deploy/coordination/chatbot.tf)
  # Retrieved from Secrets Manager for cross-account access
  chatbot_infra_notifications_channel_sns_topic = data.aws_secretsmanager_secret_version.chatbot_infra_notifications_sns_topic_arn.secret_string
}

module "drift_detection" {
  source = "../../../modules/drift-detection"

  deployment_name          = "integration"
  schedule_expression      = var.drift_detection_schedule
  git_branch               = "whi-tw/detect-deploy-integration-drift" # TODO: change back to "main" after testing
  drift_detected_topic_arn = local.chatbot_infra_notifications_channel_sns_topic
}
