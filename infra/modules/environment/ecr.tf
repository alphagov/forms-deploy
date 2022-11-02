resource "aws_ecr_repository" "forms_api" {
  name                 = "forms-api-${var.env_name}"
  image_tag_mutability = var.mutable_image_tags ? "MUTABLE" : "IMMUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "forms_runner" {
  name                 = "forms-runner-${var.env_name}"
  image_tag_mutability = var.mutable_image_tags ? "MUTABLE" : "IMMUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "forms_admin" {
  name                 = "forms-admin-${var.env_name}"
  image_tag_mutability = var.mutable_image_tags ? "MUTABLE" : "IMMUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}
