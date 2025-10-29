data "aws_caller_identity" "current" {}

locals {
  #The AWS managed account for the ALB, see: https://docs.aws.amazon.com/elasticloadbalancing/latest/application/enable-access-logging.html
  aws_lb_account_id = "652711504416"
}

module "access_logs_bucket" {
  source = "../../../../modules/access-logs-bucket"

  bucket_name               = "govuk-forms-review-alb-access-logs"
  send_access_logs_to_cyber = var.send_logs_to_cyber
  extra_bucket_policies     = [data.aws_iam_policy_document.allow_logs.json]
}

data "aws_iam_policy_document" "allow_logs" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${local.aws_lb_account_id}:root"]
    }
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${module.access_logs_bucket.bucket_name}/alb/AWSLogs/*"]
  }
}

# Move resources from old secure-bucket structure to new access-logs-bucket structure
moved {
  from = module.access_logs_bucket.aws_s3_bucket.this
  to   = module.access_logs_bucket.aws_s3_bucket.access_logs
}

moved {
  from = module.access_logs_bucket.aws_s3_bucket_public_access_block.this
  to   = module.access_logs_bucket.aws_s3_bucket_public_access_block.access_logs
}

moved {
  from = module.access_logs_bucket.aws_s3_bucket_versioning.this
  to   = module.access_logs_bucket.aws_s3_bucket_versioning.access_logs
}

moved {
  from = module.access_logs_bucket.aws_s3_bucket_server_side_encryption_configuration.this[0]
  to   = module.access_logs_bucket.aws_s3_bucket_server_side_encryption_configuration.access_logs
}

moved {
  from = module.access_logs_bucket.aws_s3_bucket_ownership_controls.owner[0]
  to   = module.access_logs_bucket.aws_s3_bucket_ownership_controls.access_logs_owner[0]
}

moved {
  from = module.access_logs_bucket.aws_s3_bucket_policy.bucket_policy
  to   = module.access_logs_bucket.aws_s3_bucket_policy.access_logs_bucket_policy
}

moved {
  from = module.access_logs_bucket.aws_s3_bucket_lifecycle_configuration.access_logs[0]
  to   = module.access_logs_bucket.aws_s3_bucket_lifecycle_configuration.access_logs
}

moved {
  from = module.cyber_s3_log_shipping[0]
  to   = module.access_logs_bucket.module.cyber_s3_log_shipping[0]
}

moved {
  from = aws_s3_bucket_notification.bucket_notification[0]
  to   = module.access_logs_bucket.module.cyber_s3_log_shipping[0].aws_s3_bucket_notification.s3_bucket_notification
}
