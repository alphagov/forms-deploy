# Cribl configuration

module "cribl_well_known" {
  count  = var.enable_cribl ? 1 : 0
  source = "../well-known/cribl"
}

# IAM policy for Cribl role to access S3 bucket
data "aws_iam_policy_document" "cribl_s3_access" {
  count = var.enable_cribl ? 1 : 0

  statement {
    sid = "CriblS3Access"

    principals {
      type        = "AWS"
      identifiers = [module.cribl_well_known[count.index].cribl_role_arn]
    }

    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]

    resources = [
      "arn:aws:s3:::${var.s3_name}",
      "arn:aws:s3:::${var.s3_name}/*",
    ]
  }
}
