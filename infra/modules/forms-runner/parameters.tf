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
