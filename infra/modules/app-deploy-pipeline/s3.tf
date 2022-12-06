resource "aws_s3_bucket" "codepipeline" {
  bucket = "codepipeline-artefacts-${var.app_name}-deploy"

  tags = {
    Name = "codepipeline-artefacts-${var.app_name}-deploy"
  }
}

