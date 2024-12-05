locals {
  file_upload_bucket_name = "govuk-forms-${var.env_name}-file-upload"
}

module "file_upload_bucket" {
  source = "../secure-bucket"
  name   = local.file_upload_bucket_name

  extra_bucket_policies = [data.aws_iam_policy_document.forms_runner_file_upload.json]
}

data "aws_iam_policy_document" "forms_runner_file_upload" {
  statement {
    sid = "Allow runner to manage s3 objects"
    principals {
      type        = "AWS"
      identifiers = [module.ecs_service.task_role_arn]
    }
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:ListBucket",
      "s3:PutObject",
      "s3:*Tagging"
    ]
    resources = [
      "arn:aws:s3:::${local.file_upload_bucket_name}",
      "arn:aws:s3:::${local.file_upload_bucket_name}/*"
    ]
  }
}


# This configuration overrides the one in the secure-bucket module
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = module.file_upload_bucket.name

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.file_upload.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_kms_key" "file_upload" {
  description             = "This key is used to encrypt/decrypt bucket objects"
  enable_key_rotation     = true
  deletion_window_in_days = 10

  policy = data.aws_iam_policy_document.file_upload.json
}

resource "aws_kms_alias" "file_upload" {
  name          = "alias/file-upload-${var.env_name}"
  target_key_id = aws_kms_key.file_upload.key_id
}

data "aws_iam_policy_document" "file_upload" {
  # See https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-default.html#key-policy-default-allow-root-enable-iam
  #checkov:skip=CKV_AWS_111:AWS suggest the EnableIamAccess statement for key policies.
  #checkov:skip=CKV_AWS_109:AWS suggest the EnableIamAccess statement for key policies.
  #checkov:skip=CKV_AWS_356:Resource "*" is OK here because the only resource it can refer to is the key to which the policy is attached

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
      identifiers = [module.ecs_service.task_role_arn]
    }
    actions = [
      "kms:DescribeKey",
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:GenerateDataKey"
    ]
    resources = ["*"]
  }
}
