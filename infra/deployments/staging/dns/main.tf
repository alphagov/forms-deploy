locals {
  paas_admin_cloudfront_distribution  = "d1o16xvhbur5rw.cloudfront.net"
  paas_runner_cloudfront_distribution = "d14wye87h7xnwn.cloudfront.net"
  aws_cloudfront_distribution         = "d291xzc38hga3k.cloudfront.net"
  aws_alb                             = "forms-staging-989380100.eu-west-2.elb.amazonaws.com"
}

# This hosted zone is for the temporary 'stage' domain which will be removed
# after the cut over.
resource "aws_route53_zone" "stage" {
  #checkov:skip=CKV2_AWS_38:DNSSEC is not currently necessary
  #checkov:skip=CKV2_AWS_39:DNS query logging not necessary
  name = "stage.forms.service.gov.uk."

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_route53_record" "stage" {
  zone_id = aws_route53_zone.stage.id
  name    = "*.stage.forms.service.gov.uk."
  type    = "CNAME"
  ttl     = 60
  records = [local.aws_alb]
}

resource "aws_route53_zone" "staging" {
  #checkov:skip=CKV2_AWS_38:DNSSEC is not currently necessary
  #checkov:skip=CKV2_AWS_39:DNS query logging not necessary
  name = "staging.forms.service.gov.uk."

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_route53_record" "runner" {
  zone_id = aws_route53_zone.staging.id
  name    = "submit.staging.forms.service.gov.uk"
  type    = "CNAME"
  ttl     = 60
  records = [local.paas_runner_cloudfront_distribution]
}

resource "aws_route53_record" "admin" {
  zone_id = aws_route53_zone.staging.id
  name    = "admin.staging.forms.service.gov.uk"
  type    = "CNAME"
  ttl     = 60
  records = [local.paas_admin_cloudfront_distribution]
}

output "stage_zone_name_servers" {
  value = aws_route53_zone.stage.name_servers
}

output "staging_zone_name_servers" {
  value = aws_route53_zone.staging.name_servers
}
