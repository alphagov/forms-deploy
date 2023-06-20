resource "aws_route53_zone" "public" {
  #checkov:skip=CKV2_AWS_38:DNSSEC is not currently necessary
  #checkov:skip=CKV2_AWS_39:DNS query logging not necessary
  name = "forms.service.gov.uk."

  lifecycle {
    prevent_destroy = true
  }
}

# This will not be required after the migration
resource "aws_route53_record" "temp_aws_cloudfront" {
  zone_id = aws_route53_zone.public.id
  name    = "*.prod-temp.forms.service.gov.uk."
  type    = "CNAME"
  ttl     = 60
  records = ["d2wbtpx65ue6b2.cloudfront.net"]
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

# stage is a temporary sub domain for the aws staging environment. It will be dropped after the cutover
resource "aws_route53_record" "delegate_stage_domain" {
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
