resource "aws_iam_role" "csv-submissions-role" {
  name = "govuk-forms-csv-submissions-${var.env_name}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = [module.ecs_service.task_role_arn]
        }
      }
    ]
  })
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