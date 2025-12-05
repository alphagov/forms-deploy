module "chatbot_well_known" {
  source = "../../../modules/well-known/chatbot"
}

module "drift_detection" {
  source = "../../../modules/drift-detection"

  deployment_name          = "integration"
  schedule_expression      = var.drift_detection_schedule
  drift_detected_topic_arn = module.chatbot_well_known.infra_notifications_topic_arn
}
