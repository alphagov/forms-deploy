resource "aws_route53_zone" "tools_zone" {
  name = "tools.forms.service.gov.uk."
  lifecycle {
    prevent_destroy = true
  }
}
