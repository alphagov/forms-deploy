resource "aws_route53_zone" "public" {
  name = "dev.forms.service.gov.uk."
}

output "name_servers" {
  value = aws_route53_zone.public.name_servers
}
