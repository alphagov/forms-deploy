data "aws_route53_zone" "private_internal" {
  name         = "internal.${var.root_domain}."
  private_zone = true
}

resource "aws_route53_zone_association" "private_internal" {
  zone_id = data.aws_route53_zone.private_internal.zone_id
  vpc_id  = aws_vpc.forms.id
}
