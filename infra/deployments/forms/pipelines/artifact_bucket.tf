module "artifact_bucket" {
  source = "../../../modules/secure-bucket"
  name   = "pipeline-govuk-forms-artifact-bucket-${var.environment_name}"
}