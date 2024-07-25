data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

resource "aws_sns_topic" "topic" {
  name              = var.topic_name
  kms_master_key_id = var.kms_key_arn
}

resource "aws_sns_topic_policy" "topic_policy" {
  arn = aws_sns_topic.topic.arn
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AllowPublishFromServices",
        Action   = "sns:Publish"
        Effect   = "Allow"
        Resource = aws_sns_topic.topic.arn
        Principal = {
          Service = [
            "cloudwatch.amazonaws.com",
            "events.amazonaws.com",
          ]
        }
      }
    ]
  })
}
