
data "aws_cloudfront_distribution" "main" {
  id = "E3PQV6DYYCB9KW"
}

resource "aws_route53_zone" "public" {
  #checkov:skip=CKV2_AWS_38:DNSSEC is not currently necessary
  #checkov:skip=CKV2_AWS_39:DNS query logging not necessary
  name = "staging.forms.service.gov.uk."

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_route53_record" "runner" {
  zone_id = aws_route53_zone.public.id
  name    = "submit.staging.forms.service.gov.uk"
  type    = "CNAME"
  ttl     = 60
  records = [data.aws_cloudfront_distribution.main.domain_name]
}

resource "aws_route53_record" "admin" {
  zone_id = aws_route53_zone.public.id
  name    = "admin.staging.forms.service.gov.uk"
  type    = "CNAME"
  ttl     = 60
  records = [data.aws_cloudfront_distribution.main.domain_name]
}

resource "aws_route53_record" "api" {
  zone_id = aws_route53_zone.public.id

  name    = "api.staging.forms.service.gov.uk"
  type    = "CNAME"
  ttl     = 60
  records = [data.aws_cloudfront_distribution.main.domain_name]
}
resource "aws_route53_record" "product-page" {
  zone_id = aws_route53_zone.public.id
  name    = "www.staging.forms.service.gov.uk"
  type    = "CNAME"
  ttl     = 60
  records = [data.aws_cloudfront_distribution.main.domain_name]
}

resource "aws_route53_record" "apex-domain" {
  #checkov:skip=CKV2_AWS_23:Not applicable to alias records
  zone_id = aws_route53_zone.public.id
  name    = "staging.forms.service.gov.uk"
  type    = "A"

  alias {
    name                   = data.aws_cloudfront_distribution.main.domain_name
    zone_id                = data.aws_cloudfront_distribution.main.hosted_zone_id
    evaluate_target_health = true
  }
}

output "staging_zone_name_servers" {
  value = aws_route53_zone.public.name_servers
}
