data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

removed {
  from = aws_sns_topic.topic

  lifecycle {
    destroy = false
  }
}

removed {
  from = aws_sns_topic_policy.topic_policy

  lifecycle {
    destroy = false
  }
}