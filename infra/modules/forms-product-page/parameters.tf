# Secret Key Base
# Rails uses secret_key_base as the input secret to the application's key generator.
# We use this mostly for cookies, and we create and store one per app
# This secret stores a manually generated random value. As an example, you can generate a new one by running:
# ruby -e "require 'securerandom'; puts SecureRandom.hex(64)"
resource "aws_ssm_parameter" "secret_key_base" {
  #checkov:skip=CKV_AWS_337:KMS managed key is fine

  name        = "/forms-product-page-${var.env_name}/secret-key-base"
  description = "Rails secret_key_base value for forms-product-page in the ${var.env_name} environment"
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

  name        = "/forms-product-page-${var.env_name}/sentry/dsn"
  description = "Sentry DSN value for forms-product-page in the ${var.env_name} environment"
  type        = "SecureString"
  value       = "dummy-value"

  lifecycle {
    ignore_changes = [
      value
    ]
  }
}
