# CSLS (Cyber Security Logging Service) configuration

module "csls_well_known" {
  source = "../well-known/csls"
}

data "aws_iam_policy_document" "csls_s3_access" {
  count = local.enable_csls ? 1 : 0
  statement {
    sid = "S3LogShipping"

    principals {
      type        = "AWS"
      identifiers = [module.csls_well_known.s3_logs_processor_role_arn]
    }

    effect = "Allow"

    actions = [
      "s3:List*",
      "s3:Get*",
    ]

    resources = [
      "arn:aws:s3:::${var.s3_name}",
      "arn:aws:s3:::${var.s3_name}/*",
    ]
  }
}
moved {
  from = module.s3_log_shipping.data.aws_iam_policy_document.s3
  to   = data.aws_iam_policy_document.csls_s3_access[0]
}
