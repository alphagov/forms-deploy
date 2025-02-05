resource "aws_ses_event_destination" "failed_email_notification" {
  name                   = "failed_email_notification"
  configuration_set_name = aws_ses_configuration_set.bounces_and_complaints_handling_rule.name
  enabled                = true
  matching_types         = ["bounce", "complaint", "reject"]

  sns_destination {
    topic_arn = aws_sns_topic.ses_bounces_and_complaints.arn
  }
}

resource "aws_ses_configuration_set" "bounces_and_complaints_handling_rule" {
  #checkov:skip=CKV_AWS_365 We'll look at this later
  name = "bounces_and_complaints_handling_rule"

  reputation_metrics_enabled = true
}

resource "aws_ses_domain_identity" "ses" {
  domain = var.email_domain
}

resource "aws_ses_domain_dkim" "ses" {
  domain = aws_ses_domain_identity.ses.domain
}

resource "aws_ses_domain_mail_from" "mail" {
  domain           = aws_ses_domain_identity.ses.domain
  mail_from_domain = "mail.${aws_ses_domain_identity.ses.domain}"
}
