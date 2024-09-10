resource "aws_route53_record" "runner" {
  zone_id = data.terraform_remote_state.account.outputs.route53_hosted_zone_id
  name    = "submit.${var.root_domain}"
  type    = "CNAME"
  ttl     = 300
  records = [data.terraform_remote_state.forms_environment.outputs.cloudfront_distribution_domain_name]
}

resource "aws_route53_record" "admin" {
  zone_id = data.terraform_remote_state.account.outputs.route53_hosted_zone_id
  name    = "admin.${var.root_domain}"
  type    = "CNAME"
  ttl     = 300
  records = [data.terraform_remote_state.forms_environment.outputs.cloudfront_distribution_domain_name]
}

resource "aws_route53_record" "api" {
  zone_id = data.terraform_remote_state.account.outputs.route53_hosted_zone_id
  name    = "api.${var.root_domain}"
  type    = "CNAME"
  ttl     = 60
  records = [data.terraform_remote_state.forms_environment.outputs.cloudfront_distribution_domain_name]
}

resource "aws_route53_record" "product-page" {
  zone_id = data.terraform_remote_state.account.outputs.route53_hosted_zone_id
  name    = "www.${var.root_domain}"
  type    = "CNAME"
  ttl     = 300
  records = [data.terraform_remote_state.forms_environment.outputs.cloudfront_distribution_domain_name]
}

resource "aws_route53_record" "apex-domain" {
  #checkov:skip=CKV2_AWS_23:Not applicable to alias records
  zone_id = data.terraform_remote_state.account.outputs.route53_hosted_zone_id
  name    = var.root_domain
  type    = "A"

  alias {
    name                   = data.terraform_remote_state.forms_environment.outputs.cloudfront_distribution_domain_name
    zone_id                = data.terraform_remote_state.forms_environment.outputs.cloudfront_hosted_zone_id
    evaluate_target_health = true
  }
}