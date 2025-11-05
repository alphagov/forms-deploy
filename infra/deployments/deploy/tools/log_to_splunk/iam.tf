resource "random_uuid" "external_id" {
}

data "aws_caller_identity" "current" {}

resource "aws_iam_role" "cribl_ingest" {
  name = module.cribl_well_known.cribl_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect : "Allow",
        Principal : {
          AWS : var.cribl_worker_arn
        },
        Action : "sts:AssumeRole",
        Condition : {
          StringEquals : {
            "sts:ExternalId" : random_uuid.external_id.result
          }
        }
      }
    ]
  })

  tags = {
    Name = module.cribl_well_known.cribl_role_name
  }
}

resource "aws_iam_policy" "cribl_kinesis" {
  name        = "cribl-kinesis-policy"
  description = "Allows necessary access to Kinesis."
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "kinesis:GetRecords",
        "kinesis:GetShardIterator",
        "kinesis:ListShards"
      ]
      Resource = "arn:aws:kinesis:eu-west-2:${data.aws_caller_identity.current.account_id}:stream/${aws_kinesis_stream.log_stream.name}"
    }]
  })
}


resource "aws_iam_role_policy_attachment" "attach_kinesis" {
  policy_arn = aws_iam_policy.cribl_kinesis.arn
  role       = aws_iam_role.cribl_ingest.name
}

resource "aws_iam_policy" "cribl_sqs" {
  name        = "cribl-sqs-policy"
  description = "Allows necessary access to SQS for Cribl S3 source."
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage",
        "sqs:ChangeMessageVisibility",
        "sqs:GetQueueAttributes",
        "sqs:GetQueueUrl"
      ]
      Resource = aws_sqs_queue.cribl_s3_events.arn
    }]
  })
}

resource "aws_iam_role_policy_attachment" "attach_sqs" {
  policy_arn = aws_iam_policy.cribl_sqs.arn
  role       = aws_iam_role.cribl_ingest.name
}
