resource "aws_secretsmanager_secret" "internal" {
  #checkov:skip=CKV2_AWS_57: we're not ready to enable automatic rotation
  for_each = var.internal_secrets

  name        = "/internal/${var.environment_name}/${each.value.name}"
  description = each.value.description
  kms_key_id  = aws_kms_key.internal.id
}
