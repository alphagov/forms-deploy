resource "aws_route53_zone" "public" {
  #checkov:skip=CKV2_AWS_38:DNSSEC is not currently necessary
  #checkov:skip=CKV2_AWS_39:DNS query logging not necessary
  name = "stage.forms.service.gov.uk."

  lifecycle {
    prevent_destroy = true
  }
}

output "name_servers" {
  value = aws_route53_zone.public.name_servers
}
