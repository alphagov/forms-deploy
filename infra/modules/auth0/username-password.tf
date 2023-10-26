
resource "auth0_connection" "username_password_connection" {
  strategy = "auth0"
  name     = "Username-Password-Authentication"
  options {
    brute_force_protection = true
    disable_signup         = true
  }
}

resource "auth0_connection_client" "forms_admin_username_password" {
  connection_id = auth0_connection.username_password_connection.id
  client_id     = auth0_client.forms_admin.id
}
