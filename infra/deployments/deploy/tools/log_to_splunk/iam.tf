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

resource "aws_iam_policy" "cribl_kms" {
  name        = "cribl-kms-policy"
  description = "Allows Cribl to decrypt SQS messages encrypted with KMS."
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "kms:Decrypt",
        "kms:DescribeKey"
      ]
      Resource = aws_kms_key.cribl_sqs.arn
    }]
  })
}

resource "aws_iam_role_policy_attachment" "attach_kms" {
  policy_arn = aws_iam_policy.cribl_kms.arn
  role       = aws_iam_role.cribl_ingest.name
}

resource "aws_iam_policy" "cribl_s3" {
  #checkov:skip=CKV_AWS_288:Cross-account S3 access requires broad identity policy. Actual access controlled by bucket policies in remote accounts.
  #checkov:skip=CKV_AWS_355:Resource wildcard required for cross-account access pattern. Access controlled by bucket policies in each environment.

  name        = "cribl-s3-policy"
  description = "Allows Cribl to read S3 objects. Actual access is controlled by bucket policies in remote accounts."
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "s3:GetObject",
        "s3:ListBucket",
        "s3:GetObjectTagging",
        "s3:PutObjectTagging"
      ]
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "attach_s3" {
  policy_arn = aws_iam_policy.cribl_s3.arn
  role       = aws_iam_role.cribl_ingest.name
}
