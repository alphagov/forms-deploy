data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

resource "aws_ses_email_identity" "verified_email_addresses" {
  for_each = var.verified_email_addresses
  email    = each.value
}

data "aws_iam_policy_document" "ses_sender" {
  statement {
    actions = [
      "ses:SendRawEmail",
      "ses:SendEmail"
    ]
    resources = [
      "arn:aws:ses:eu-west-2:${local.account_id}:identity/*",
      "arn:aws:ses:eu-west-2:${local.account_id}:configuration-set/ses_bounces_and_complaints_topic"
    ]
    condition {
      test     = "ForAnyValue:StringEquals"
      variable = "ses:FromAddress"
      values   = [var.from_address]
    }
  }
}

resource "aws_iam_policy" "ses_sender" {
  name        = "ses_sender"
  description = "Allows sending of emails via Simple Email Service"
  policy      = data.aws_iam_policy_document.ses_sender.json
}

resource "aws_ses_event_destination" "sns" {
  name                   = "ses-sns"
  configuration_set_name = aws_ses_configuration_set.ses_bounces_and_complaints_topic.name
  enabled                = true
  matching_types         = ["bounce", "complaint", "reject"]

  sns_destination {
    topic_arn = aws_sns_topic.ses_bounces_and_complaints_topic.arn
  }
}

resource "aws_ses_configuration_set" "ses_bounces_and_complaints_topic" {
  #checkov:skip=CKV_AWS_365 We'll look at this later
  name = "ses_bounces_and_complaints_topic"

  reputation_metrics_enabled = true
}

resource "aws_ses_domain_identity" "ses" {
  domain = var.email_domain
}

resource "aws_ses_domain_dkim" "ses" {
  domain = aws_ses_domain_identity.ses.domain
}

resource "aws_route53_record" "ses" {
  count   = 3
  zone_id = var.hosted_zone_id
  name    = "${aws_ses_domain_dkim.ses.dkim_tokens[count.index]}._domainkey"
  type    = "CNAME"
  ttl     = 600
  records = ["${aws_ses_domain_dkim.ses.dkim_tokens[count.index]}.dkim.amazonses.com"]
}

resource "aws_route53_record" "ses_email_receiving" {
  zone_id = var.hosted_zone_id
  name    = aws_ses_domain_identity.ses.domain
  type    = "MX"
  records = ["10 inbound-smtp.eu-west-2.amazonaws.com"]
  ttl     = 3600
}
