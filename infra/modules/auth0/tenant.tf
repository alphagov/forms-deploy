resource "auth0_tenant" "tenant" {
  friendly_name = "GOV.UK Forms (${var.env_name})"
}
