resource "auth0_connection" "google_workspace" {
  name           = "Google-Workspace"
  strategy       = "google-apps"
  show_as_button = false
  options {
    api_enable_users         = true
    client_id                = data.aws_ssm_parameter.google_oauth_client_id.value
    client_secret            = data.aws_ssm_parameter.google_oauth_client_secret.value
    domain                   = "digital.cabinet-office.gov.uk"
    domain_aliases           = ["digital.cabinet-office.gov.uk"]
    set_user_root_attributes = "on_each_login"
    tenant_domain            = "digital.cabinet-office.gov.uk"
  }
}

resource "auth0_connection_clients" "google_workspace_connection_clients" {
  connection_id = auth0_connection.google_workspace.id
  enabled_clients = [
    auth0_client.forms_admin.id
  ]
}

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
