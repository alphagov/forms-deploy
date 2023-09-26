locals {
  aws_alb = "forms-dev-1285400852.eu-west-2.elb.amazonaws.com"
}

resource "aws_route53_zone" "public" {
  #checkov:skip=CKV2_AWS_38:DNSSEC is not currently necessary
  #checkov:skip=CKV2_AWS_39:DNS query logging not necessary
  name = "dev.forms.service.gov.uk."

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_ses_domain_identity" "ses" {
  domain = "dev.forms.service.gov.uk"
}

resource "aws_ses_domain_dkim" "ses" {
  domain = aws_ses_domain_identity.ses.domain
}

resource "aws_route53_record" "ses" {
  count   = 3
  zone_id = aws_route53_zone.public.id
  name    = "${aws_ses_domain_dkim.ses.dkim_tokens[count.index]}._domainkey"
  type    = "CNAME"
  ttl     = 600
  records = ["${aws_ses_domain_dkim.ses.dkim_tokens[count.index]}.dkim.amazonses.com"]
}

resource "aws_route53_record" "runner" {
  zone_id = aws_route53_zone.public.id
  name    = "submit.dev.forms.service.gov.uk"
  type    = "CNAME"
  ttl     = 60
  records = [local.aws_alb]
}

resource "aws_route53_record" "admin" {
  zone_id = aws_route53_zone.public.id
  name    = "admin.dev.forms.service.gov.uk"
  type    = "CNAME"
  ttl     = 60
  records = [local.aws_alb]
}

resource "aws_route53_record" "api" {
  zone_id = aws_route53_zone.public.id
  name    = "api.dev.forms.service.gov.uk"
  type    = "CNAME"
  ttl     = 60
  records = [local.aws_alb]
}

resource "aws_route53_record" "product-page" {
  zone_id = aws_route53_zone.public.id
  name    = "www.dev.forms.service.gov.uk"
  type    = "CNAME"
  ttl     = 60
  records = [local.aws_alb]
}

data "aws_elb_hosted_zone_id" "main" {}

resource "aws_route53_record" "apex-domain" {
  #checkov:skip=CKV2_AWS_23:Not applicable to alias records
  zone_id = aws_route53_zone.public.id
  name    = "dev.forms.service.gov.uk"
  type    = "A"

  alias {
    name                   = local.aws_alb
    zone_id                = data.aws_elb_hosted_zone_id.main.id
    evaluate_target_health = true
  }
}

output "name_servers" {
  value = aws_route53_zone.public.name_servers
}
