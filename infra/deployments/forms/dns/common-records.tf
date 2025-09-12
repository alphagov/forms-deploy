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

resource "aws_route53_record" "product_page" {
  zone_id = data.terraform_remote_state.account.outputs.route53_hosted_zone_id
  name    = "www.${var.root_domain}"
  type    = "CNAME"
  ttl     = 300
  records = [data.terraform_remote_state.forms_environment.outputs.cloudfront_distribution_domain_name]
}

resource "aws_route53_record" "apex_domain" {
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

resource "aws_route53_record" "root_spf" {
  zone_id = data.terraform_remote_state.account.outputs.route53_hosted_zone_id
  name    = var.root_domain
  type    = "TXT"
  ttl     = 86400

  records = ["v=spf1 include:amazonses.com ~all"]
}

resource "aws_route53_record" "mail_spf" {
  zone_id = data.terraform_remote_state.account.outputs.route53_hosted_zone_id
  name    = "mail.${var.root_domain}"
  type    = "TXT"
  ttl     = 86400

  records = ["v=spf1 include:amazonses.com ~all"]
}

# Private zone record for internal admin
resource "aws_route53_record" "private_internal_admin" {
  #checkov:skip=CKV2_AWS_23:Not applicable to alias records
  zone_id = data.terraform_remote_state.forms_environment.outputs.private_internal_zone_id
  name    = "admin.internal.${var.root_domain}"
  type    = "A"

  alias {
    name                   = data.terraform_remote_state.forms_environment.outputs.internal_alb_dns_name
    zone_id                = data.terraform_remote_state.forms_environment.outputs.internal_alb_zone_id
    evaluate_target_health = true
  }
}

# Private zone record for internal forms-runner
resource "aws_route53_record" "private_internal_runner" {
  #checkov:skip=CKV2_AWS_23:Not applicable to alias records
  zone_id = data.terraform_remote_state.forms_environment.outputs.private_internal_zone_id
  name    = "submit.internal.${var.root_domain}"
  type    = "A"

  alias {
    name                   = data.terraform_remote_state.forms_environment.outputs.internal_alb_dns_name
    zone_id                = data.terraform_remote_state.forms_environment.outputs.internal_alb_zone_id
    evaluate_target_health = true
  }
}