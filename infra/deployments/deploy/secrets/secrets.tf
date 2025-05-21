module "users" {
  source = "../../../modules/users"
}

data "aws_caller_identity" "current" {}

resource "aws_secretsmanager_secret" "mailchimp_api_key" {
  name       = "external/dev/mailchimp/api-key"
  kms_key_id = aws_kms_key.this.id
}

resource "aws_kms_key" "this" {
  description         = "Symmetric encryption KMS key for external secrets in dev environments"
  enable_key_rotation = true
}

resource "aws_kms_key_policy" "secretsmanager" {
  key_id = aws_kms_key.this.id
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "key-default-1"
    Statement = [
      {
        Sid    = "Enable IAM Access"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow administration of the key by admins of this account"
        Effect = "Allow"
        Principals = {
          type        = "AWS"
          identifiers = [for admin in module.users.with_role["deploy_admin"] : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${admin}-admin"]
        },
        Action = [
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
        ],
        Resource = "*"
      },
    ]
  })
}
