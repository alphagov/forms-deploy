module "ses" {
  source = "../../../modules/ses"

  environment_name = var.environment_name
  environment_type = var.environment_type

  hosted_zone_id = data.terraform_remote_state.account.outputs.route53_hosted_zone_id
  email_domain   = var.root_domain
  from_address   = "no-reply@${var.root_domain}"
}

# moved statements, will be deleted once deployed
moved {
  from = module.ses.aws_sns_topic.ses_bounces_and_complaints
  to   = module.ses.module.sqs.aws_sns_topic.ses_bounces_and_complaints
}

moved {
  from = module.ses.aws_sns_topic_subscription.ses_bounces_and_complaints
  to   = module.ses.module.sqs.aws_sns_topic_subscription.ses_bounces_and_complaints
}

moved {
  from = module.ses.aws_sqs_queue.ses_bounces_and_complaints
  to   = module.ses.module.sqs.aws_sqs_queue.ses_bounces_and_complaints
}

moved {
  from = module.ses.aws_sqs_queue.ses_dead_letter
  to   = module.ses.module.sqs.aws_sqs_queue.ses_dead_letter
}

moved {
  from = module.ses.aws_sqs_queue_policy.ses_bounces_and_complaints
  to   = module.ses.module.sqs.aws_sqs_queue_policy.ses_bounces_and_complaints
}

moved {
  from = module.ses.aws_kms_key.this
  to   = module.ses.module.sqs.aws_kms_key.this
}