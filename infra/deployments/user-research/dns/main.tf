resource "aws_route53_zone" "public" {
  #checkov:skip=CKV2_AWS_38:DNSSEC is not currently necessary
  #checkov:skip=CKV2_AWS_39:DNS query logging not necessary
  name = "research.forms.service.gov.uk."

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_route53_record" "research" {
  zone_id = aws_route53_zone.public.id
  name    = "*.research.forms.service.gov.uk."
  type    = "CNAME"
  ttl     = 60
  records = ["forms-user-research-752966643.eu-west-2.elb.amazonaws.com"]
}

output "name_servers" {
  value = aws_route53_zone.public.name_servers
}
