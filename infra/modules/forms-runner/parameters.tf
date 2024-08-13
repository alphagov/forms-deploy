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
