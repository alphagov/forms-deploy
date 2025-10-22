resource "aws_iam_role" "kinesis_subscription_role" {
  count = var.kinesis_destination_arn != "" ? 1 : 0

  name = "cloudwatch-kinesis-subscription-role"
  assume_role_policy = jsonencode({
    "Version" : "2008-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "logs.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "kinesis_subscription_policy" {
  count = var.kinesis_destination_arn != "" ? 1 : 0

  name        = "cloudwatch-kinesis-subscription-policy"
  path        = "/"
  description = "IAM policy for CloudWatch Logs to put records to Kinesis on another account."


  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:PutLogEvents",
          "logs:PutSubscriptionFilter"
        ],
        "Resource" : var.kinesis_destination_arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "kinesis_subscription_role_policy_attachment" {
  count = var.kinesis_destination_arn != "" ? 1 : 0

  role       = aws_iam_role.kinesis_subscription_role[count.index].name
  policy_arn = aws_iam_policy.kinesis_subscription_policy[count.index].arn
}
