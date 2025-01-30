data "aws_caller_identity" "caller" {}

resource "aws_ecr_repository" "repository" {
  #checkov:skip=CKV_AWS_136:AWS Managed SSE is sufficient.
  #checkov:skip=CKV_AWS_51:We will want mutable tags in this environment
  name = var.repository_name

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "policy" {
  repository = aws_ecr_repository.repository.name
  policy     = data.aws_ecr_lifecycle_policy_document.lifecycle.json
}

data "aws_ecr_lifecycle_policy_document" "lifecycle" {
  rule {
    priority    = 1
    description = "Delete images older than 30 days"

    selection {
      tag_status   = "any"
      count_type   = "sinceImagePushed"
      count_number = 30
      count_unit   = "days"
    }

    action {
      type = "expire"
    }
  }
}
