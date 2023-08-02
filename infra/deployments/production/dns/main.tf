locals {
  paas_admin_cloudfront_distribution  = "d3r22e84hwvy8u.cloudfront.net"
  paas_runner_cloudfront_distribution = "d38kosxua6o1pg.cloudfront.net"
  aws_alb                             = "forms-production-1193111259.eu-west-2.elb.amazonaws.com"
}

resource "aws_route53_zone" "public" {
  #checkov:skip=CKV2_AWS_38:DNSSEC is not currently necessary
  #checkov:skip=CKV2_AWS_39:DNS query logging not necessary
  name = "forms.service.gov.uk."

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_route53_record" "runner" {
  zone_id = aws_route53_zone.public.id
  name    = "submit.forms.service.gov.uk"
  type    = "CNAME"
  ttl     = 300
  records = [local.aws_alb]
}

resource "aws_route53_record" "admin" {
  zone_id = aws_route53_zone.public.id
  name    = "admin.forms.service.gov.uk"
  type    = "CNAME"
  ttl     = 300
  records = [local.aws_alb]
}

resource "aws_route53_record" "api" {
  zone_id = aws_route53_zone.public.id
  name    = "api.forms.service.gov.uk"
  type    = "CNAME"
  ttl     = 60
  records = [local.aws_alb]
}

resource "aws_route53_record" "delegate_dev_domain" {
  zone_id = aws_route53_zone.public.id
  name    = "dev.forms.service.gov.uk."
  type    = "NS"
  ttl     = 60
  records = [
    "ns-124.awsdns-15.com",
    "ns-1371.awsdns-43.org",
    "ns-2043.awsdns-63.co.uk",
    "ns-593.awsdns-10.net",
  ]
}

resource "aws_route53_record" "delegate_staging_domain" {
  zone_id = aws_route53_zone.public.id
  name    = "staging.forms.service.gov.uk."
  type    = "NS"
  ttl     = 60
  records = [
    "ns-1162.awsdns-17.org",
    "ns-1604.awsdns-08.co.uk",
    "ns-359.awsdns-44.com",
    "ns-638.awsdns-15.net",
  ]
}

resource "aws_route53_record" "delegate_research_domain" {
  zone_id = aws_route53_zone.public.id
  name    = "research.forms.service.gov.uk."
  type    = "NS"
  ttl     = 60
  records = [
    "ns-1068.awsdns-05.org",
    "ns-1742.awsdns-25.co.uk",
    "ns-279.awsdns-34.com",
    "ns-950.awsdns-54.net",
  ]
}
