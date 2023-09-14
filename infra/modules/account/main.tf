resource "aws_account_alternate_contact" "security" {
  alternate_contact_type = "SECURITY"
  name                   = "GOV.UK Forms Infrastructure Team"
  title                  = "Infra Team"
  email_address          = data.aws_ssm_parameter.contact_email.value
  phone_number           = data.aws_ssm_parameter.contact_phone_number.value
}

resource "aws_account_alternate_contact" "operations" {
  alternate_contact_type = "OPERATIONS"
  name                   = "GOV.UK Forms Infrastructure Team"
  title                  = "Infra Team"
  email_address          = data.aws_ssm_parameter.contact_email.value
  phone_number           = data.aws_ssm_parameter.contact_phone_number.value
}

resource "aws_ssm_parameter" "contact_email" {
  name  = "contact-email"
  type  = "SecureString"
  value = "dummy-email-address@digital.cabinet-office.gov.uk"

  lifecycle {
    ignore_changes = [
      value
    ]
  }
}

resource "aws_ssm_parameter" "contact_phone_number" {
  name  = "contact-phone-number"
  type  = "SecureString"
  value = "+1234567890"

  lifecycle {
    ignore_changes = [
      value
    ]
  }
}

data "aws_ssm_parameter" "contact_phone_number" {
  name = "contact-phone-number"

  depends_on = [aws_ssm_parameter.contact_phone_number]
}

data "aws_ssm_parameter" "contact_email" {
  name = "contact-email"

  depends_on = [aws_ssm_parameter.contact_email]
}

