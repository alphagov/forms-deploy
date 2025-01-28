locals {
  file_upload_bucket_name = "govuk-forms-${var.env_name}-file-upload"
}

module "file_upload_bucket" {
  source = "../secure-bucket"
  name   = local.file_upload_bucket_name

  extra_bucket_policies = [data.aws_iam_policy_document.forms_runner_file_upload.json]
  # In order to use KMS for server side encryption we need to disable the defaul AES256 encyrption in the module
  AES256_encryption_configuration = false
}

module "users" {
  source = "../users"
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
    sid    = "Deny decryption for support and admin users"
    effect = "Deny"

    principals {
      type = "AWS"
      identifiers = toset(concat(
        [for admin in module.users.with_role["${var.environment_type}_admin"] : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${admin}-admin"],
        [for admin in module.users.with_role["${var.environment_type}_support"] : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${admin}-support"]
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

# Configure logging
# We are not using CloudTrail because we cannot edit the existing trail
# New trails are pricey
module "file_upload_bucket_logs" {
  source = "../secure-bucket"
  name   = "${local.file_upload_bucket_name}-logs"

  extra_bucket_policies = flatten([
    [data.aws_iam_policy_document.file_upload_bucket_logs.json],
    var.send_logs_to_cyber ? [module.s3_log_shipping[0].s3_policy] : []
  ])
}

resource "aws_s3_bucket_logging" "file_upload" {
  bucket = module.file_upload_bucket.name

  target_bucket = module.file_upload_bucket_logs.name
  target_prefix = "s3-access-logs"

  target_object_key_format {
    partitioned_prefix {
      partition_date_source = "DeliveryTime"
    }
  }
}

data "aws_iam_policy_document" "file_upload_bucket_logs" {
  statement {
    sid    = "S3ServerAccessLogsPolicy"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["logging.s3.amazonaws.com"]
    }
    actions = [
      "s3:PutObject",
    ]
    resources = ["arn:aws:s3:::${module.file_upload_bucket_logs.name}/*"]
  }
}

# this is for csls log shipping
module "s3_log_shipping" {
  count = var.send_logs_to_cyber ? 1 : 0

  # Double slash after .git in the module source below is required
  # https://developer.hashicorp.com/terraform/language/modules/sources#modules-in-package-sub-directories
  source                   = "git::https://github.com/alphagov/cyber-security-shared-terraform-modules.git//s3/s3_log_shipping?ref=6fecf620f987ba6456ea6d7307aed7d83f077c32"
  s3_processor_lambda_role = "arn:aws:iam::885513274347:role/csls_prodpython/csls_process_s3_logs_lambda_prodpython"
  s3_name                  = module.file_upload_bucket_logs.name
}

moved {
  from = module.s3_log_shipping
  to   = module.s3_log_shipping[0]
}

