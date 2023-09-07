resource "auth0_tenant" "tenant" {
  friendly_name = "GOV.UK Forms (${var.env_name})"
  picture_url   = "${var.admin_base_url}/${var.app_logo_path}"
}
