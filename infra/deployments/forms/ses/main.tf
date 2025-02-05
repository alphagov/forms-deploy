module "ses" {
  source = "../../../modules/ses"

  environment_type = var.environment_type

  hosted_zone_id = data.terraform_remote_state.account.outputs.route53_hosted_zone_id
  email_domain   = var.root_domain
  from_address   = "no-reply@${var.root_domain}"
}
