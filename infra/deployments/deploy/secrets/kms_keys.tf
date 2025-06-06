module "users" {
  source = "../../../modules/users"
}

data "aws_caller_identity" "current" {}

resource "aws_kms_key" "external_environment_type" {
  for_each = toset(keys(var.secrets_in_environment_type))

  description         = "Symmetric encryption KMS key for external secrets in ${each.value} environments"
  enable_key_rotation = true
  policy              = data.aws_iam_policy_document.kms_management.json
}

resource "aws_kms_key" "external_global" {
  description         = "Symmetric encryption KMS key for external global secrets. This key is used by all environment types"
  enable_key_rotation = true
  policy              = data.aws_iam_policy_document.kms_management.json
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
