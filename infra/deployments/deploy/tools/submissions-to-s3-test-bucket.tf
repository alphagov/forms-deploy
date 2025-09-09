module "submissions_to_s3_test_bucket" {
  source = "../../../modules/secure-bucket"

  name                   = "govuk-forms-submissions-to-s3-test"
  access_logging_enabled = true
  extra_bucket_policies = [
    data.aws_iam_policy_document.allow_writes_from_other_accounts.json
  ]
}

data "aws_iam_policy_document" "allow_writes_from_other_accounts" {
  dynamic "statement" {
    for_each = [for _, id in module.other_accounts.environment_accounts_id : id]

    content {
      sid    = "AllowAcct${statement.value}"
      effect = "Allow"
      actions = [
        "s3:PutObject"
      ]

      principals {
        identifiers = ["arn:aws:iam::${statement.value}:root"]
        type        = "AWS"
      }

      condition {
        test     = "ArnLike"
        values   = ["arn:aws:iam::${statement.value}:role/govuk-forms-submissions-to-s3-*"]
        variable = "aws:PrincipalArn"
      }

      resources = [
        "arn:aws:s3:::govuk-forms-submissions-to-s3-test",
        "arn:aws:s3:::govuk-forms-submissions-to-s3-test/*"
      ]
    }
  }

  dynamic "statement" {
    # This role is separate because it is used for end to end testing and needs s3:DeleteObject, which the govuk-forms-submissions-to-s3-* does not.
    for_each = [for _, id in module.other_accounts.environment_accounts_id : id]
    content {
      sid    = "AllowAcct${statement.value}EndToEndRole"
      effect = "Allow"
      actions = [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:ListBucket",
        "s3:PutObject",
        "s3:DeleteObject"
      ]

      principals {
        identifiers = ["arn:aws:iam::${statement.value}:root"]
        type        = "AWS"
      }

      condition {
        test     = "ArnLike"
        values   = ["arn:aws:iam::${statement.value}:role/govuk-s3-end-to-end-test-*"]
        variable = "aws:PrincipalArn"
      }

      resources = [
        "arn:aws:s3:::govuk-forms-submissions-to-s3-test",
        "arn:aws:s3:::govuk-forms-submissions-to-s3-test/*"
      ]
    }
  }
}