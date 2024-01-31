
resource "auth0_connection" "username_password_connection" {
  strategy = "auth0"
  name     = "Username-Password-Authentication"
  options {
    brute_force_protection = true
    disable_signup         = true
  }
}

resource "auth0_connection_clients" "username_password_connection_clients" {
  connection_id = auth0_connection.username_password_connection.id
  enabled_clients = [
    auth0_client.forms_admin.id,
    auth0_client.forms_admin_e2e.id
  ]
}
