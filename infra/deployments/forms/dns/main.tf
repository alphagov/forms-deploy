data "aws_cloudfront_distribution" "main" {
  id = "EXITHSOVYUXHW"
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
  records = [data.aws_cloudfront_distribution.main.domain_name]
}

resource "aws_route53_record" "admin" {
  zone_id = aws_route53_zone.public.id
  name    = "admin.forms.service.gov.uk"
  type    = "CNAME"
  ttl     = 300
  records = [data.aws_cloudfront_distribution.main.domain_name]
}

resource "aws_route53_record" "api" {
  zone_id = aws_route53_zone.public.id
  name    = "api.forms.service.gov.uk"
  type    = "CNAME"
  ttl     = 60
  records = [data.aws_cloudfront_distribution.main.domain_name]
}

resource "aws_route53_record" "product-page" {
  zone_id = aws_route53_zone.public.id
  name    = "www.forms.service.gov.uk"
  type    = "CNAME"
  ttl     = 300
  records = [data.aws_cloudfront_distribution.main.domain_name]
}

data "aws_elb_hosted_zone_id" "main" {}

resource "aws_route53_record" "apex-domain" {
  #checkov:skip=CKV2_AWS_23:Not applicable to alias records
  zone_id = aws_route53_zone.public.id
  name    = "forms.service.gov.uk"
  type    = "A"

  alias {
    name                   = data.aws_cloudfront_distribution.main.domain_name
    zone_id                = data.aws_cloudfront_distribution.main.hosted_zone_id
    evaluate_target_health = true
  }
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
