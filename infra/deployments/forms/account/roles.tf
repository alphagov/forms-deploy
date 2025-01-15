resource "aws_iam_role" "codepipeline-readonly" {
  name = "codepipeline-readonly"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.deploy_account_id}:role/deploy-pipeline-visualiser-ecs-task"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codepipeline-readonly-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AWSCodePipeline_ReadOnlyAccess"
  role       = aws_iam_role.codepipeline-readonly.name
}
