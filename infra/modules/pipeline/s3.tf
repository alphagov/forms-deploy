resource "aws_s3_bucket" "codepipeline" {
  bucket = "codepipeline-artefacts-${var.terraform_deployment}-deploy"

  tags = {
    Name = "codepipeline-artefacts-${var.terraform_deployment}-deploy"
  }
}

