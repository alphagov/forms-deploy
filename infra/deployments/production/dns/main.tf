data "aws_route53_zone" "public" {
  name         = "forms.service.gov.uk."
  private_zone = false
}

resource "aws_route53_record" "delegate_dev_domain" {
  zone_id = data.aws_route53_zone.public.id
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

