# Configure notifications for SES
resource "aws_sns_topic" "ses_notifications" {
  name = "ses-notifications-${var.environment}"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.ses_notifications.arn
  protocol  = "email"
  endpoint  = "catalina.garcia@digital.cabinet-office.gov.uk"
}
