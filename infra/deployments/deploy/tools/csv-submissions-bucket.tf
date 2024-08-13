module "csv_submissions_bucket" {
  source = "../../../modules/secure-bucket"

  name = "govuk-forms-csv-form-submissions-dummy"
  extra_bucket_policies = [
    data.aws_iam_policy_document.allow_writes_from_other_accounts.json
  ]
}

data "aws_iam_policy_document" "allow_writes_from_other_accounts" {
  statement {
    sid    = "AllowOtherAccountsToUseBucket"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:PutObject",
      "s3:PutObjectVersion",
    ]
    principals {
      type        = "AWS"
      identifiers = [for acct, id in local.other_accounts : "arn:aws:s3::${id}:role/govuk-forms-csv-submissions-*"]
    }

  }
}