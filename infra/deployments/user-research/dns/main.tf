locals {
  aws_alb = "forms-user-research-752966643.eu-west-2.elb.amazonaws.com"
}

resource "aws_route53_zone" "public" {
  #checkov:skip=CKV2_AWS_38:DNSSEC is not currently necessary
  #checkov:skip=CKV2_AWS_39:DNS query logging not necessary
  name = "research.forms.service.gov.uk."

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_route53_record" "runner" {
  zone_id = aws_route53_zone.public.id
  name    = "submit.research.forms.service.gov.uk"
  type    = "CNAME"
  ttl     = 60
  records = [local.aws_alb]
}

resource "aws_route53_record" "admin" {
  zone_id = aws_route53_zone.public.id
  name    = "admin.research.forms.service.gov.uk"
  type    = "CNAME"
  ttl     = 60
  records = [local.aws_alb]
}

resource "aws_route53_record" "api" {
  zone_id = aws_route53_zone.public.id
  name    = "api.research.forms.service.gov.uk"
  type    = "CNAME"
  ttl     = 60
  records = [local.aws_alb]
}

resource "aws_route53_record" "product-page" {
  zone_id = aws_route53_zone.public.id
  name    = "www.research.forms.service.gov.uk"
  type    = "CNAME"
  ttl     = 60
  records = [local.aws_alb]
}

data "aws_elb_hosted_zone_id" "main" {}

resource "aws_route53_record" "apex-domain" {
  #checkov:skip=CKV2_AWS_23:Not applicable to alias records
  zone_id = aws_route53_zone.public.id
  name    = "research.forms.service.gov.uk"
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
