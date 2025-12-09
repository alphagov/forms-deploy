module "drift_detection" {
  source = "../../../modules/drift-detection"

  deployment_name     = "integration"
  schedule_expression = var.drift_detection_schedule
}
