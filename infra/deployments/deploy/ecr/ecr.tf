resource "aws_ecr_repository" "forms_api" {
  #checkov:skip=CKV_AWS_136:AWS Managed SSE is sufficient.
  name                 = "forms-api-deploy"
  image_tag_mutability = "IMMUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "forms_runner" {
  #checkov:skip=CKV_AWS_136:AWS Managed SSE is sufficient.
  name                 = "forms-runner-deploy"
  image_tag_mutability = "IMMUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "forms_admin" {
  #checkov:skip=CKV_AWS_136:AWS Managed SSE is sufficient.
  name                 = "forms-admin-deploy"
  image_tag_mutability = "IMMUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "forms_product_page" {
  #checkov:skip=CKV_AWS_136:AWS Managed SSE is sufficient.
  name                 = "forms-product-page-deploy"
  image_tag_mutability = "IMMUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "end_to_end_tests" {
  #checkov:skip=CKV_AWS_136:AWS Managed SSE is sufficient.
  #checkov:skip=CKV_AWS_51:Permit mutable tags on pipeline images
  name                 = "end-to-end-tests"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository_policy" "aws_ecr_repository_policy_api" {
  repository = aws_ecr_repository.forms_api.name
  policy     = data.aws_iam_policy_document.aws_ecr_repository_policy_api_document.json

}

data "aws_iam_policy_document" "aws_ecr_repository_policy_api_document" {
  statement {
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability"
    ]
    effect = "Allow"

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::619109835131:role/user-research-forms-api-ecs-task-execution",
        "arn:aws:iam::498160065950:role/dev-forms-api-ecs-task-execution",
        "arn:aws:iam::972536609845:role/staging-forms-api-ecs-task-execution",
        "arn:aws:iam::443944947292:role/production-forms-api-ecs-task-execution"
      ]
    }
  }
}


resource "aws_ecr_repository_policy" "aws_ecr_repository_policy_admin" {
  repository = aws_ecr_repository.forms_admin.name
  policy     = data.aws_iam_policy_document.aws_ecr_repository_policy_admin.json

}

data "aws_iam_policy_document" "aws_ecr_repository_policy_admin" {
  statement {
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability"
    ]
    effect = "Allow"

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::619109835131:role/user-research-forms-admin-ecs-task-execution",
        "arn:aws:iam::498160065950:role/dev-forms-admin-ecs-task-execution",
        "arn:aws:iam::972536609845:role/staging-forms-admin-ecs-task-execution",
        "arn:aws:iam::443944947292:role/production-forms-admin-ecs-task-execution"
      ]
    }
  }
}

resource "aws_ecr_repository_policy" "aws_ecr_repository_policy_runner" {
  repository = aws_ecr_repository.forms_runner.name
  policy     = data.aws_iam_policy_document.aws_ecr_repository_policy_runner_document.json

}

data "aws_iam_policy_document" "aws_ecr_repository_policy_runner_document" {

  statement {
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability"
    ]
    effect = "Allow"

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::619109835131:role/user-research-forms-runner-ecs-task-execution",
        "arn:aws:iam::498160065950:role/dev-forms-runner-ecs-task-execution",
        "arn:aws:iam::972536609845:role/staging-forms-runner-ecs-task-execution",
        "arn:aws:iam::443944947292:role/production-forms-runner-ecs-task-execution"
      ]
    }
  }
}

resource "aws_ecr_repository_policy" "aws_ecr_repository_policy_product_page" {
  repository = aws_ecr_repository.forms_product_page.name
  policy     = data.aws_iam_policy_document.aws_ecr_repository_policy_product_page_document.json

}

data "aws_iam_policy_document" "aws_ecr_repository_policy_product_page_document" {

  statement {
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability"
    ]
    effect = "Allow"

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::619109835131:role/user-research-forms-product-page-ecs-task-execution",
        "arn:aws:iam::498160065950:role/dev-forms-product-page-ecs-task-execution",
        "arn:aws:iam::972536609845:role/staging-forms-product-page-ecs-task-execution",
        "arn:aws:iam::443944947292:role/production-forms-product-page-ecs-task-execution"
      ]
    }
  }
}