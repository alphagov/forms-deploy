module "users" {
  source = "../../../modules/users"
}

data "aws_caller_identity" "current" {}

resource "aws_kms_key" "external_env_type" {
  for_each = toset(local.environment_types)

  description         = "Symmetric encryption KMS key for external secrets in ${each.key} environments"
  enable_key_rotation = true
  policy              = data.aws_iam_policy_document.kms_management.json
}

resource "aws_kms_key" "external_global" {
  description         = "Symmetric encryption KMS key for external global secrets"
  enable_key_rotation = true
  policy              = data.aws_iam_policy_document.kms_management.json
}

data "aws_iam_policy_document" "kms_management" {
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
      type        = "AWS"
      identifiers = [for admin in module.users.with_role["deploy_admin"] : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${admin}-admin"]
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
      "kms:CancelKeyDeletion"
    ]
    resources = ["*"]
  }
}
