resource "auth0_client" "forms_admin" {
  name     = "forms-admin-${var.env_name}"
  app_type = "regular_web"
  logo_uri = "${var.admin_base_url}${var.app_logo_path}"

  allowed_logout_urls = [
    "${var.admin_base_url}"
  ]
  callbacks = [
    "${var.admin_base_url}${var.app_auth_callback_path}"
  ]

  is_first_party = true

  jwt_configuration {
    alg = "RS256"
  }
}

resource "auth0_client_credentials" "forms_admin" {
  client_id = auth0_client.forms_admin.id

  authentication_method = "client_secret_post"
}

# Get Terraform to copy the secrets over to AWS for us
#

resource "aws_ssm_parameter" "forms_admin_client_id" {
  #checkov:skip=CKV_AWS_337:The parameter is already using the default key

  name  = "/forms-admin-${var.env_name}/auth0/client-id"
  type  = "SecureString"
  value = auth0_client_credentials.forms_admin.client_id
}

resource "aws_ssm_parameter" "forms_admin_client_secret" {
  #checkov:skip=CKV_AWS_337:The parameter is already using the default key

  name  = "/forms-admin-${var.env_name}/auth0/client-secret"
  type  = "SecureString"
  value = auth0_client_credentials.forms_admin.client_secret
}

resource "aws_ssm_parameter" "forms_admin_domain" {
  #checkov:skip=CKV_AWS_337:The parameter is already using the default key

  name  = "/forms-admin-${var.env_name}/auth0/domain"
  type  = "SecureString"
  value = data.auth0_tenant.tenant.domain
}
