## Zendesk us-east-1
# SNS topic to send CloudWatch alarms to Zendesk
# Required since Shield and some Cloudwatch resources
# send alerts outside of eu-west-2
module "zendesk_alert_us_east_1" {
  source = "./alert_sns_topic"

  # Override the default AWS provider with the one for us-east-1
  # so that it's created in us-east-1 transparently
  providers = {
    aws = aws.us-east-1
  }

  topic_name = "cloudwatch-alarms"
  kms_key_id = aws_kms_key.topic_sse_us_east_1.arn
}

data "aws_ssm_parameter" "email_zendesk" {
  name = "/alerting/email-zendesk"
}

resource "aws_sns_topic_subscription" "zendesk_email_us_east_1" {
  provider  = aws.us-east-1
  topic_arn = module.zendesk_alert_us_east_1.topic_arn
  protocol  = "email"
  endpoint  = data.aws_ssm_parameter.email_zendesk.value
}

## Zendesk eu-west-2
module "zendesk_alert_eu_west_2" {
  source = "./alert_sns_topic"

  topic_name = "alert_zendesk_${var.env_name}"
  kms_key_id = aws_kms_key.topic_sse_eu_west_2.key_id
}

resource "aws_sns_topic_subscription" "zendesk_email_eu_west_2" {
  topic_arn = module.zendesk_alert_eu_west_2.topic_arn
  protocol  = "email"
  endpoint  = data.aws_ssm_parameter.email_zendesk.value
}

## Pagerduty eu-west-2
module "pagerduty_eu_west_2" {
  source = "./alert_sns_topic"

  topic_name = "pagerduty_integration_${var.env_name}"
  kms_key_id = aws_kms_key.topic_sse_eu_west_2.key_id
}

resource "aws_sns_topic_subscription" "pagerduty_subscription_eu_west_2" {
  topic_arn = module.pagerduty_eu_west_2.topic_arn
  protocol  = "https"
  endpoint  = data.aws_ssm_parameter.pagerduty_integration_url.value
}

data "aws_ssm_parameter" "pagerduty_integration_url" {
  name       = "/alerting/${var.env_name}/pagerduty-integration-url"
  depends_on = [aws_ssm_parameter.pagerduty_integration_url]
}

resource "aws_ssm_parameter" "pagerduty_integration_url" {
  #checkov:skip=CKV_AWS_337:The parameter is already using the default key
  # Value is set externally.
  name  = "/alerting/${var.env_name}/pagerduty-integration-url"
  type  = "SecureString"
  value = "https://example.org/"

  lifecycle {
    ignore_changes = [value]
  }
}

## KMS keys
resource "aws_kms_key" "topic_sse_us_east_1" {
  provider = aws.us-east-1

  description = "For server side encryption of the alerts topic"
  policy      = data.aws_iam_policy_document.key_policy.json

  enable_key_rotation = true
}

resource "aws_kms_alias" "topic_sse_us_east_1" {
  provider = aws.us-east-1

  name          = "alias/alert-topic-encryption-${var.env_name}"
  target_key_id = aws_kms_key.topic_sse_us_east_1.key_id
}

resource "aws_kms_key" "topic_sse_eu_west_2" {
  description = "For server side encryption of the alerts topic"
  policy      = data.aws_iam_policy_document.key_policy.json

  enable_key_rotation = true
}

resource "aws_kms_alias" "topic_sse_eu_west_2" {
  name          = "alias/alert-topic-encryption-${var.env_name}"
  target_key_id = aws_kms_key.topic_sse_eu_west_2.key_id
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
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
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
