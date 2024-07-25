## Zendesk us-east-1
module "zendesk_alert_us_east_1" {
  source = "./alert_sns_topic"

  # Override the default AWS provider with the one for us-east-1
  # so that it's created in us-east-1 transparently
  providers = {
    aws = aws.us-east-1
  }
  
  topic_name = "cloudwatch-alarms"
  kms_key_arn = aws_kms_key.topic_sse_us_east_1.key_id
}

data "aws_ssm_parameter" "email_zendesk" {
  name = "/alerting/email-zendesk"
}

resource "aws_sns_topic_subscription" "email" {
  provider  = aws.us-east-1
  topic_arn = module.zendesk_alert_us_east_1.topic_arn
  protocol  = "email"
  endpoint  = data.aws_ssm_parameter.email_zendesk.value
}

## KMS keys
resource "aws_kms_key" "topic_sse_us_east_1" {
  provider = aws.us-east-1

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