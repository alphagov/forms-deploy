#############################
# Inputs (scoped to this stack)
#############################

variable "spike_secret_length" {
  description = "Length of generated spike secret values"
  type        = number
  default     = 32
}

#############################
# Context
#############################

locals {
  # Suffix for all spike secrets
  spike_app_secret_suffix = "fake-app/dummy-secret"

  # Extended environment accounts map including spike accounts
  # Both catlike and doglike point to the development account for the spike
  extended_environment_accounts = merge(
    module.all_accounts.environment_accounts_id,
    {
      "catlike" = module.all_accounts.environment_accounts_id["development"]
      "doglike" = module.all_accounts.environment_accounts_id["development"]
    }
  )

  # Generate secret names for all environments
  environment_secret_names = {
    for env_name, account_id in local.extended_environment_accounts :
    env_name => "/spikesecrets/${env_name}/${local.spike_app_secret_suffix}"
  }
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
      values   = ["secretsmanager.${data.aws_region.this.name}.amazonaws.com"]
    }
    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:secretsmanager:arn"
      values   = ["arn:aws:secretsmanager:${data.aws_region.this.name}:${data.aws_caller_identity.this.account_id}:secret:*"]
    }
  }

  statement {
    sid    = "AllowCrossAccountECSExecutionRoles"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey"
    ]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = [for account_id in toset(values(local.extended_environment_accounts)) : "arn:aws:iam::${account_id}:role/*-secrets-spike-*-execution"]
    }
    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["secretsmanager.${data.aws_region.this.name}.amazonaws.com"]
    }
    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:secretsmanager:arn"
      values   = ["arn:aws:secretsmanager:${data.aws_region.this.name}:${data.aws_caller_identity.this.account_id}:secret:/spikesecrets/*"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalOrgID"
      values   = [data.aws_organizations_organization.this.id]
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
# Generate ephemeral values for all environments
#############################
ephemeral "random_password" "environment_secrets" {
  for_each = local.extended_environment_accounts

  length  = var.spike_secret_length
  special = false
}

#############################
# Secrets and initial versions (programmatic)
#############################
resource "aws_secretsmanager_secret" "environment" {
  for_each = local.environment_secret_names

  name       = each.value
  kms_key_id = aws_kms_key.spike_secrets.arn
  tags = {
    Environment = each.key
  }
}

resource "aws_secretsmanager_secret_version" "environment" {
  for_each = local.environment_secret_names

  secret_id                = aws_secretsmanager_secret.environment[each.key].id
  secret_string_wo         = ephemeral.random_password.environment_secrets[each.key].result
  secret_string_wo_version = 1
}

# Create an ephemeral resource to expose the secret version data for consumption
ephemeral "aws_secretsmanager_secret_version" "environment" {
  for_each = local.environment_secret_names

  secret_id  = aws_secretsmanager_secret.environment[each.key].id
  version_id = aws_secretsmanager_secret_version.environment[each.key].version_id
}

#############################
# Resource-based policies (programmatic)
#############################
data "aws_iam_policy_document" "environment_secret_policy" {
  for_each = local.extended_environment_accounts

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
    sid    = "AllowEnvironmentAccountAccess"
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]
    resources = [
      "arn:aws:secretsmanager:${data.aws_region.this.name}:${data.aws_caller_identity.this.account_id}:secret:/spikesecrets/${each.key}/*"
    ]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${each.value}:root"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalOrgID"
      values   = [data.aws_organizations_organization.this.id]
    }
  }
}

resource "aws_secretsmanager_secret_policy" "environment" {
  for_each = local.extended_environment_accounts

  secret_arn = aws_secretsmanager_secret.environment[each.key].arn
  policy     = data.aws_iam_policy_document.environment_secret_policy[each.key].json
}

#############################
# Outputs
#############################
output "kms_key_arn" {
  description = "ARN of the KMS CMK used by spike secrets"
  value       = aws_kms_key.spike_secrets.arn
}

output "environment_secret_arns" {
  description = "ARNs of all environment-scoped secrets"
  value = {
    for env_name, secret_name in local.environment_secret_names :
    env_name => aws_secretsmanager_secret.environment[env_name].arn
  }
}
