data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

resource "aws_sns_topic" "alert_pagerduty" {
  name              = "pagerduty_integration_${var.environment}"
  kms_master_key_id = aws_kms_key.topic_sse.key_id
}

resource "aws_sns_topic_policy" "pagerduty_topic_access_policy" {
  arn = aws_sns_topic.alert_pagerduty.arn
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AllowPublishFromServices",
        Action   = "sns:Publish"
        Effect   = "Allow"
        Resource = aws_sns_topic.alert_pagerduty.arn
        Principal = {
          Service = [
            "cloudwatch.amazonaws.com",
            "events.amazonaws.com",
          ]
        }
      }
    ]
  })
}

data "aws_ssm_parameter" "pagerduty_integration_url" {
  name       = "/alerting/${var.environment}/pagerduty-integration-url"
  depends_on = [aws_ssm_parameter.pagerduty_integration_url]
}

resource "aws_ssm_parameter" "pagerduty_integration_url" {
  #checkov:skip=CKV_AWS_337:The parameter is already using the default key
  # Value is set externally.
  name  = "/alerting/${var.environment}/pagerduty-integration-url"
  type  = "SecureString"
  value = "https://example.org/"

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_sns_topic_subscription" "pagerduty_subscription" {
  topic_arn = aws_sns_topic.alert_pagerduty.arn
  protocol  = "https"
  endpoint  = data.aws_ssm_parameter.pagerduty_integration_url.value
}

resource "aws_kms_key" "topic_sse" {
  description = "For server side encryption of the alerts topic"
  policy      = data.aws_iam_policy_document.key_policy.json

  enable_key_rotation = true
}

data "aws_iam_policy_document" "key_policy" {
  # See https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-default.html#key-policy-default-allow-root-enable-iam
  #checkov:skip=CKV_AWS_111:AWS suggest the EnableIamAccess statement for key policies.
  #checkov:skip=CKV_AWS_109:AWS suggest the EnableIamAccess statement for key policies.
  #checkov:skip=CKV_AWS_356:Resource "*" is OK here because the only resource it can refer to is the key to which the policy is attached

  # https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-default.html#key-policy-default-allow-root-enable-iam
  statement {
    sid    = "EnableIamAccess"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${local.account_id}:root"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid    = "EnableCloudWatchAndEventsAccess"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudwatch.amazonaws.com", "events.amazonaws.com"]
    }

    actions   = ["kms:GenerateDataKey*", "kms:Decrypt"]
    resources = ["*"]
  }
}

resource "aws_sns_topic" "alert_zendesk" {
  name              = "alert_zendesk_${var.environment}"
  kms_master_key_id = aws_kms_key.topic_sse.key_id
}

resource "aws_sns_topic_policy" "zendesk_topic_access_policy" {
  arn = aws_sns_topic.alert_zendesk.arn
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AllowPublishFromServices",
        Action   = "sns:Publish"
        Effect   = "Allow"
        Resource = aws_sns_topic.alert_zendesk.arn
        Principal = {
          Service = [
            "events.amazonaws.com",
          ]
        }
      }
    ]
  })
}

data "aws_ssm_parameter" "zendesk_email" {
  name = "/alerting/email-zendesk"
}

resource "aws_sns_topic_subscription" "zendesk_subscription" {
  topic_arn = aws_sns_topic.alert_zendesk.arn
  protocol  = "email"
  endpoint  = data.aws_ssm_parameter.zendesk_email.value
}
