resource "aws_ses_domain_identity" "ses" {
  domain = var.email_domain
}

resource "aws_ses_domain_dkim" "ses" {
  domain = aws_ses_domain_identity.ses.domain
}

resource "aws_ses_domain_mail_from" "mail" {
  domain           = aws_ses_domain_identity.ses.domain
  mail_from_domain = "mail.${aws_ses_domain_identity.ses.domain}"
}
