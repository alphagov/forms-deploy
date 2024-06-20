resource "auth0_client" "forms_admin_e2e" {
  name     = "forms-admin-${var.env_name}-e2e"
  app_type = "regular_web"
  logo_uri = "${var.admin_base_url}${var.app_logo_path}"

  initiate_login_uri  = "${var.admin_base_url}${var.app_auth_path}"
  allowed_logout_urls = [var.admin_base_url]
  callbacks = [
    "${var.admin_base_url}${var.app_auth_callback_path}"
  ]

  is_first_party = true

  jwt_configuration {
    alg = "RS256"
  }
}

resource "auth0_client_credentials" "forms_admin_e2e" {
  client_id = auth0_client.forms_admin_e2e.id

  authentication_method = "client_secret_post"
}

# Get Terraform to copy the secrets over to AWS for us

resource "aws_ssm_parameter" "forms_admin_e2e_client_id" {
  #checkov:skip=CKV_AWS_337:The parameter is already using the default key
  #checkov:skip=CKV2_FORMS_AWS_7:We know the correct value at runtime and should not ignore changes to it

  name  = "/forms-admin-${var.env_name}/auth0/e2e-client-id"
  type  = "SecureString"
  value = auth0_client_credentials.forms_admin_e2e.client_id
}

resource "aws_ssm_parameter" "forms_admin_e2e_client_secret" {
  #checkov:skip=CKV_AWS_337:The parameter is already using the default key
  #checkov:skip=CKV2_FORMS_AWS_7:We know the correct value at runtime and should not ignore changes to it

  name  = "/forms-admin-${var.env_name}/auth0/e2e-client-secret"
  type  = "SecureString"
  value = auth0_client_credentials.forms_admin_e2e.client_secret
}
