resource "aws_ecr_repository" "forms_api" {
  name                 = "forms-api-deploy"
  image_tag_mutability = "IMMUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "forms_runner" {
  name                 = "forms-runner-deploy"
  image_tag_mutability = "IMMUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "forms_admin" {
  name                 = "forms-admin-deploy"
  image_tag_mutability = "IMMUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository_policy" "aws_ecr_repository_policy_api" {
  repository = aws_ecr_repository.forms_api.name

  policy = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "AllowPull",
            "Effect": "Allow",
            "Principal": {
              "AWS": "arn:aws:iam::498160065950:role/dev-forms-api-ecs-task-execution"
              },
            "Action": [
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "ecr:BatchCheckLayerAvailability"
            ]
        }
    ]
}
EOF
}

resource "aws_ecr_repository_policy" "aws_ecr_repository_policy_admin" {
  repository = aws_ecr_repository.forms_admin.name

  policy = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "AllowPull",
            "Effect": "Allow",
            "Principal": {
              "AWS": "arn:aws:iam::498160065950:role/dev-forms-admin-ecs-task-execution"
              },
            "Action": [
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "ecr:BatchCheckLayerAvailability"
            ]
        }
    ]
}
EOF
}

resource "aws_ecr_repository_policy" "aws_ecr_repository_policy_runner" {
  repository = aws_ecr_repository.forms_runner.name

  policy = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "AllowPull",
            "Effect": "Allow",
            "Principal": {
              "AWS": "arn:aws:iam::498160065950:role/dev-forms-runner-ecs-task-execution"
              },
            "Action": [
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "ecr:BatchCheckLayerAvailability"
            ]
        }
    ]
}
EOF
}