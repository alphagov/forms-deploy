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

output "name_servers" {
  value = aws_route53_zone.public.name_servers
}
