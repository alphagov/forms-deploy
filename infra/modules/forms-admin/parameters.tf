resource "aws_ssm_parameter" "mailchimp_api_key" {
  #checkov:skip=CKV_AWS_337:KMS managed key is fine
  name  = "/forms-admin-${var.env_name}/mailchimp-api-key"
  type  = "SecureString"
  value = "dummy_value"

  lifecycle {
    ignore_changes = [value]
  }
}

# Secret Key Base
# Rails uses secret_key_base as the input secret to the application's key generator.
# We use this mostly for cookies, and we create and store one per app
# This secret stores a manually generated random value. As an example, you can generate a new one by running:
# ruby -e "require 'securerandom'; puts SecureRandom.hex(64)"
resource "aws_ssm_parameter" "secret_key_base" {
  #checkov:skip=CKV_AWS_337:KMS managed key is fine

  name        = "/forms-admin-${var.env_name}/secret-key-base"
  description = "Rails secret_key_base value for forms-admin in the ${var.env_name} environment"
  type        = "SecureString"
  value       = "dummy-value"

  lifecycle {
    ignore_changes = [
      value
    ]
  }
}

# Sentry Data Source Name (DSN)
# This value tells Sentry where to send events to that they are associated with the correct project
resource "aws_ssm_parameter" "sentry_dsn" {
  #checkov:skip=CKV_AWS_337:KMS managed key is fine

  name        = "/forms-admin-${var.env_name}/sentry/dsn"
  description = "Sentry DSN value for forms-admin in the ${var.env_name} environment"
  type        = "SecureString"
  value       = "dummy-value"

  lifecycle {
    ignore_changes = [
      value
    ]
  }
}

resource "aws_ssm_parameter" "notify_api_key" {
  #checkov:skip=CKV_AWS_337:The parameter is already using the default key

  name        = "/forms-admin-${var.env_name}/notify-api-key"
  description = "API key for forms-admin to connect with GOV.UK Notify (${var.env_name} environment)"
  type        = "SecureString"
  value       = "dummy-value"

  lifecycle {
    ignore_changes = [
      value
    ]
  }
}


# Even though we no longer use GDS SSO (GOV.UK Signon), our codebase still depends on it
resource "aws_ssm_parameter" "gds_sso_oauth_id" {
  #checkov:skip=CKV_AWS_337:The parameter is already using the default key

  name        = "/forms-admin-${var.env_name}/gds-sso-oauth-id"
  description = "Oauth ID to authenticate forms-admin-${var.env_name} with GOVUK Signon"
  type        = "SecureString"
  value       = "dummy-value"

  lifecycle {
    ignore_changes = [
      value
    ]
  }
}

# Even though we no longer use GDS SSO (GOV.UK Signon), our codebase still depends on it
resource "aws_ssm_parameter" "gds_sso_oauth_secret" {
  #checkov:skip=CKV_AWS_337:The parameter is already using the default key

  name        = "/forms-admin-${var.env_name}/gds-sso-oauth-secret"
  description = "Oauth secret to authenticate forms-admin-${var.env_name} with GOVUK Signon"
  type        = "SecureString"
  value       = "dummy-value"

  lifecycle {
    ignore_changes = [
      value
    ]
  }
}
