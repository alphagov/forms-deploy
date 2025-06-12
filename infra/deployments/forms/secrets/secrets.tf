resource "aws_secretsmanager_secret" "internal" {
  #checkov:skip=CKV2_AWS_57: we're not ready to enable automatic rotation
  for_each = toset(var.internal_secrets)

  name        = "/internal/${var.environment_name}/${var.all_internal_secrets[each.value].name}"
  description = var.all_internal_secrets[each.value].description
  kms_key_id  = aws_kms_key.internal.id
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
