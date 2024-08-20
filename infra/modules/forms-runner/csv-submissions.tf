resource "aws_iam_role" "csv-submissions-role" {
  name               = "govuk-forms-csv-submissions-${var.env_name}"
  assume_role_policy = data.aws_iam_policy_document.csv_submission_assume_role_policy.json
}

data "aws_iam_policy_document" "csv_submission_assume_role_policy" {
  source_policy_documents = [
    data.aws_iam_policy_document.allow_ecs_task_role_to_assumerole.json,
    data.aws_iam_policy_document.allow_additional_csv_submission_role_assumers.json
  ]
}

data "aws_iam_policy_document" "allow_ecs_task_role_to_assumerole" {
  statement {
    effect = "Allow"
    principals {
      identifiers = [module.ecs_service.task_role_arn]
      type        = "AWS"
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "allow_additional_csv_submission_role_assumers" {
  statement {
    effect = "Allow"
    principals {
      identifiers = var.additional_csv_submission_role_assumers
      type        = "AWS"
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy" "allow_s3_actions" {
  role = aws_iam_role.csv-submissions-role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AllowAllS3Actions"
        Action   = "s3:*"
        Effect   = "Allow"
        Resource = ["arn:aws:s3:::*"]
      }
    ]
  })
}