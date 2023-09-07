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
}
