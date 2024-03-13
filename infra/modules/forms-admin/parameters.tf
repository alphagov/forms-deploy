resource "aws_ssm_parameter" "mailchimp_api_key" {
  #checkov:skip=CKV_AWS_337:KMS managed key is fine
  name  = "/forms-admin-${var.env_name}/mailchimp-api-key"
  type  = "SecureString"
  value = "dummy_value"

  lifecycle {
    ignore_changes = [value]
  }
}