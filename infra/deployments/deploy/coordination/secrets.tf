# Secrets Manager secrets for cross-account access to ChatBot SNS topic ARNs
# These secrets can be read by other AWS accounts (forms environments)
# via resource-based policies

resource "aws_secretsmanager_secret" "chatbot_alerts_sns_topic_arn" {
  #checkov:skip=CKV_AWS_149:SNS topic ARNs are not sensitive data and do not require KMS encryption
  #checkov:skip=CKV2_AWS_57:These secrets contain static SNS topic ARNs, not rotating credentials
  name        = "govuk-forms/chatbot/alerts-sns-topic-arn"
  description = "ARN of the SNS topic for ChatBot alerts channel (managed in deploy/coordination/chatbot.tf)"

  tags = {
    Name = "chatbot-alerts-sns-topic-arn"
  }
}

resource "aws_secretsmanager_secret_version" "chatbot_alerts_sns_topic_arn" {
  secret_id     = aws_secretsmanager_secret.chatbot_alerts_sns_topic_arn.id
  secret_string = aws_sns_topic.alerts_topic.arn
}

# Resource policy to allow forms accounts to read the secret
resource "aws_secretsmanager_secret_policy" "chatbot_alerts_sns_topic_arn" {
  secret_arn = aws_secretsmanager_secret.chatbot_alerts_sns_topic_arn.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowFormsAccountsToRead"
        Effect = "Allow"
        Principal = {
          AWS = [
            for account_id in module.other_accounts.environment_accounts_id :
            "arn:aws:iam::${account_id}:role/deployer-*"
          ]
        }
        Action   = "secretsmanager:GetSecretValue"
        Resource = "*"
      }
    ]
  })
}

resource "aws_secretsmanager_secret" "chatbot_deployments_sns_topic_arn" {
  #checkov:skip=CKV_AWS_149:SNS topic ARNs are not sensitive data and do not require KMS encryption
  #checkov:skip=CKV2_AWS_57:These secrets contain static SNS topic ARNs, not rotating credentials
  name        = "govuk-forms/chatbot/deployments-sns-topic-arn"
  description = "ARN of the SNS topic for ChatBot deployments channel (managed in deploy/coordination/chatbot.tf)"

  tags = {
    Name = "chatbot-deployments-sns-topic-arn"
  }
}

resource "aws_secretsmanager_secret_version" "chatbot_deployments_sns_topic_arn" {
  secret_id     = aws_secretsmanager_secret.chatbot_deployments_sns_topic_arn.id
  secret_string = aws_sns_topic.deployments_topic.arn
}

# Resource policy to allow forms accounts to read the secret
resource "aws_secretsmanager_secret_policy" "chatbot_deployments_sns_topic_arn" {
  secret_arn = aws_secretsmanager_secret.chatbot_deployments_sns_topic_arn.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowFormsAccountsToRead"
        Effect = "Allow"
        Principal = {
          AWS = [
            for account_id in module.other_accounts.environment_accounts_id :
            "arn:aws:iam::${account_id}:role/deployer-*"
          ]
        }
        Action   = "secretsmanager:GetSecretValue"
        Resource = "*"
      }
    ]
  })
}

# Output the secret ARNs for documentation
output "chatbot_alerts_sns_topic_arn_secret_arn" {
  value       = aws_secretsmanager_secret.chatbot_alerts_sns_topic_arn.arn
  description = "Secrets Manager secret ARN for ChatBot alerts SNS topic ARN"
}

output "chatbot_deployments_sns_topic_arn_secret_arn" {
  value       = aws_secretsmanager_secret.chatbot_deployments_sns_topic_arn.arn
  description = "Secrets Manager secret ARN for ChatBot deployments SNS topic ARN"
}
