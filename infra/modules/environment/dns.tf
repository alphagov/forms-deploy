resource "aws_route53_zone" "private_internal" {
  #checkov:skip=CKV2_AWS_38:DNSSEC is not currently necessary for private zones
  #checkov:skip=CKV2_AWS_39:DNS query logging not necessary for private zones
  name = "internal.${var.root_domain}."

  vpc {
    vpc_id = aws_vpc.forms.id
  }

  lifecycle {
    prevent_destroy = true
  }
}