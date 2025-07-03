data "aws_caller_identity" "current" {}

resource "aws_kms_key" "internal" {
  description         = "Symmetric encryption KMS key for internal secrets"
  enable_key_rotation = true
  policy              = data.aws_iam_policy_document.kms_management.json
}

resource "aws_kms_alias" "internal" {
  name          = "alias/internal"
  target_key_id = aws_kms_key.internal.key_id
}


data "aws_iam_policy_document" "kms_management" {
  # See https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-default.html#key-policy-default-allow-root-enable-iam
  #checkov:skip=CKV_AWS_111:AWS suggest the EnableIamAccess statement for key policies.
  #checkov:skip=CKV_AWS_109:AWS suggest the EnableIamAccess statement for key policies.
  #checkov:skip=CKV_AWS_356:Resource "*" is OK here because the only resource it can refer to is the key to which the policy is attached

  statement {
    sid    = "Enable IAM Access"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid    = "Allow administration of the key by admins of this account"
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = toset(concat(
        [for admin in module.users.with_role["${var.environment_type}_admin"] : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${admin}-admin"],
        ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/deployer-${var.environment_name}"]
      ))
    }
    actions = [
      "kms:DescribeKey",
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:GenerateDataKey"
    ]
    resources = ["*"]
  }
}
