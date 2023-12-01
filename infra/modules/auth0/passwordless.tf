data "template_file" "en_passwordless_email_body" {
  template = file("${path.module}/content/en/email_templates/passwordless_email_body.html")
  vars = {
    otp_expiry_minutes = floor(var.otp_expiry_length / 60)
  }
}

locals {
  en = {
    email_templates = {
      passwordless_email = merge(
        jsondecode(templatefile("${path.module}/content/en/email_templates/passwordless_email.json.tftpl", { from_address = var.smtp_from_address })),
        {
          body = data.template_file.en_passwordless_email_body.rendered
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

resource "auth0_connection_client" "forms_admin_passwordless_email" {
  connection_id = auth0_connection.passwordless_email.id
  client_id     = auth0_client.forms_admin.id
}
