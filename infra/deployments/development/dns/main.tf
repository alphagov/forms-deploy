resource "aws_route53_zone" "public" {
  #checkov:skip=CKV2_AWS_38:DNSSEC is not currently necessary
  #checkov:skip=CKV2_AWS_39:DNS query logging not necessary
  name = "dev.forms.service.gov.uk."

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_route53_record" "aws_cloudfront" {
  zone_id = aws_route53_zone.public.id
  name    = "*.dev.forms.service.gov.uk."
  type    = "CNAME"
  ttl     = 60
  records = ["d1u0sprro0b145.cloudfront.net"]
}

output "name_servers" {
  value = aws_route53_zone.public.name_servers
}
