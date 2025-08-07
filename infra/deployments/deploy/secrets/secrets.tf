locals {
  secrets_in_environment_type = flatten([
    for environment_type, secrets_set in var.secrets_in_environment_type : [
      for secret in secrets_set : {
        environment_type      = environment_type
        name                  = "/external/${environment_type}/${var.external_environment_type_secrets[secret].name}"
        description           = var.external_environment_type_secrets[secret].description
        generate_random_value = var.external_environment_type_secrets[secret].generate_random_value
      }
    ]
  ])
}

ephemeral "random_password" "generated_by_us" {
  length           = 16
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_secretsmanager_secret" "external_environment_type" {
  #checkov:skip=CKV2_AWS_57: we're not ready to enable automatic rotation
  for_each = { for secret in local.secrets_in_environment_type : secret.name => secret }

  name        = each.value.name
  description = each.value.description
  kms_key_id  = aws_kms_key.external_environment_type[each.value.environment_type].id
}

resource "aws_secretsmanager_secret_version" "external_environment_type" {
  for_each = { for secret in local.secrets_in_environment_type : secret.name => secret }

  secret_id                = aws_secretsmanager_secret.external_environment_type[each.value.name].id
  secret_string_wo         = each.value.generate_random_value ? ephemeral.random_password.generated_by_us.result : "dummy-value"
  secret_string_wo_version = 1
}

resource "aws_secretsmanager_secret" "external_global" {
  #checkov:skip=CKV2_AWS_57: we're not ready to enable automatic rotation
  for_each = var.external_global_secrets

  name        = "/external/global/${each.value.name}"
  description = each.value.description
  kms_key_id  = aws_kms_key.external_global.id
}

resource "aws_secretsmanager_secret_version" "external_global" {
  for_each = var.external_global_secrets

  secret_id                = aws_secretsmanager_secret.external_global[each.key].id
  secret_string_wo         = each.value.generate_random_value ? ephemeral.random_password.generated_by_us.result : "dummy-value"
  secret_string_wo_version = 1
}

# Cross-account resource policies for external secrets in environment types
# Allow ECS task execution roles from environment accounts to read secrets for their environment type
resource "aws_secretsmanager_secret_policy" "external_environment_type_cross_account" {
  for_each = {
    for secret in local.secrets_in_environment_type : secret.name => secret
    if contains(keys(local.environment_type_to_account_id), secret.environment_type)
  }

  secret_arn = aws_secretsmanager_secret.external_environment_type[each.value.name].arn
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowECSTaskExecutionRoleAccess"
        Effect = "Allow"
        Principal = {
          AWS = [
            # Allow all ECS task execution roles in the environment account for this environment type
            "arn:aws:iam::${local.environment_type_to_account_id[each.value.environment_type]}:role/*-ecs-task-execution"
          ]
        }
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = "*"
      }
    ]
  })
}

# Cross-account resource policies for external global secrets
# Allow ECS task execution roles from all environment accounts to read global secrets
resource "aws_secretsmanager_secret_policy" "external_global_cross_account" {
  for_each = var.external_global_secrets

  secret_arn = aws_secretsmanager_secret.external_global[each.key].arn
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowECSTaskExecutionRoleAccess"
        Effect = "Allow"
        Principal = {
          AWS = [
            for account_id in values(local.environment_type_to_account_id) :
            "arn:aws:iam::${account_id}:role/*-ecs-task-execution"
          ]
        }
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = "*"
      }
    ]
  })
}
