locals {
  en = {
    email_templates = {
      passwordless_email = merge(
        jsondecode(file("${path.module}/content/en/email_templates/passwordless_email.json")),
        {
          body = file("${path.module}/content/en/email_templates/passwordless_email_body.html")
        }
      )
    }
  }
}

resource "auth0_connection" "passwordless_email" {
  strategy = "email"
  name     = "email" # name must be "email" to be visible in the Auth0 web console

  options {
    name = "email"

    syntax   = "liquid"
    from     = local.en.email_templates.passwordless_email.from
    subject  = local.en.email_templates.passwordless_email.subject
    template = local.en.email_templates.passwordless_email.body

    auth_params = {
      scope = "openid profile"
    }
    brute_force_protection = true

    totp {
      time_step = 180
      length    = 6
    }
  }
}

resource "auth0_connection_client" "forms_admin_passwordless_email" {
  connection_id = auth0_connection.passwordless_email.id
  client_id     = auth0_client.forms_admin.id
}
