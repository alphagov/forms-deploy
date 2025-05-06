resource "aws_kms_key" "active_record_encryption" {
  description = "Key used to encrypt sensitive data within Runner database"
  policy      = data.aws_iam_policy_document.encryption_key.json

  enable_key_rotation = true
}

resource "aws_kms_alias" "active_record_alias" {
  name          = "alias/active-record-encryption-${var.env_name}"
  target_key_id = aws_kms_key.active_record_encryption.key_id
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
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
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
    sid    = "Allow encryption and decryption of messages"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [module.ecs_service.task_role_arn]
    }

    actions = [
      "kms:Decrypt",
      "kms:Encrypt"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "Allow Administration of the key"
    effect = "Allow"

    principals {
      type = "AWS"
      identifiers = toset(concat(
        [for admin in module.users.with_role["${var.environment_type}_admin"] : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${admin}-admin"],
        ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/deployer-${var.env_name}"]
      ))
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
      "kms:TagResource"
    ]
    resources = ["*"]
  }
}