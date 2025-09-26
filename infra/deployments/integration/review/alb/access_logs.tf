data "aws_caller_identity" "current" {}

locals {
  #The AWS managed account for the ALB, see: https://docs.aws.amazon.com/elasticloadbalancing/latest/application/enable-access-logging.html
  aws_lb_account_id = "652711504416"
}

module "access_logs_bucket" {
  source = "../../../../modules/secure-bucket"

  name                   = "govuk-forms-review-alb-access-logs"
  access_logging_enabled = true

  extra_bucket_policies = flatten([
    [data.aws_iam_policy_document.allow_logs.json],
    var.send_logs_to_cyber ? [module.cyber_s3_log_shipping[0].s3_policy] : []
  ])
}

data "aws_iam_policy_document" "allow_logs" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${local.aws_lb_account_id}:root"]
    }
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${module.access_logs_bucket.name}/alb/AWSLogs/*"]
  }
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  count = var.send_logs_to_cyber ? 1 : 0

  bucket = module.access_logs_bucket.name
  queue {
    queue_arn = module.cyber_s3_log_shipping[0].s3_to_splunk_queue_arn
    events    = ["s3:ObjectCreated:*"]
  }
}

module "cyber_s3_log_shipping" {
  count = var.send_logs_to_cyber ? 1 : 0

  source  = "../../../../modules/cyber_s3_log_shipping"
  s3_name = module.access_logs_bucket.name
}

moved {
  from = module.s3_log_shipping[0]
  to   = module.cyber_s3_log_shipping[0].module.s3_log_shipping
}
