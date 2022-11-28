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
