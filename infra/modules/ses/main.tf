data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

resource "aws_ses_email_identity" "verified_email_addresses" {
  for_each = var.verified_email_addresses
  email    = each.value
}

data "aws_iam_policy_document" "ses_sender" {
  statement {
    actions = [
      "ses:SendRawEmail",
      "ses:SendEmail"
    ]
    resources = ["arn:aws:ses:eu-west-2:${local.account_id}:identity/*"]
    condition {
      test     = "ForAnyValue:StringEquals"
      variable = "ses:FromAddress"
      values   = ["${var.from_address}"]
    }
  }
}

resource "aws_iam_policy" "ses_sender" {
  name        = "ses_sender"
  description = "Allows sending of emails via Simple Email Service"
  policy      = data.aws_iam_policy_document.ses_sender.json
}

resource "aws_iam_user_policy_attachment" "attach" {
  #checkov:skip=CKV_AWS_40: ignoring while spiking
  user       = aws_iam_user.this.name
  policy_arn = aws_iam_policy.ses_sender.arn
}

resource "aws_ssm_parameter" "smtp_username" {
  name  = "/ses/${var.smtp_user}/smtp-username"
  type  = "SecureString"
  value = aws_iam_access_key.this.id
}

resource "aws_ssm_parameter" "smtp_password" {
  name  = "/ses/${var.smtp_user}/smtp-password"
  type  = "SecureString"
  value = aws_iam_access_key.this.ses_smtp_password_v4
}

resource "aws_ses_receipt_rule_set" "main" {
  rule_set_name = "default-rule-set"
}

resource "aws_ses_receipt_rule" "bounce" {
  name          = "bounce"
  rule_set_name = "default-rule-set"
  enabled       = true

  bounce_action {
    message         = "no emails from you, thank you"
    sender          = var.from_address
    smtp_reply_code = "550"
    status_code     = "5.1.1"
    topic_arn       = aws_sns_topic.ses_notifications.arn
    position        = 1
  }
}

# Configure notifications for SES
resource "aws_sns_topic" "ses_notifications" {
  name = "ses-notifications-${var.environment}"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.ses_notifications.arn
  protocol  = "email"
  endpoint  = "catalina.garcia@digital.cabinet-office.gov.uk"
}
