data "aws_ssm_parameter" "email_zendesk" {
  name = "/alerting/email-zendesk"
}

resource "aws_sns_topic" "cloudwatch_alarms" {
  #checkov:skip=CKV_AWS_26:We don't need this to be encrypted at the moment
  provider = aws.us-east-1
  name     = "cloudwatch-alarms"
}

resource "aws_sns_topic_subscription" "email" {
  provider  = aws.us-east-1
  topic_arn = aws_sns_topic.cloudwatch_alarms.arn
  protocol  = "email"
  endpoint  = data.aws_ssm_parameter.email_zendesk.value
}