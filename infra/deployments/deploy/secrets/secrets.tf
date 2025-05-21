resource "aws_secretsmanager_secret" "mailchimp_api_key" {
  for_each = local.environment_type

  name       = "external/${each.key}/mailchimp/api-key"
  kms_key_id = aws_kms_key.external_env_type[each.key].id
}
