locals {
  file_upload_bucket_name = "govuk-forms-${var.env_name}-file-upload"
}

module "file_upload_bucket" {
  source             = "../secure-bucket"
  name               = local.file_upload_bucket_name
  versioning_enabled = false

  extra_bucket_policies = [data.aws_iam_policy_document.forms_runner_file_upload.json]

  # In order to use KMS for server side encryption we need to disable the defaul AES256 encyrption in the module
  AES256_encryption_configuration = false
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  bucket = module.file_upload_bucket.name

  rule {
    id     = "expire_all_files"
    status = "Enabled"
    expiration {
      days = 30
    }
    abort_incomplete_multipart_upload {
      days_after_initiation = 30
    }

    filter {}
  }
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
      "s3:DeleteObject",
      "s3:GetObjectTagging",
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

  statement {
    sid    = "Allow the role assumed for sending submissions to an S3 bucket to decrypt files"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.submissions_to_s3_role.arn]
    }
    actions = [
      "kms:DescribeKey",
      "kms:Decrypt"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "Deny decryption for support and admin users"
    effect = "Deny"

    principals {
      type = "AWS"
      identifiers = toset(concat(
        [
          for admin in module.users.with_role["${var.environment_type}_admin"] :
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${admin}-admin"
        ],
        [
          for admin in module.users.with_role["${var.environment_type}_support"] :
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${admin}-support"
        ]
      ))
    }

    actions = [
      "kms:Decrypt"
    ]

    # We are only attaching this policy to the relevant key. We cannot specify the key here because we do not know the arn until the key is created, and the key needs this policy to be created
    # We also cannot specify an alias because aliases cannot be used within policies, "mapping of aliases to keys can be manipulated outside the policy, which would allow for an escalation of privilege" https://d1.awsstatic.com/whitepapers/aws-kms-best-practices.pdf
    resources = ["arn:aws:kms:eu-west-2:${data.aws_caller_identity.current.account_id}:key/*"]
  }
}

// We need to remove the duplicate bucket resources created by the old secure-bucket module
// As we are migrating to send logs through Cribl. Terraform won't be able to delete the buckets
// as they have objects in them. These `removed` blocks tell Terraform to ignore these resources
// when deleting.
removed {
  from = module.file_upload_bucket_logs.aws_s3_bucket.this

  lifecycle {
    destroy = false
  }
}
removed {
  from = module.file_upload_bucket_logs.module.access_logs_bucket.aws_s3_bucket.access_logs

  lifecycle {
    destroy = false
  }
}
