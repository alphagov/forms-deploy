locals {
  en = {
    email_templates = {
      passwordless_email = merge(
        jsondecode(templatefile("${path.module}/content/en/email_templates/passwordless_email.json.tftpl", { from_address = var.smtp_from_address })),
        {
          body = templatefile("${path.module}/content/en/email_templates/passwordless_email_body.html", { otp_expiry_minutes = floor(var.otp_expiry_length / 60) })
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
      time_step = var.otp_expiry_length
      length    = 6
    }
  }
}

resource "auth0_connection_clients" "passwordless_email_connection_clients" {
  connection_id = auth0_connection.passwordless_email.id
  enabled_clients = [
    auth0_client.forms_admin.id,
  ]
}
