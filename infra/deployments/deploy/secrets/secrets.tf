resource "aws_secretsmanager_secret" "mailchimp_api_key" {
  for_each = local.environment_type

  name       = "external/${each.key}/mailchimp/api-key"
  kms_key_id = aws_kms_key.external_env_type[each.key].id
}

resource "aws_secretsmanager_secret" "zendesk_api_user" {
  for_each = local.environment_type

  name       = "external/${each.key}/zendesk/api-user"
  kms_key_id = aws_kms_key.this[each.key].id
}

resource "aws_secretsmanager_secret" "zendesk_api_key" {
  for_each = local.environment_type

  name       = "external/${each.key}/zendesk/api-key"
  kms_key_id = aws_kms_key.this[each.key].id
}

resource "aws_secretsmanager_secret" "auth0_machine_user_email" {
  for_each = local.environment_type

  name       = "external/${each.key}/auth0/machine-user/email"
  kms_key_id = aws_kms_key.this[each.key].id
}

resource "aws_secretsmanager_secret" "auth0_machine_user_password" {
  for_each = local.environment_type

  name       = "external/${each.key}/auth0/machine-user/password"
  kms_key_id = aws_kms_key.this[each.key].id
}

resource "aws_secretsmanager_secret" "notify_api_key" {
  for_each = local.environment_type

  name       = "external/${each.key}/notify/api-key"
  kms_key_id = aws_kms_key.this[each.key].id
}

resource "aws_secretsmanager_secret" "account_contact_phone_number" {
  for_each = local.environment_type

  name       = "external/${each.key}/account/contact-phone-number"
  kms_key_id = aws_kms_key.this[each.key].id
}

resource "aws_secretsmanager_secret" "account_contact_email" {
  for_each = local.environment_type

  name       = "external/${each.key}/account/contact-email"
  kms_key_id = aws_kms_key.this[each.key].id
}

resource "aws_secretsmanager_secret" "account_emergency_email" {
  for_each = local.environment_type

  name       = "external/${each.key}/account/emergency-email"
  kms_key_id = aws_kms_key.this[each.key].id
}

resource "aws_secretsmanager_secret" "account_emergency_phone_number" {
  for_each = local.environment_type

  name       = "external/${each.key}/account/emergency-phone-number"
  kms_key_id = aws_kms_key.this[each.key].id
}

resource "aws_secretsmanager_secret" "dockerhub_username" {
  for_each = local.environment_type

  name       = "external/${each.key}/dockerhub/username"
  kms_key_id = aws_kms_key.this[each.key].id
}

resource "aws_secretsmanager_secret" "dockerhub_password" {
  for_each = local.environment_type

  name       = "external/${each.key}/dockerhub/password"
  kms_key_id = aws_kms_key.this[each.key].id
}

resource "aws_secretsmanager_secret" "google_oauth_client_secret" {
  for_each = local.environment_type

  name       = "external/${each.key}/google/oauth/client-secret"
  kms_key_id = aws_kms_key.this[each.key].id
}

resource "aws_secretsmanager_secret" "google_oauth_client_id" {
  for_each = local.environment_type

  name       = "external/${each.key}/google/oauth/client-id"
  kms_key_id = aws_kms_key.this[each.key].id
}