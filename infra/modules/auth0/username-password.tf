
resource "auth0_connection" "username_password_connection" {
  strategy = "auth0"
  name     = "Username-Password-Authentication"
  options {
    brute_force_protection = true
    disable_signup         = true
    password_policy        = "good"

    password_complexity_options {
      min_length = 16
    }

    password_dictionary {
      enable = true
    }

    password_no_personal_info {
      enable = true
    }
  }
}

resource "auth0_connection_clients" "username_password_connection_clients" {
  connection_id = auth0_connection.username_password_connection.id
  enabled_clients = [
    auth0_client.forms_admin_e2e.id
  ]
}
