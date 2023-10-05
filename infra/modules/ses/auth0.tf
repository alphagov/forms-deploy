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

resource "aws_ssm_parameter" "auth0_smtp_username" {
  name  = "/ses/auth0/smtp-username"
  type  = "SecureString"
  value = aws_iam_access_key.auth0.id
}

resource "aws_ssm_parameter" "auth0_smtp_password" {
  name  = "/ses/auth0/smtp-password"
  type  = "SecureString"
  value = aws_iam_access_key.auth0.ses_smtp_password_v4
}
