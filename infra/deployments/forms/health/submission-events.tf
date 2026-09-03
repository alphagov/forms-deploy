module "submission_events" {
  count    = var.forms_runner_settings.enable_submission_events_analytics ? 1 : 0
  source   = "../../../modules/submission-events"
  env_name = var.environment_name
}
