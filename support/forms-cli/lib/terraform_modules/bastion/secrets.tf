data "aws_ssm_parameter" "database_url_secrets" {
  for_each        = toset(var.databases)
  name            = "/${each.value}-${var.environment}/database/url"
  with_decryption = false
}
