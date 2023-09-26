resource "auth0_email_provider" "smtp_email_provider" {
  name                 = "smtp"
  enabled              = true
  default_from_address = var.smtp_from_address

  credentials {
    smtp_host = var.smtp_host
    smtp_port = var.smtp_port
    smtp_user = var.smtp_username
    smtp_pass = var.smtp_password
  }
}