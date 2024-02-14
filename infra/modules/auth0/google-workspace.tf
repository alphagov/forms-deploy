resource "aws_ssm_parameter" "google_oauth_client_id" {
  #checkov:skip=CKV_AWS_337:The parameter is already using the default key
  # Value is set externally.
  name  = "/forms-admin-${var.env_name}/google-oauth/client-id"
  type  = "SecureString"
  value = "dummy-client-id"

  lifecycle {
    ignore_changes = [
      value
    ]
  }
}

resource "aws_ssm_parameter" "google_oauth_client_secret" {
  #checkov:skip=CKV_AWS_337:The parameter is already using the default key
  # Value is set externally.
  name  = "/forms-admin-${var.env_name}/google-oauth/client-secret"
  type  = "SecureString"
  value = "dummy-client-secret"

  lifecycle {
    ignore_changes = [
      value
    ]
  }
}

data "aws_ssm_parameter" "google_oauth_client_id" {
  name = "/forms-admin-${var.env_name}/google-oauth/client-id"

  depends_on = [aws_ssm_parameter.google_oauth_client_id]
}

data "aws_ssm_parameter" "google_oauth_client_secret" {
  name = "/forms-admin-${var.env_name}/google-oauth/client-secret"

  depends_on = [aws_ssm_parameter.google_oauth_client_secret]
}
