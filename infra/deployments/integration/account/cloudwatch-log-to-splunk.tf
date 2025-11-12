resource "aws_iam_role" "kinesis_subscription_role" {
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
moved {
  from = aws_iam_role.kinesis_subscription_role[0]
  to   = aws_iam_role.kinesis_subscription_role
}

module "cribl_well_known" {
  source = "../../../modules/well-known/cribl"
}

resource "aws_iam_policy" "kinesis_subscription_policy" {
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
        "Resource" : module.cribl_well_known.kinesis_destination_arns["eu-west-2"]
      }
    ]
  })
}
moved {
  from = aws_iam_policy.kinesis_subscription_policy[0]
  to   = aws_iam_policy.kinesis_subscription_policy
}

resource "aws_iam_role_policy_attachment" "kinesis_subscription_role_policy_attachment" {
  role       = aws_iam_role.kinesis_subscription_role.name
  policy_arn = aws_iam_policy.kinesis_subscription_policy.arn
}
moved {
  from = aws_iam_role_policy_attachment.kinesis_subscription_role_policy_attachment[0]
  to   = aws_iam_role_policy_attachment.kinesis_subscription_role_policy_attachment
}
