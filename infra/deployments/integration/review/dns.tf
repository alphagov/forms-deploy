resource "aws_route53_record" "apex_domain" {
  zone_id = data.terraform_remote_state.account.outputs.review_dns_zone_id
  name    = "review.forms.service.gov.uk"

  type    = "CNAME"
  ttl     = "60"
  records = [module.cloudfront.cloudfront_domain_name]
}

resource "aws_route53_record" "wildcard" {
  zone_id = data.terraform_remote_state.account.outputs.review_dns_zone_id
  name    = "*.review.forms.service.gov.uk"

  type    = "CNAME"
  ttl     = "60"
  records = [module.cloudfront.cloudfront_domain_name]
}
