data "auth0_tenant" "tenant" {} # only ever allowed to access one tenant, based on API token

resource "auth0_tenant" "tenant" {
  friendly_name         = "GOV.UK Forms (${var.env_name})"
  picture_url           = "${var.admin_base_url}/${var.app_logo_path}"
  idle_session_lifetime = var.idle_session_lifetime
  session_lifetime      = var.session_lifetime
}
