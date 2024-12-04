module "file_upload_bucket" {
  source = "../../../modules/secure-bucket"
  name   = "govuk-forms-file-upload"

  extra_bucket_policies = [data.aws_iam_policy_document.forms_runner_access.json]
}

data "aws_iam_policy_document" "forms_runner_access" {
  statement {
    sid = "Allow runner to manage objects"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.environment_name}-forms-runner-ecs-task"]
    }
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:ListBucket",
      "s3:PutObject"
    ]
    resources = [
      "arn:aws:s3:::govuk-forms-file-upload",
      "arn:aws:s3:::govuk-forms-file-upload/*"
    ]
  }
}


# This configuration overrides the one in the secure-bucket module
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = module.file_upload_bucket.name

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.this.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_kms_key" "this" {
  description             = "This key is used to encrypt/decrypt bucket objects"
  enable_key_rotation     = true
  deletion_window_in_days = 10

  policy = data.aws_iam_policy_document.key_policy.json
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "key_policy" {
  statement {
    sid    = "Enable Iam Access"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid    = "Allow use of the key"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.environment_name}-forms-runner-ecs-task"]
    }
    actions = [
      "kms:DescribeKey",
      "kms:Decrypt",
      "kms:Encrypt"
    ]
    resources = ["*"]
  }
}
