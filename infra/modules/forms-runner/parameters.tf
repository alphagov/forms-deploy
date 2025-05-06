resource "aws_ssm_parameter" "forms_api_key" {
  #checkov:skip=CKV_AWS_337:KMS managed key is fine
  name  = "/forms-runner-${var.env_name}/forms-api-key"
  type  = "SecureString"
  value = "dummy_value"

  description = "API key to access forms-api"

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "notify_api_key" {
  #checkov:skip=CKV_AWS_337:KMS managed key is fine
  name  = "/forms-runner-${var.env_name}/notify-api-key"
  type  = "SecureString"
  value = "dummy_value"

  description = "API key to connect with GOV.UK Notify"

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

  name        = "/forms-runner-${var.env_name}/secret-key-base"
  description = "Rails secret_key_base value for forms-runner in the ${var.env_name} environment"
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

  name        = "/forms-runner-${var.env_name}/sentry/dsn"
  description = "Sentry DSN value for forms-runner in the ${var.env_name} environment"
  type        = "SecureString"
  value       = "dummy-value"

  lifecycle {
    ignore_changes = [
      value
    ]
  }
}

resource "aws_ssm_parameter" "active_record_encryption_primary_key" {
  #checkov:skip=CKV_AWS_337:The parameter is already using the default key

  name        = "/forms-runner-${var.env_name}/active_record_encryption_primary_key"
  description = "The primary key for encrypting the database with ActiveRecord Encrypt"
  type        = "SecureString"
  value       = "dummy-value"

  lifecycle {
    ignore_changes = [
      value
    ]
  }
}

resource "aws_ssm_parameter" "active_record_encryption_deterministic_key" {
  #checkov:skip=CKV_AWS_337:The parameter is already using the default key

  name        = "/forms-runner-${var.env_name}/active_record_encryption_deterministic_key"
  description = "The deterministic key for encrypting the database with ActiveRecord Encrypt"
  type        = "SecureString"
  value       = "dummy-value"

  lifecycle {
    ignore_changes = [
      value
    ]
  }
}

resource "aws_ssm_parameter" "active_record_encryption_derivation_salt" {
  #checkov:skip=CKV_AWS_337:The parameter is already using the default key

  name        = "/forms-runner-${var.env_name}/active_record_encryption_derivation_salt"
  description = "The derivative salt for encrypting the database with ActiveRecord Encrypt"
  type        = "SecureString"
  value       = "dummy-value"

  lifecycle {
    ignore_changes = [
      value
    ]
  }
}
