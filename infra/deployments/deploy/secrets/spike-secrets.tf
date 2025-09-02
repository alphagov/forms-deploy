#############################
# Inputs (scoped to this stack)
#############################

variable "initial_catlike_secret_value" {
  description = "Optional initial value for the catlike secret; defaults to a generated random value if unset"
  type        = string
  default     = null
}

variable "initial_doglike_secret_value" {
  description = "Optional initial value for the doglike secret; defaults to a generated random value if unset"
  type        = string
  default     = null
}

data "aws_region" "current" {}

#############################
# Context
#############################
data "aws_caller_identity" "this" {}

locals {
  catlike_name = "/spikesecrets/catlike/dummy-secret"
  doglike_name = "/spikesecrets/doglike/dummy-secret"
}

#############################
# KMS CMK dedicated to Secrets Manager
#############################
data "aws_iam_policy_document" "kms_key_policy" {
  statement {
    sid       = "RootAdmin"
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.this.account_id}:root"]
    }
  }

  statement {
    sid    = "AllowSecretsManagerUseOfKey"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = ["*"]
    principals {
      type        = "Service"
      identifiers = ["secretsmanager.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["secretsmanager.${data.aws_region.current.region}.amazonaws.com"]
    }
    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:secretsmanager:arn"
      values   = ["arn:aws:secretsmanager:${data.aws_region.current.region}:${data.aws_caller_identity.this.account_id}:secret:*"]
    }
  }
}

resource "aws_kms_key" "spike_secrets" {
  description         = "CMK for spike Secrets Manager secrets"
  enable_key_rotation = true
  policy              = data.aws_iam_policy_document.kms_key_policy.json
}

resource "aws_kms_alias" "spike_secrets" {
  name          = "alias/spike/secrets"
  target_key_id = aws_kms_key.spike_secrets.key_id
}

#############################
# Generate initial values when not provided
#############################
resource "random_password" "catlike" {
  length  = 32
  special = false
}

resource "random_password" "doglike" {
  length  = 32
  special = false
}

locals {
  catlike_initial_value = coalesce(var.initial_catlike_secret_value, try(random_password.catlike.result, null))
  doglike_initial_value = coalesce(var.initial_doglike_secret_value, try(random_password.doglike.result, null))
}

#############################
# Secrets and initial versions
#############################
resource "aws_secretsmanager_secret" "catlike" {
  name       = local.catlike_name
  kms_key_id = aws_kms_key.spike_secrets.arn
  tags = {
    AccountType = "catlike"
  }
}

resource "aws_secretsmanager_secret" "doglike" {
  name       = local.doglike_name
  kms_key_id = aws_kms_key.spike_secrets.arn
  tags = {
    AccountType = "doglike"
  }
}

resource "aws_secretsmanager_secret_version" "catlike" {
  secret_id     = aws_secretsmanager_secret.catlike.id
  secret_string = local.catlike_initial_value
}

resource "aws_secretsmanager_secret_version" "doglike" {
  secret_id     = aws_secretsmanager_secret.doglike.id
  secret_string = local.doglike_initial_value
}

#############################
# Resource-based ABAC policies on each secret
#############################
data "aws_iam_policy_document" "catlike_secret_policy" {
  statement {
    sid       = "DenyOutsideOrg"
    effect    = "Deny"
    actions   = ["secretsmanager:*"]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    condition {
      test     = "StringNotEquals"
      variable = "aws:PrincipalOrgID"
      values   = [data.aws_organizations_organization.this.id]
    }
  }

  statement {
    sid    = "AllowEnvTypeReaders"
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]
    resources = [aws_secretsmanager_secret.catlike.arn]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalTag/AccountType"
      values   = ["catlike"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/AccountType"
      values   = ["catlike"]
    }
  }
}

data "aws_iam_policy_document" "doglike_secret_policy" {
  statement {
    sid       = "DenyOutsideOrg"
    effect    = "Deny"
    actions   = ["secretsmanager:*"]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    condition {
      test     = "StringNotEquals"
      variable = "aws:PrincipalOrgID"
      values   = [data.aws_organizations_organization.this.id]
    }
  }

  statement {
    sid    = "AllowEnvTypeReaders"
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]
    resources = [aws_secretsmanager_secret.doglike.arn]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalTag/AccountType"
      values   = ["doglike"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/AccountType"
      values   = ["doglike"]
    }
  }
}

resource "aws_secretsmanager_secret_policy" "catlike" {
  secret_arn = aws_secretsmanager_secret.catlike.arn
  policy     = data.aws_iam_policy_document.catlike_secret_policy.json
}

resource "aws_secretsmanager_secret_policy" "doglike" {
  secret_arn = aws_secretsmanager_secret.doglike.arn
  policy     = data.aws_iam_policy_document.doglike_secret_policy.json
}

#############################
# Outputs
#############################
output "kms_key_arn" {
  description = "ARN of the KMS CMK used by spike secrets"
  value       = aws_kms_key.spike_secrets.arn
}

output "catlike_secret_arn" {
  description = "ARN of the catlike spike secret"
  value       = aws_secretsmanager_secret.catlike.arn
}

output "doglike_secret_arn" {
  description = "ARN of the doglike spike secret"
  value       = aws_secretsmanager_secret.doglike.arn
}

#############################
# Notes for consumers (inline README)
#############################
# Consumers must ensure their runtime role sessions include a session tag AccountType
# matching the secret's AccountType (catlike or doglike). Typical setup:
# - Trust policy: allow sts:AssumeRole + sts:TagSession with a Condition requiring
#   aws:RequestTag/AccountType to be one of the allowed env types for that role.
# - Identity policy: you may add a condition such as
#   StringEquals: { "aws:ResourceTag/AccountType": "<envtype>" } when granting
#   secretsmanager:GetSecretValue/DescribeSecret on relevant ARNs.
# - No kms:Decrypt permission is needed on consumer roles; Secrets Manager decrypts
#   the secret using the CMK via the service integration allowed by the key policy.
