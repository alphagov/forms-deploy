data "aws_ssm_parameter" "smtp_username" {
  name = "/ses/auth0-smtp-username"
}

data "aws_ssm_parameter" "smtp_password" {
  name = "/ses/auth0-smtp-password"
}

resource "auth0_email_provider" "smtp_email_provider" {
  name                 = "smtp"
  enabled              = true
  default_from_address = var.smtp_from_address

  credentials {
    smtp_host = var.smtp_host
    smtp_port = var.smtp_port
    smtp_user = data.aws_ssm_parameter.smtp_username.value
    smtp_pass = data.aws_ssm_parameter.smtp_password.value
  }
}
