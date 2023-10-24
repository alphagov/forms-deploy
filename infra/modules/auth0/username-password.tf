
resource "auth0_connection" "username_password_connection" {
  strategy = "auth0"
  name     = "Username-Password-Authentication"
  options {
    brute_force_protection = true
    disable_signup         = true
  }
}
