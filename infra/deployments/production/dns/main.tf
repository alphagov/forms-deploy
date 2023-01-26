resource "aws_route53_zone" "public" {
  #checkov:skip=CKV2_AWS_38:DNSSEC is not currently necessary
  #checkov:skip=CKV2_AWS_39:DNS query logging not necessary
  name = "forms.service.gov.uk."

  lifecycle {
    prevent_destroy = true
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
  name    = "stage.forms.service.gov.uk."
  type    = "NS"
  ttl     = 60
  records = [
    "ns-1270.awsdns-30.org",
    "ns-1681.awsdns-18.co.uk",
    "ns-201.awsdns-25.com",
    "ns-765.awsdns-31.net",
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
