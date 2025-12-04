module "drift_detection" {
  source = "../../../modules/drift-detection"

  deployment_name     = "integration"
  schedule_expression = var.drift_detection_schedule
  git_branch          = "whi-tw/detect-deploy-integration-drift" # TODO: change back to "main" after testing
}
