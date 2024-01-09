module "artifact_bucket" {
  source = "../../../modules/secure-bucket"
  name   = "codepipline-apply-forms-terraform-${var.environment_name}"
}

resource "aws_codepipeline" "main" {
  #checkov:skip=CKV_AWS_219:Amazon Managed SSE is sufficient.
  name     = "apply-forms-terraform-${var.environment_name}"
  role_arn = aws_iam_role.codepipeline.arn

  artifact_store {
    type     = "S3"
    location = module.artifact_bucket.name
  }

  stage {
    name = "Source"
    action {
      name             = "get-forms-deploy"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["forms_deploy"]

      configuration = {
        ConnectionArn        = var.github_connection_arn
        FullRepositoryId     = "alphagov/forms-deploy"
        BranchName           = var.branch_name
        DetectChanges        = var.detect_changes
        OutputArtifactFormat = "CODEBUILD_CLONE_REF"
      }
    }
  }
}