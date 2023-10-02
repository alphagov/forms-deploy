data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

resource "aws_ses_email_identity" "verified_email_addresses" {
  for_each = var.verified_email_addresses
  email    = each.value
}

resource "aws_iam_user" "this" {
  #checkov:skip=CKV_AWS_273:ignoring while spiking
  name = var.smtp_user
}

resource "aws_iam_access_key" "this" {
  user = aws_iam_user.this.name
}

data "aws_iam_policy_document" "ses_sender" {
  statement {
    actions = [
      "ses:SendRawEmail",
      "ses:SendEmail"
    ]
    resources = ["arn:aws:ses:eu-west-2:${local.account_id}:identity/*"]
    condition {
      test     = "ForAnyValue:StringEquals"
      variable = "ses:FromAddress"
      values   = ["${var.from_address}"]
    }
  }
}

resource "aws_iam_policy" "ses_sender" {
  name        = "ses_sender"
  description = "Allows sending of emails via Simple Email Service"
  policy      = data.aws_iam_policy_document.ses_sender.json
}

resource "aws_iam_user_policy_attachment" "attach" {
  #checkov:skip=CKV_AWS_40: ignoring while spiking
  user       = aws_iam_user.this.name
  policy_arn = aws_iam_policy.ses_sender.arn
}

resource "aws_ssm_parameter" "smtp_username" {
  name  = "/ses/${var.smtp_user}/smtp-username"
  type  = "SecureString"
  value = aws_iam_access_key.this.id
}

resource "aws_ssm_parameter" "smtp_password" {
  name  = "/ses/${var.smtp_user}/smtp-password"
  type  = "SecureString"
  value = aws_iam_access_key.this.ses_smtp_password_v4
}
