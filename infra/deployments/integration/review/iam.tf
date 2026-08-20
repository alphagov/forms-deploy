resource "aws_iam_role" "ecs_execution" {
  name               = "review-apps-ecs-execution"
  description        = "The role assumed by AWS ECS when starting review app tasks in the review environment"
  assume_role_policy = data.aws_iam_policy_document.allow_ecs_to_assume_role.json
}

resource "aws_iam_service_linked_role" "app_autoscaling" {
  aws_service_name = "ecs.application-autoscaling.amazonaws.com"
}

resource "aws_iam_role_policy_attachment" "ecs_task_exec_standard_policy" {
  role       = aws_iam_role.ecs_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


data "aws_iam_policy_document" "allow_ecs_to_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "forms_admin_task" {
  name               = "review-apps-forms-admin-task"
  description        = "The role assumed by forms-admin review app tasks"
  assume_role_policy = data.aws_iam_policy_document.allow_ecs_to_assume_role.json
}

data "aws_iam_policy_document" "forms_admin_brand_assets" {
  statement {
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject"
    ]
    resources = ["arn:aws:s3:::${module.cloudfront.assets_bucket_name}/assets/brands/*"]
    effect    = "Allow"
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::${module.cloudfront.assets_bucket_name}"]
    effect    = "Allow"
    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values   = ["assets/brands/*"]
    }
  }
}

resource "aws_iam_role_policy" "forms_admin_task_brand_assets" {
  name   = "brand-assets"
  role   = aws_iam_role.forms_admin_task.name
  policy = data.aws_iam_policy_document.forms_admin_brand_assets.json
}
