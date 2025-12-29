data "aws_caller_identity" "current" {}

locals {
  aws_account_id = data.aws_caller_identity.current.account_id
}

import {
  to = module.ses.aws_sesv2_account_suppression_attributes.account_suppression_list
  id = local.aws_account_id
}

module "ses" {
  source = "../../../modules/ses"

  environment_name = var.environment_name
  environment_type = var.environment_type

  hosted_zone_id = data.terraform_remote_state.account.outputs.route53_hosted_zone_id
  email_domain   = var.root_domain
  from_address   = "no-reply@${var.root_domain}"
}
