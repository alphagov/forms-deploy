module "csv_submissions_bucket" {
  source = "../../../modules/secure-bucket"

  name = "govuk-forms-csv-form-submissions-dummy"
  extra_bucket_policies = [
    data.aws_iam_policy_document.allow_writes_from_other_accounts.json
  ]
}

data "aws_iam_policy_document" "allow_writes_from_other_accounts" {
  dynamic "statement" {
    for_each = [for _, id in local.other_accounts : id]

    content {
      sid    = "AllowAcct${statement.value}"
      effect = "Allow"
      actions = [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:ListBucket",
        "s3:PutObject"
      ]

      principals {
        identifiers = ["arn:aws:iam::${statement.value}:root"]
        type        = "AWS"
      }

      condition {
        test     = "ArnLike"
        values   = ["arn:aws:iam::${statement.value}:role/govuk-forms-csv-submissions-*"]
        variable = "aws:PrincipalArn"
      }

      resources = [
        "arn:aws:s3:::govuk-forms-csv-form-submissions-dummy",
        "arn:aws:s3:::govuk-forms-csv-form-submissions-dummy/*"
      ]
    }
  }
}