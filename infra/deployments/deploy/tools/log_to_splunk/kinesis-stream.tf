resource "aws_kinesis_stream" "log_stream" {
  name             = "cribl-cloudwatch-kinesis-stream"
  shard_count      = var.shard_count
  retention_period = 24
  encryption_type  = "KMS"
  kms_key_id       = "alias/aws/kinesis"

  tags = {
    Name = "CloudWatchToKinesis"
  }
}

resource "aws_cloudwatch_log_destination" "kinesis_log_destination" {
  depends_on = [aws_kinesis_stream.log_stream, aws_iam_role.logs_kinesis_role, aws_iam_policy.logs_kinesis_policy]
  name       = module.cribl_well_known.kinesis_destination_names["eu-west-2"]
  role_arn   = aws_iam_role.logs_kinesis_role.arn
  target_arn = aws_kinesis_stream.log_stream.arn
}

resource "aws_cloudwatch_log_destination" "kinesis_log_destination_us_east_1" {
  provider = aws.us-east-1

  depends_on = [aws_kinesis_stream.log_stream, aws_iam_role.logs_kinesis_role, aws_iam_policy.logs_kinesis_policy]
  name       = module.cribl_well_known.kinesis_destination_names["us-east-1"]
  role_arn   = aws_iam_role.logs_kinesis_role.arn
  target_arn = aws_kinesis_stream.log_stream.arn
}

resource "aws_cloudwatch_log_destination_policy" "kinesis_log_destination_policy" {
  destination_name = aws_cloudwatch_log_destination.kinesis_log_destination.name
  access_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : var.aws_account_sources
        },
        "Action" : "logs:PutSubscriptionFilter",
        "Resource" : aws_cloudwatch_log_destination.kinesis_log_destination.arn
      }
    ]
  })
}

resource "aws_cloudwatch_log_destination_policy" "kinesis_log_destination_policy_us_east_1" {
  destination_name = aws_cloudwatch_log_destination.kinesis_log_destination_us_east_1.name
  access_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : var.aws_account_sources
        },
        "Action" : "logs:PutSubscriptionFilter",
        "Resource" : aws_cloudwatch_log_destination.kinesis_log_destination_us_east_1.arn
      }
    ]
  })
  region = "us-east-1"
}

resource "aws_iam_role" "logs_kinesis_role" {
  name = "kinesis-cloudwatch-logs-producer-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "logs.amazonaws.com"
        },
        "Action" : "sts:AssumeRole",
        "Condition" : {
          "StringLike" : {
            "aws:SourceArn" : var.account_access_arns
          }
        }
      }
    ]
  })
}


resource "aws_iam_policy" "logs_kinesis_policy" {
  name        = "kinesis-cloudwatch-logs-producer-policy"
  path        = "/"
  description = "IAM policy for CloudWatch Logs to put records to Kinesis on another account."
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "kinesis:PutRecord",
          "kinesis:PutRecords"
        ],
        "Resource" : aws_kinesis_stream.log_stream.arn
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "kinesis_role_policy_attachment" {
  role       = aws_iam_role.logs_kinesis_role.name
  policy_arn = aws_iam_policy.logs_kinesis_policy.arn
}
