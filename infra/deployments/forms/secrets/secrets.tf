# This resource requires a kms key created manually in the "account" root. The "account" root is applied manually (by a human) and it can give the deployer role the correct permissions in the kms key. If we created the kms key here instead, the pipelines would fail until we manually give the correct permissions because the deployer role can't give itself access to the kms key.
resource "aws_secretsmanager_secret" "internal" {
  #checkov:skip=CKV2_AWS_57: we're not ready to enable automatic rotation
  for_each = toset(var.internal_secrets)

  name        = "/internal/${var.environment_name}/${var.all_internal_secrets[each.value].name}"
  description = var.all_internal_secrets[each.value].description
  kms_key_id  = data.terraform_remote_state.account.outputs.internal_kms_key_id
}

ephemeral "random_password" "generated_by_us" {
  length           = 16
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_secretsmanager_secret_version" "internal" {
  for_each = toset(var.internal_secrets)

  secret_id                = aws_secretsmanager_secret.internal[each.value].id
  secret_string_wo         = var.all_internal_secrets[each.value].generate_random_value ? ephemeral.random_password.generated_by_us.result : "dummy-value"
  secret_string_wo_version = 1
}

output "internal_secrets_ids" {
  value = {
    for k, secret in var.internal_secrets : secret => aws_secretsmanager_secret_version.internal[secret].secret_id
  }
}

output "internal_secrets_arns" {
  value = {
    for k, secret in var.internal_secrets : secret =>
    aws_secretsmanager_secret_version.internal[secret].arn
  }
}