module "drift_detection" {
  source = "../../../modules/drift-detection"

  deployment_name     = "deploy"
  schedule_expression = var.drift_detection_schedule
}
