resource "aws_ses_email_identity" "verified_email_addresses" {
  for_each = var.verified_email_addresses
  email    = each.value
}

resource "aws_iam_user" "smtp_user" {
  #checkov:skip=CKV_AWS_273:ignoring while spiking
  name = "smtp_user"
}

resource "aws_iam_access_key" "smtp_user" {
  user = aws_iam_user.smtp_user.name
}

data "aws_iam_policy_document" "ses_sender" {
  #checkov:skip=CKV_AWS_111: ignoring while spiking
  statement {
    actions = [
      "ses:SendRawEmail",
      "ses:SendEmail"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "ses_sender" {
  name        = "ses_sender"
  description = "Allows sending of emails via Simple Email Service"
  policy      = data.aws_iam_policy_document.ses_sender.json
}

resource "aws_iam_user_policy_attachment" "attach" {
  #checkov:skip=CKV_AWS_40: ignoring while spiking
  user       = aws_iam_user.smtp_user.name
  policy_arn = aws_iam_policy.ses_sender.arn
}

output "smtp_username" {
  value     = aws_iam_access_key.smtp_user.id
  sensitive = true
}

output "smtp_password" {
  value     = aws_iam_access_key.smtp_user.ses_smtp_password_v4
  sensitive = true
}
