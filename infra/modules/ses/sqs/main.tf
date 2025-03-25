resource "aws_kms_key" "this" {
  description = "Key used to encrypt messages on the queue and topic for ${var.identifier} ${var.sqs_type}"
  policy      = data.aws_iam_policy_document.encryption_key.json

  enable_key_rotation = true
}

resource "aws_kms_alias" "this" {
  name          = "alias/${var.identifier}-${var.sqs_type}-${var.environment_name}"
  target_key_id = aws_kms_key.this.key_id
}

module "users" {
  source = "../../users"
}

data "aws_iam_policy_document" "encryption_key" {
  # See https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-default.html#key-policy-default-allow-root-enable-iam
  #checkov:skip=CKV_AWS_111: This is applied directly to the key and we cannot specify the key in the resources.
  #checkov:skip=CKV_AWS_109: This is applied directly to the key and we cannot specify the key in the resources.
  #checkov:skip=CKV_AWS_356: This is applied directly to the key and we cannot specify the key in the resources.

  # https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-default.html#key-policy-default-allow-root-enable-iam
  statement {
    sid    = "EnableIamAccess"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.account_id}:root"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid    = "Allow SQS, SNS and SES to use the key"
    effect = "Allow"

    principals {
      type = "Service"
      identifiers = [
        "sqs.amazonaws.com",
        "sns.amazonaws.com",
        "ses.amazonaws.com"
      ]
    }

    actions = [
      "kms:GenerateDataKey",
      "kms:Decrypt"
    ]
    resources = ["*"]
  }


  statement {
    sid    = "Allow decryption of messages"
    effect = "Allow"

    principals {
      type = "AWS"
      identifiers = toset(concat(
        [for admin in module.users.with_role["${var.environment_type}_admin"] : "arn:aws:iam::${var.account_id}:role/${admin}-admin"],
        [for admin in module.users.with_role["${var.environment_type}_support"] : "arn:aws:iam::${var.account_id}:role/${admin}-support"]
      ))
    }

    actions = [
      "kms:Decrypt"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "Allow Administration of the key"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [for admin in module.users.with_role["${var.environment_type}_admin"] : "arn:aws:iam::${var.account_id}:role/${admin}-admin"]
    }

    actions = [
      "kms:Create*",
      "kms:Describe*",
      "kms:Enable*",
      "kms:List*",
      "kms:Put*",
      "kms:Update*",
      "kms:Revoke*",
      "kms:Disable*",
      "kms:Get*",
      "kms:Delete*",
      "kms:ScheduleKeyDeletion",
      "kms:CancelKeyDeletion",
      "kms:GenerateDataKey",
      "kms:Decrypt",
      "kms:TagResource"
    ]
    resources = ["*"]
  }
}

resource "aws_sqs_queue" "ses_queue" {
  name                       = "${var.identifier}_${var.sqs_type}_queue"
  message_retention_seconds  = 1209600 # 14 days
  visibility_timeout_seconds = 300
  redrive_policy             = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.ses_dead_letter.arn}\",\"maxReceiveCount\":4}"

  kms_master_key_id = aws_kms_key.this.id
}

resource "aws_sqs_queue" "ses_dead_letter" {
  # This is so that the auth0 queue (identifier = ses) will not be replaced
  name = var.identifier == "ses" ? "${var.identifier}_dead_letter_queue" : "${var.identifier}_${var.sqs_type}_dead_letter_queue"

  message_retention_seconds = 1209600 # 14 days

  kms_master_key_id = aws_kms_key.this.id
}

resource "aws_sns_topic" "ses_topic" {
  name = "${var.identifier}_${var.sqs_type}"

  kms_master_key_id = aws_kms_key.this.id
}

resource "aws_sns_topic_subscription" "ses_topic_subscription" {
  topic_arn = aws_sns_topic.ses_topic.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.ses_queue.arn
}

data "aws_iam_policy_document" "ses_policy_document" {
  policy_id = var.policy_id
  statement {
    sid       = var.policy_id
    effect    = "Allow"
    actions   = ["SQS:SendMessage"]
    resources = [aws_sqs_queue.ses_queue.arn]
    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }
    condition {
      test     = "ArnEquals"
      values   = [aws_sns_topic.ses_topic.arn]
      variable = "aws:SourceArn"
    }
  }
}

resource "aws_sqs_queue_policy" "ses_policy" {
  queue_url = aws_sqs_queue.ses_queue.id
  policy    = data.aws_iam_policy_document.ses_policy_document.json
}
