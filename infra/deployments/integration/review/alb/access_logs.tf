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
