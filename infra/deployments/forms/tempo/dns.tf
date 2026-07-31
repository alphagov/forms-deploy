# These records live here rather than in the shared forms/dns root so that
# staging/production (which share that root's code) are never touched by
# this dev-only POC.

resource "aws_route53_record" "tempo_public" {
  count   = var.tempo_settings.enabled ? 1 : 0
  zone_id = data.terraform_remote_state.account.outputs.route53_hosted_zone_id
  name    = "tempo.${var.root_domain}"
  type    = "CNAME"
  ttl     = 300
  records = [data.terraform_remote_state.forms_environment.outputs.cloudfront_distribution_domain_name]
}

resource "aws_route53_record" "tempo_otlp_internal" {
  #checkov:skip=CKV2_AWS_23:Not applicable to alias records
  count   = var.tempo_settings.enabled ? 1 : 0
  zone_id = data.terraform_remote_state.forms_environment.outputs.private_internal_zone_id
  name    = "tempo-otlp.internal.${var.root_domain}"
  type    = "A"

  alias {
    name                   = data.terraform_remote_state.forms_environment.outputs.internal_alb_dns_name
    zone_id                = data.terraform_remote_state.forms_environment.outputs.internal_alb_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "tempo_mimir_internal" {
  #checkov:skip=CKV2_AWS_23:Not applicable to alias records
  count   = var.tempo_settings.enabled ? 1 : 0
  zone_id = data.terraform_remote_state.forms_environment.outputs.private_internal_zone_id
  name    = "mimir.internal.${var.root_domain}"
  type    = "A"

  alias {
    name                   = data.terraform_remote_state.forms_environment.outputs.internal_alb_dns_name
    zone_id                = data.terraform_remote_state.forms_environment.outputs.internal_alb_zone_id
    evaluate_target_health = true
  }
}
