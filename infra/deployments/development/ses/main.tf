module "users" {
  source = "../../../modules/users"
}

module "ses" {
  source = "../../../modules/ses"

  verified_email_addresses = concat(
    [
      for user in module.users.for_env["dev"] : "${user}@digital.cabinet-office.gov.uk"
    ],
    [
      "forms--test-automation-groupt@digital.cabinet-office.gov.uk", # smoke tests user
    ],
  )

  email_domain = "dev.forms.service.gov.uk"
  from_address = "no-reply@dev.forms.service.gov.uk"
  environment  = "dev"
}

# this zone should be managed in the dns deployment module for the environment
data "aws_route53_zone" "public" {
  name = "dev.forms.service.gov.uk."
}

resource "aws_ses_domain_identity" "ses" {
  domain = "dev.forms.service.gov.uk"
}

resource "aws_ses_domain_dkim" "ses" {
  domain = aws_ses_domain_identity.ses.domain
}

resource "aws_route53_record" "ses" {
  count   = 3
  zone_id = data.aws_route53_zone.public.id
  name    = "${aws_ses_domain_dkim.ses.dkim_tokens[count.index]}._domainkey"
  type    = "CNAME"
  ttl     = 600
  records = ["${aws_ses_domain_dkim.ses.dkim_tokens[count.index]}.dkim.amazonses.com"]
}

resource "aws_route53_record" "ses_email_receiving" {
  zone_id = data.aws_route53_zone.public.id
  name    = aws_ses_domain_identity.ses.domain
  type    = "MX"
  records = ["10 inbound-smtp.eu-west-2.amazonaws.com"]
  ttl     = 3600
}
