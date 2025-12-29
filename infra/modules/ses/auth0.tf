locals {
  account_id = data.aws_caller_identity.current.account_id
}

resource "aws_iam_user" "auth0" {
  #checkov:skip=CKV_AWS_273: SES SMTP interface requires long-term IAM credentials
  name = "auth0"
}

resource "aws_iam_access_key" "auth0" {
  user = aws_iam_user.auth0.name
}

resource "aws_iam_user_policy_attachment" "attach" {
  #checkov:skip=CKV_AWS_40: SES SMTP interface requires long-term IAM credentials
  user       = aws_iam_user.auth0.name
  policy_arn = aws_iam_policy.ses_sender.arn
}

resource "aws_iam_policy" "ses_sender" {
  name        = "ses_sender"
  description = "Allows sending of emails via Simple Email Service"
  policy      = data.aws_iam_policy_document.ses_sender.json
}

data "aws_iam_policy_document" "ses_sender" {
  statement {
    actions = [
      "ses:SendRawEmail",
      "ses:SendEmail"
    ]
    resources = [
      "arn:aws:ses:eu-west-2:${local.account_id}:identity/*",
      "arn:aws:ses:eu-west-2:${local.account_id}:configuration-set/bounces_and_complaints_handling_rule"
    ]
    condition {
      test     = "ForAnyValue:StringEquals"
      variable = "ses:FromAddress"
      values   = [var.from_address]
    }
  }
}

resource "aws_ssm_parameter" "auth0_smtp_username" {
  #checkov:skip=CKV_AWS_337:The parameter is already using the default key
  #checkov:skip=CKV2_FORMS_AWS_7:We know the correct value at runtime and should not ignore changes to it

  name  = "/ses/auth0/smtp-username"
  type  = "SecureString"
  value = aws_iam_access_key.auth0.id
}

resource "aws_ssm_parameter" "auth0_smtp_password" {
  #checkov:skip=CKV_AWS_337:The parameter is already using the default key
  #checkov:skip=CKV2_FORMS_AWS_7:We know the correct value at runtime and should not ignore changes to it

  name  = "/ses/auth0/smtp-password"
  type  = "SecureString"
  value = aws_iam_access_key.auth0.ses_smtp_password_v4
}
